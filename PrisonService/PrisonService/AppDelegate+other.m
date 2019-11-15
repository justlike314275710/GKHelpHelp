//
//  AppDelegate+other.m
//  PrisonService
//
//  Created by kky on 2018/11/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "AppDelegate+other.h"
#import <AFNetworking/AFNetworking.h>
#import <Bugly/Bugly.h>
#import "SDTrackTool.h"
#import <AvoidCrash/AvoidCrash.h>
#import <Bugly/Bugly.h>
#import <UserNotifications/UserNotifications.h>
#import "PSMeetingMessage.h"
#import "PSAllMessageViewController.h"
#import "UIViewController+Tool.h"


#define BuglyAppID @"21f609a887"
#define BuglyAppIDKey @"1456f3ed-eb99-458b-9ac8-227261185610"


@interface AppDelegate()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate (other)

- (void)detection_network {
    
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未知网络");
                [KGStatusBar dismiss];
                self.IS_NetWork = YES;
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"无网络");
                // 没有网络的时候发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNoNetwork object:nil];
                NSString *msg = NSLocalizedString(@"Network not available, check network settings", @"当前网络不可用,请检查你的网络设置");
                [KGStatusBar showWithStatus:msg];
                self.IS_NetWork = NO;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                [KGStatusBar dismiss];
                NSLog(@"网络数据连接");
                self.IS_NetWork = YES;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"wifi连接");
                [KGStatusBar dismiss];
                self.IS_NetWork = YES;
            }
                break;
            default:
                break;
        }
    }];
    [netManager startMonitoring];
    
}
#pragma mark ---------- apns
- (void)registerAPNS:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                dispatch_async(dispatch_get_main_queue(), ^{
                     [application registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    }else if (systemVersion >= 8.0) {
        // iOS >= 8 Notifications
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }else {
        // iOS < 8 Notifications
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}
#pragma mark ---------- 远程APNS推送打开app(点击推送push)
- (void)userNotificationCenterApns:(NSDictionary*)userInfo{
    
    PSMeetingMessage *message = [[PSMeetingMessage alloc] initWithDictionary:userInfo error:nil];
    UIViewController *currentVC = [UIViewController jsd_getCurrentViewController];
    NSLog(@"%@",message);
    switch (message.code) {
        case PSMeetingStatus:
        case PSMeetingLocal:
        case PSMeetingCancelAuthorization:
        {
            PSAllMessageViewController *allMessageVC = [[PSAllMessageViewController alloc] init];
            allMessageVC.current = 1;
            [currentVC.navigationController pushViewController:allMessageVC animated:YES];

        }
            break;
        case PSMessageArticleInteractive:
        {
            PSAllMessageViewController *allMessageVC = [[PSAllMessageViewController alloc] init];
            allMessageVC.current = 2;
            [currentVC.navigationController pushViewController:allMessageVC animated:YES];
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

#pragma mark ---------- UNUserNotificationCenterDelegate
//App处于前台收到本地推送或者远程推送时调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0) __TVOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0){
    NSLog(@"userInfo : %@",notification.request.content.userInfo);
    
    
}
//App处于后台（未杀死）点击本地推送或者远程推送时调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler __IOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0) __TVOS_PROHIBITED{
    
    NSLog(@"%@",response.notification.request.content.userInfo);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if(userInfo){
        PSMeetingMessage *message = [[PSMeetingMessage alloc] initWithDictionary:userInfo error:nil];
        UIViewController *currentVC = [UIViewController jsd_getCurrentViewController];
        NSLog(@"%@",message);
        switch (message.code) {
            case PSMeetingStatus:
            case PSMeetingLocal:
            case PSMeetingCancelAuthorization:
            {
                PSAllMessageViewController *allMessageVC = [[PSAllMessageViewController alloc] init];
                allMessageVC.current = 1;
                [currentVC.navigationController pushViewController:allMessageVC animated:YES];
            }
                break;
            case PSMessageArticleInteractive:
            {
                PSAllMessageViewController *allMessageVC = [[PSAllMessageViewController alloc] init];
                allMessageVC.current = 2;
                [currentVC.navigationController pushViewController:allMessageVC animated:YES];
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
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"userInfo : %@",userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        //app在前台
    }else{
        //app在后台点击远程推送
    }
}
//App处于前台收到本地推送消息，或者后台（未杀死）点击本地推送消息时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"userInfo : %@",notification.userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        //app在前台
    }else{
        //app在后台点击远程推送
    }
}

- (void)registerAPNs
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        UIUserNotificationType types         = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |      UIRemoteNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound |        UIRemoteNotificationTypeBadge;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

#pragma mark ---------- Bugly
- (void)registerBugly {
    [Bugly startWithAppId:BuglyAppID];
}
#pragma mark ---------- mob
- (void)registerUMMob {
    [SDTrackTool configure];
}

/*
 * 发布模式下才开启防奔溃功能 ~
 */
-(void)configAvoidCrash
{
    
//#if !(defined(DEBUG)||defined(_DEBUG))
    [AvoidCrash makeAllEffective];
    
    //================================================
    //   1、unrecognized selector sent to instance（方式1）
    //================================================
    
    //若出现unrecognized selector sent to instance并且控制台输出:
    //-[__NSCFConstantString initWithName:age:height:weight:]: unrecognized selector sent to instance
    //你可以将@"__NSCFConstantString"添加到如下数组中，当然，你也可以将它的父类添加到下面数组中
    //比如，对于部分字符串，继承关系如下
    //__NSCFConstantString --> __NSCFString --> NSMutableString --> NSString
    //你可以将上面四个类随意一个添加到下面的数组中，建议直接填入 NSString
    //我所开发的项目中所防止unrecognized selector sent to instance的类有下面几个，主要是防止后台数据格式错乱导致的崩溃。个人觉得若要防止后台接口数据错乱，用下面的几个类即可。
    //=============================================
    //   1、unrecognized selector sent to instance
    //=============================================
    NSArray *noneSelClassStrings = @[
                                     @"NSNull",
                                     @"NSNumber",
                                     @"NSString",
                                     @"NSDictionary",
                                     @"NSArray"
                                     ];
    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    
    //=============================================
    //   2、unrecognized selector sent to instance
    //=============================================
    
    //若需要防止某个前缀的类的unrecognized selector sent to instance
    NSArray *noneSelClassPrefix = @[
                                    @"NSNull",
                                    ];
    [AvoidCrash setupNoneSelClassStringPrefixsArr:noneSelClassPrefix];
    
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
//#endif
    
}

- (void)dealwithCrashMessage:(NSNotification *)note {
    //异常拦截并且通过bugly上报
    NSDictionary *info = note.userInfo;
    NSString *errorReason = [NSString stringWithFormat:@"【ErrorReason】%@========【ErrorPlace】%@========【DefaultToDo】%@========【ErrorName】%@", info[@"errorReason"], info[@"errorPlace"], info[@"defaultToDo"], info[@"errorName"]];
    NSArray *callStack = info[@"callStackSymbols"];
    NSLog(@"***********AvoidCrash捕捉到异常奔溃，奔溃信息如下***********\n %@ \n %@",errorReason,callStack);
    
    [Bugly reportExceptionWithCategory:3 name:info[@"errorName"] reason:errorReason callStack:callStack extraInfo:nil terminateApp:NO];
//    [BuglyManager reportErrorName:Bugly_ErrorName_AvoidCrash errorReason:errorReason callStack:callStack extraInfo:nil];
}

+(BOOL) runningInBackground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    
    return result;
}

+(BOOL) runningInForeground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateActive);
    
    return result;
}



@end
