//
//  AppDelegate+other.m
//  PrisonService
//
//  Created by kky on 2018/11/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "AppDelegate+other.h"
#import <AFNetworking/AFNetworking.h>

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
                 [KGStatusBar showWithStatus:@"当前网络不可用,请检查你的网络设置"];
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

@end
