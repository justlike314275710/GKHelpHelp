//
//  PSAuthenticationHomePageViewController.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/15.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "SDCycleScrollView.h"
#import "PSBusinessViewController.h"

@interface PSHomePageViewController : PSBusinessViewController
@property (nonatomic, strong) SDCycleScrollView *advView;
//是否显示广告
- (BOOL)showAdv;
@end
