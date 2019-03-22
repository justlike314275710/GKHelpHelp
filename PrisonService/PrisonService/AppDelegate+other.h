//
//  AppDelegate+other.h
//  PrisonService
//
//  Created by kky on 2018/11/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate()

@end

@interface AppDelegate (other)
/**
 检测网络
 **/
- (void)detection_network;

/**
 bug 日志收集
 **/
-(void)registerBugly;

/**
 友盟数据统计
 **/
- (void)registerUMMob;

/**
 防止崩溃（发布模式下才开启防奔溃功能 ~）
 **/
- (void)configAvoidCrash;


- (void)registerAPNs;

@end

