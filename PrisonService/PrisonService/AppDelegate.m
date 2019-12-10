//
//  AppDelegate.m
//  PrisonService
//
//  Created by  calvin on 2018/4/2.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "AppDelegate.h"
#import "PSLaunchManager.h"
#import "IQKeyboardManager.h"
#import "WXApi.h"
#import "PSThirdPartyConstants.h"
#import "PSPayCenter.h"
#import <NIMSDK/NIMSDK.h>
#import "iflyMSC/IFlyFaceSDK.h"
#import <AFNetworking/AFNetworking.h>
#import "KGStatusBar.h"
#import "AppDelegate+other.h"
#import <UserNotifications/UserNotifications.h>
#import "PSIMMessageManager.h"
#import "PSBusinessConstants.h"
#import "PSVersonUpdateViewModel.h"
#import "ZQLocalNotification.h"
#import "UIViewController+Tool.h"
#import "PSAllMessageViewController.h"
#import "PSLocateManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerThirdParty];
    //注册apns
    self.getTokenCount = 0;
    self.showTokenCount = 0;
    [self registerAPNS:application launchOptions:launchOptions];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    [[PSLaunchManager sharedInstance] launchApplication];
    self.openByNotice = NO;
    if (launchOptions) {
         // 获取推送通知定义的userinfo
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo) {
            self.openByNotice = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self userNotificationCenterApns:userInfo];
            });
        }
    }
    //检测更新
    PSVersonUpdateViewModel *updateViewModel = [PSVersonUpdateViewModel new];
    [updateViewModel jundgeVersonUpdate];
    if (UAT==1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth-70,0, 50, 20)];
            label.textColor = [UIColor redColor];
            label.text = @"测试";
            label.font = FontOfSize(10);
            UIWindow *wd = [UIApplication sharedApplication].keyWindow;
            [wd addSubview:label];
        });
    }
    return YES;
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}

- (void)registerThirdParty {
    //键盘
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //云信
#ifdef DEBUG
    [[NIMSDK sharedSDK] registerWithAppID:NIMKEY cerName:@"development"];
#else
    [[NIMSDK sharedSDK] registerWithAppID:NIMKEY cerName:@"distribution"];
#endif
//    获取推送设置
    //科大讯飞
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO];
    [IFlySpeechUtility createUtility:[NSString stringWithFormat:@"appid=%@",KEDAXUNFEI_APPID]];
    //微信
    [WXApi registerApp:WECHAT_APPID];
    //监测网络变化
    [self detection_network];
    //Bugly崩溃日志
    [self registerBugly];
    //配置防奔溃（发布模式下开启）
    [self configAvoidCrash];
    //友盟数据统计
    [self registerUMMob];
}
- (BOOL)handleURL:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[PSPayCenter payCenter] handleAliURL:url];
    }else if ([url.scheme isEqualToString:WECHAT_APPID] && [url.host isEqualToString:@"pay"]) {
        //微信支付
        [[PSPayCenter payCenter] handleWeChatURL:url];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches.anyObject locationInView:nil].y > 20) return;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"statusBarTappedNotification" object:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setApplicationIconBadgeNumber:0]; //清除角标
    [[UIApplication sharedApplication] cancelAllLocalNotifications];//清除APP所
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //在这个方法里输入如下清除方法
    [application setApplicationIconBadgeNumber:0]; //清除角标
    [[UIApplication sharedApplication] cancelAllLocalNotifications];//清除APP所
}
//后台进入app
- (void)applicationDidBecomeActive:(UIApplication *)application {
    //在调一下接口看登录是否过期
    self.getTokenCount = 0;
    self.showTokenCount = 0;
    KPostNotification(KNOtificationALLMessagejudgeToken, nil);
    //判断是否开启定位权限
    [self checkAuthorizationWithLocation];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
}

@end
