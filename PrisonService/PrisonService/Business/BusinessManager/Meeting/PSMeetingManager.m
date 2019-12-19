//
//  PSMeetingManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "PSMeetingManager.h"
#import "PSIMMessageManager.h"
#import "PSJailConfigurationsRequest.h"
#import "PSViewModelService.h"
#import "PSRingMeetingViewController.h"
#import "PSContentManager.h"
#import "PSFaceAuthViewController.h"
#import "PSMeetingViewController.h"
#import "PSTipsView.h"
#import "PSAlertView.h"
#import "PSSessionManager.h"
#import "ZQLocalNotification.h"
#import "WXZTipView.h"
#import "PSFamilyFaceViewController.h"
#import "PSFamliesFaceViewController.h"
#import <EBBannerView/EBBannerView.h>
#import "UIViewController+Tool.h"
#import "AppDelegate+other.h"
#import "PSAllMessageViewController.h"
#import "PSHomeViewModel.h"
#import "PSAllMessageViewController.h"

#import "PSLocateManager.h"
@interface PSMeetingManager ()<PSIMMessageObserver>

@property (nonatomic, strong) PSJailConfigurationsRequest *jailConfigurationsRequest;
@property (nonatomic, strong) NSString *jailId;
@property (nonatomic, strong) NSString *jailName;
@property (nonatomic, strong) NSString *meetingID;
@property (nonatomic ,strong) NSString *familesMeetingID ;
@property (nonatomic, strong) NSString *presenterPassword;
@property (nonatomic, strong) NSString *meetingPassword;
@property (nonatomic, strong) PSJailConfiguration *jailConfiguration;
//@property (nonatomic, strong) PSNavigationController *meetingNavigationController;

@end

@implementation PSMeetingManager
+ (PSMeetingManager *)sharedInstance {
    static PSMeetingManager *manager = nil;
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
        [[PSIMMessageManager sharedInstance] addObserver:self];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EBBannerViewDidClickAction:) name:EBBannerViewDidClickNotification object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[PSIMMessageManager sharedInstance] removeObserver:self];
}

