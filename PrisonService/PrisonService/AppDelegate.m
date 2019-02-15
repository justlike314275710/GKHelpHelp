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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerThirdParty];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    [[PSLaunchManager sharedInstance] launchApplication];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    return YES;
}

- (void)registerThirdParty {
    //键盘
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //云信
    [[NIMSDK sharedSDK] registerWithAppID:NIMKEY cerName:nil];
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
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
}


@end
