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

#define BuglyAppID @"21f609a887"
#define BuglyAppIDKey @"1456f3ed-eb99-458b-9ac8-227261185610"


@interface AppDelegate()

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

- (void)registerBugly {
    [Bugly startWithAppId:BuglyAppID];
}

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
    //[BuglyManager reportErrorName:Bugly_ErrorName_AvoidCrash errorReason:errorReason callStack:callStack extraInfo:nil];
}


@end