- (void)requestJailConfigurationsCompletion:(RequestDataCompleted)completionCallback failed:(RequestDataFailed)failedCallback {
    self.jailConfigurationsRequest = [PSJailConfigurationsRequest new];
    self.jailConfigurationsRequest.jailId = self.jailId;
    [self.jailConfigurationsRequest send:^(PSRequest *request, PSResponse *response) {
        if (completionCallback) {
            completionCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)fetchJailConfigurations {
    @weakify(self)
    [self requestJailConfigurationsCompletion:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSJailConfigurationsResponse *configurationResponse = (PSJailConfigurationsResponse *)response;
            self.jailConfiguration = configurationResponse.configuration;
            self.jailName = configurationResponse.jailName;
        }else{
            self.jailConfiguration = [[PSJailConfiguration alloc] init];
        }
        [self ringAndShowMeeting];
    } failed:^(NSError *error) {
        @strongify(self)
        self.jailConfiguration = [[PSJailConfiguration alloc] init];
        [self ringAndShowMeeting];
    }];
}

//响铃并显示接听界面
- (void)ringAndShowMeeting {
    //埋点...
    [SDTrackTool logEvent:RECEIVE_REMOTE_CALL];
    
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.jailConfiguration = self.jailConfiguration;
    viewModel.jailName = self.jailName;
    PSRingMeetingViewController *ringViewController = [[PSRingMeetingViewController alloc] initWithViewModel:viewModel];
    @weakify(self)
    [ringViewController setUserOperation:^(PSMeetingOperation operation) {
        @strongify(self)
        if (operation == PSMeetingRefuse) {
            [self refuseOperation];
        }else{
            [self acceptOperation];
        }
    }];
    self.meetingNavigationController = [[PSNavigationController alloc] initWithRootViewController:ringViewController];
    [[PSContentManager sharedInstance].rootViewController presentViewController:self.meetingNavigationController animated:NO completion:nil];
}

- (void)refuseOperation {
    
    PSMeetingMessage *exitMessage = [PSMeetingMessage new];
    exitMessage.code = PSMeetingEnd;
    [[PSIMMessageManager sharedInstance] sendMeetingMessage:exitMessage];
    [self clearMeeting];
    [self.meetingNavigationController dismissViewControllerAnimated:NO completion:nil];
    self.meetingNavigationController = nil;
}

- (void)acceptOperation {
    if ([self.jailConfiguration.face_recognition isEqualToString:@"0"]) {
        //开始视频通话
        [self startMeeting];
    }else{
        //需要人脸识别
        [self checkFaceAuth];
    }
}
//虹软人脸识别


//人脸识别验证
- (void)checkFaceAuth {
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.jailConfiguration = self.jailConfiguration;
    viewModel.jailName = self.jailName;
    viewModel.meetingID = self.meetingID;
    viewModel.meetingPassword = self.meetingPassword;
    viewModel.presenterPassword = self.presenterPassword;
    viewModel.familymeetingID=self.familesMeetingID;
    viewModel.faceType=PSFaceMeeting;
    PSFaceAuthViewController *authViewController = [[PSFaceAuthViewController alloc] initWithViewModel:viewModel];
    @weakify(self)
    [authViewController setCompletion:^(BOOL successful) {
        @strongify(self)
        if (successful) {
            //开始视频通话
            [self startMeeting];
        }else{
            [self.meetingNavigationController dismissViewControllerAnimated:NO completion:nil];
            self.meetingNavigationController = nil;
            PSMeetingMessage *exitMessage = [PSMeetingMessage new];
            exitMessage.code = PSMeetingEnd;
            [[PSIMMessageManager sharedInstance] sendMeetingMessage:exitMessage];
        }
    }];
    [self.meetingNavigationController pushViewController:authViewController animated:YES];

}



/**
 视频通话
 */
- (void)startMeeting {
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.jailConfiguration = self.jailConfiguration;
    viewModel.jailName = self.jailName;
    viewModel.meetingID = self.meetingID;
    viewModel.meetingPassword = self.meetingPassword;
    viewModel.presenterPassword = self.presenterPassword;
    viewModel.familymeetingID=self.familesMeetingID;
    viewModel.callDuration=self.callDuration;
    
    
    
   PSMeetingViewController *meetingViewController = [[PSMeetingViewController alloc] initWithViewModel:viewModel];
//    [self.meetingNavigationController pushViewController:meetingViewController animated:YES];
//    [[PSContentManager sharedInstance] resetContent];
    [[PSContentManager sharedInstance].currentNavigationController pushViewController:meetingViewController animated:NO];
    //进入会议，发送进入会议消息
    PSMeetingMessage *enterMessage = [PSMeetingMessage new];
    enterMessage.code = PSMeetingEnter;
    [[PSIMMessageManager sharedInstance] sendMeetingMessage:enterMessage];
    [self.meetingNavigationController dismissViewControllerAnimated:NO completion:nil];
     self.meetingNavigationController = nil;
}

/**
 发送免费会见定位
 
 @param meetingID 会见ID(监狱端传送）
 */
-(void)sendFreeLocation:(NSString*)meetingID{
    CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status){
       
    }else//开启的
    {
        PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
        viewModel.meetingID = meetingID;
        viewModel.lat=[PSLocateManager sharedInstance].lat;
        viewModel.lng=[PSLocateManager sharedInstance].lng;
        viewModel.province=[PSLocateManager sharedInstance].province;
        viewModel.city=[PSLocateManager sharedInstance].city;
        [viewModel requestUpdateFreeMeetingCoordinateCompleted:^(PSResponse *response) {
            
        } failed:^(NSError *error) {
            
        }];
    }
    
}

/**
 发送收费会见定位
 @param meetingID 会见ID(监狱端传送）
 */
-(void)sendChargeLocation:(NSString*)meetingID{
    CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status)
    {
    
    }else//开启的
    {
        PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
        viewModel.meetingID = meetingID;
        viewModel.lat=[PSLocateManager sharedInstance].lat;
        viewModel.lng=[PSLocateManager sharedInstance].lng;
        viewModel.province=[PSLocateManager sharedInstance].province;
        viewModel.city=[PSLocateManager sharedInstance].city;
        [viewModel requestUpdateMeetingCoordinateCompleted:^(PSResponse *response) {
    
        } failed:^(NSError *error) {
    
        }];
    }
}

