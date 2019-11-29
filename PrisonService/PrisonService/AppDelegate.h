//
//  AppDelegate.h
//  PrisonService
//
//  Created by calvin on 2018/4/2.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL IS_NetWork; //是否有网

@property (assign, nonatomic) BOOL openByNotice; //是否是通知栏启动的

@property (assign, nonatomic) NSInteger getTokenCount;

@property (assign, nonatomic) NSInteger showTokenCount; //token弹窗次数--->防止多次弹窗

@end

