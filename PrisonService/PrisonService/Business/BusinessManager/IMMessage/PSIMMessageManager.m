//
//  PSNIMManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSIMMessageManager.h"
#import "PSObserverVector.h"
#import <NIMSDK/NIMSDK.h>
#import "PSSessionManager.h"
#import "PSTipsView.h"
#import "PSBusinessConstants.h"
#import "PSAlertView.h"
#import "XXAlertView.h"
#import "ZQLocalNotification.h"
#import <EBBannerView/EBBannerView.h>
#import "AppDelegate.h"
#import "UIViewController+Tool.h"
#import "PSAllMessageViewController.h"
#import "AppDelegate+other.h"
#import "PSHomeViewModel.h"
@interface PSIMMessageManager ()<NIMLoginManagerDelegate,NIMSystemNotificationManagerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) PSObserverVector *observerVector;
@property (nonatomic, strong) NIMSession *session;

@end

@implementation PSIMMessageManager

+ (PSIMMessageManager *)sharedInstance {
    static PSIMMessageManager *manager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.observerVector = [[PSObserverVector alloc] init];
        [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EBBannerViewDidClickAction:) name:EBBannerViewDidClickNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObserver:(id<PSIMMessageObserver>)observer {
    [self.observerVector addObserver:observer];
}

- (void)removeObserver:(id<PSIMMessageObserver>)observer {
    [self.observerVector removeObserver:observer];
}

- (void)sendMeetingMessage:(PSMeetingMessage *)message {
    NSString *content = [message toJSONString];
    NIMCustomSystemNotification *customSystemNotification = [[NIMCustomSystemNotification alloc] initWithContent:content];
    NSLog(@"***%@",content);
    [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:customSystemNotification toSession:self.session completion:nil];
    NSLog(@"%@",self.session);
}

/**
 *  云信登录
 *
 *  @param finished 预留回调，暂时不做任何处理
 */
- (void)doLoginIM:(LaunchTaskCompletion)completion {
    //登录云信
    NSString *account = [PSSessionManager sharedInstance].session.account?[[PSSessionManager sharedInstance].session.account copy]:[[PSSessionManager sharedInstance].session.families.openId copy];
    NSString *token = [[PSSessionManager sharedInstance].session.token copy];
    if (account.length<=0&&!account) {
        account = [LXFileManager readUserDataForKey:@"account"];
        [PSSessionManager sharedInstance].session.account = account;
    }
    if (token.length<0&&!token) {
        token = [LXFileManager readUserDataForKey:@"token"];
        [PSSessionManager sharedInstance].session.token = token;
    }
    if ([account length] > 0 && [token length] > 0) {
        //自动登录
        NIMAutoLoginData *autoLoginData = [[NIMAutoLoginData alloc] init];
        autoLoginData.account = account;
        autoLoginData.token = token;
        autoLoginData.forcedMode = YES;
        [[[NIMSDK sharedSDK] loginManager] autoLogin:autoLoginData];
    }else {
        [[PSSessionManager sharedInstance] doLogout];
    }
}

- (void)logoutIM {
    [[NIMSDK sharedSDK].loginManager logout:nil];
}

#pragma mark - NIMLoginManagerDelegate
//被踢
- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType {
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    NSString*Tips=NSLocalizedString(@"Tips", @"提示");
    NSString*pushed_off_line=NSLocalizedString(@"pushed_off_line", @"您的账号已在其他设备登陆,已被挤下线");
    XXAlertView*alert=[[XXAlertView alloc]initWithTitle:Tips message:pushed_off_line sureBtn:determine cancleBtn:nil];
    alert.clickIndex = ^(NSInteger index) {
        
        if (index==2) {
            [[PSSessionManager sharedInstance] doLogout];
        }
    };
    [alert show];
    
}
- (void)onLogin:(NIMLoginStep)step {
    if (step == NIMLoginStepSyncOK) {
    }
    if (step == NIMLoginStepLoginOK) {
    }
  
}
#pragma mark ---------- 云信自动登录失败
- (void)onAutoLoginFailed:(NSError *)error {
    if (error.code == 302 || error.code == 417) {
        //用户名或密码错误(error code 302)
        //已有一端登录导致自动登录失败（error code 417）
        NSLog(@"云信登陆错误||%@",error);
        //[self doLogout];
        NSString *msg = NSLocalizedString(@"Yunxin login failed", @"云信登录失败");
        [PSTipsView showTips:msg];
    }
}
#pragma mark ---------- NIMSystemNotificationManagerDelegate
- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification {

}
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount {
    
}
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification {
    NSString *content = notification.content;
    if ([content isKindOfClass:[NSString class]]) {
        NSError *error = nil;
        //刷新消息列表
        KPostNotification(AppDotChange, nil); //未读消息数
        UIViewController *currentVC = [UIViewController jsd_getCurrentViewController];
        //在消息列表才发送通知,及时刷新
        if ([currentVC isKindOfClass:[UIPageViewController class]]) {
            KPostNotification(KNotificationRefreshzx_message, nil);
            KPostNotification(KNotificationRefreshts_message, nil);
            KPostNotification(KNotificationRefreshhd_message, nil);
        }
        self.session = [NIMSession session:notification.sender type:NIMSessionTypeP2P];
        PSMeetingMessage *message = [[PSMeetingMessage alloc] initWithString:content error:&error];
        if (!error) {
            //apns通知启动
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (appdelegate.openByNotice) {
                appdelegate.openByNotice = NO; //不弹出前台通知
            } else {
                if (message.code == PSMeetingLocal) {
                    [self.observerVector notifyObserver:@selector(receivedLocalMeetingMessage:) object:message];
                    //只在前台弹出
                    if ([AppDelegate runningInForeground]) {
                        EBBannerView *banner = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
                            make.style = 11;
                            make.content = message.msg;
                            make.object = message;
                        }];
                        [banner show];
                    }
                }else{
                    [self.observerVector notifyObserver:@selector(receivedMeetingMessage:) object:message];
                }
            }
        }
    }
}
#pragma mark ---------- Notification Method
-(void)EBBannerViewDidClickAction:(NSNotification *)noti{
    PSMeetingMessage *message = noti.object;
    switch (message.code) {
        case PSMeetingStatus:
        case PSMeetingLocal:
        case PSMeetingCancelAuthorization:
        {
            [self getCountVisit:1];
        }
            break;
        case PSMessageArticleInteractive:
        {
            [self getCountVisit:2];
        }
            break;
            
        default:
            break;
    }
    //延时刷新未读红点数
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        KPostNotification(AppDotChange, nil);
    });
}

#pragma mark ---------- 获取系统消息数
- (void)getCountVisit:(NSInteger)index{
    UIViewController *currentVC = [UIViewController jsd_getCurrentViewController];
//    PSHomeViewModel *homeViewModel = [[PSHomeViewModel alloc] init];
//    [homeViewModel getRequestCountVisitCompleted:^(PSResponse *response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            PSAllMessageViewController *allMessageVC = [[PSAllMessageViewController alloc] init];
            allMessageVC.current = index;
//            allMessageVC.model = homeViewModel.messageCountModel;
            [currentVC.navigationController pushViewController:allMessageVC animated:YES];
            NSString *obj = [NSString stringWithFormat:@"%ld",(long)index];
            KPostNotification(KNOtificationALLMessageScrollviewIndex,obj);
//        });
//    } failed:^(NSError *error) {
//
//    }];
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    [self doLoginIM:nil];
    if (completion) {
        completion(YES);
    }
}
- (NSString *)taskName {
    return @"IM消息收发管理";
}


@end