//会议结束后的清理工作
- (void)clearMeeting {
    self.jailId = nil;
    self.meetingID = nil;
    self.presenterPassword = nil;
    self.meetingPassword = nil;
    self.jailName = nil;
    self.jailConfiguration = nil;
    if ([[PSContentManager sharedInstance].currentNavigationController.topViewController isKindOfClass:[PSMeetingViewController class]]) {
        [[PSContentManager sharedInstance].currentNavigationController popViewControllerAnimated:YES];
    } else {
        [[UIViewController jsd_getCurrentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleMeetingStatusMessage:(PSMeetingMessage *)message {

    //只在前台弹出
    if ([AppDelegate runningInForeground]) {
        EBBannerView *banner = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
            make.style = 11;
            make.content = message.msg;
            make.object = message;
        }];
        [banner show];
    }
}

#pragma mark - Notification Method
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
//MARK:获取系统消息数
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


#pragma mark - PSIMMessageObserver
- (void)receivedMeetingMessage:(PSMeetingMessage *)message {
    switch (message.code) {
            
        case PSFreeMeetingLocation:
        {
            [self sendFreeLocation:message.meetingId];
            
        }
            break;
            
        case PSChargeMeetingLocation:
        {
            NSString *callDuration = message.callDuration;
            //倒计时通知
            if (callDuration&&[callDuration integerValue]>0) {
                KPostNotification(KNOtificationMeetingCountdown, message);
            } else {
                
            }
            [self sendChargeLocation:message.meetingId]; //收费会见定位
            
        }
            break;
        case PSMeetingStart:
        {
            //发起会议
            if (message.msg.length > 0) {
                NSArray *msgComponents = [message.msg componentsSeparatedByString:@"##"];
                if (msgComponents.count == 3) {
                    self.meetingID = msgComponents[0];
                    self.presenterPassword = msgComponents[1];
                    self.meetingPassword = msgComponents[2];
                }
                self.jailId = message.jail;
                self.familesMeetingID=message.meetingId;
                self.callDuration=message.callDuration;
                [self fetchJailConfigurations];
            }else{
                //初始发起会见
                [[PSIMMessageManager sharedInstance] sendMeetingMessage:message];
            }
        }
            break;
        case PSMeetingEnter:
        {
            //进入会议
        }
            break;
        case PSMeetingEnd:
        {
            //挂断会议
            PSMeetingMessage *exitMessage = [PSMeetingMessage new];
            exitMessage.code = PSMeetingEnd;
            [[PSIMMessageManager sharedInstance] sendMeetingMessage:exitMessage];
            NSString*meet_end=NSLocalizedString(@"meet_end", @"监狱终端已挂断");
            [WXZTipView showBottomWithText:meet_end];
            [self clearMeeting];
            //埋点....
            [SDTrackTool logEvent:VIDEO_MEETING_COMPLETE];

            
        }
            break;
        case PSMeetingStatus:
        {
            [self handleMeetingStatusMessage:message];
        }
            break;
            
        case PSMeetingCancelAuthorization:
        {
            PSPrisonerDetail *prisonerDetail = nil;
            NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
            NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
            if (index >= 0 && index < details.count) {
                prisonerDetail = details[index];
            }
            if ([prisonerDetail.prisonerId isEqualToString:message.prisonerId]) {
                [ PSAlertView showWithTitle:@"提示" message:@"您的家属认证申请已被撤回!" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex==0) {
                        [[PSSessionManager sharedInstance]doLogout];
                    }
                } buttonTitles:@"确定", nil];
                //只在前台弹出
                if ([AppDelegate runningInForeground]) {
                    EBBannerView *banner = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
                        make.style = 11;
                        make.content = message.msg;
                        make.object = message;
                    }];
                    [banner show];
                }
            } else {
                //只在前台弹出
                if ([AppDelegate runningInForeground]) {
                    EBBannerView *banner = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
                        make.style = 11;
                        make.content = message.msg;
                        make.object = message;
                    }];
                    [banner show];
                }
            }
          
        }
          break;
        case PSMessageArticleInteractive:  //互动文章消息
        {
            //刷新我的列表
            if ([message.channel isEqualToString:@"1"]) { //1为家属段
                KPostNotification(KNotificationRefreshMyArticle, nil);
                KPostNotification(KNotificationRefreshInteractiveArticle, nil);
                KPostNotification(KNotificationRefreshCollectArticle, nil);
                //只在前台弹出
                if ([AppDelegate runningInForeground]) {
                    EBBannerView *banner = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
                        make.style = 11;
                        make.content = message.msg;
                        make.object = message;
                    }];
                    [banner show];
                }
                //发布文章权限改变
                if (message.isEnabled&&message.isEnabled.length>0) {
                    KPostNotification(KNotificationAuthorChange,message);
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    if (completion) {
        completion(YES);
    }
}

@end
