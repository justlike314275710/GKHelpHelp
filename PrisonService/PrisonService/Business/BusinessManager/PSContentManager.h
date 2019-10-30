//
//  PSContentManager.h
//  PrisonService
//
//  Created by calvin on 2018/4/3.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSLaunchTask.h"

@interface PSContentManager : NSObject<PSLaunchTask>

@property (nonatomic, strong, readonly) UIViewController       *rootViewController;
@property (nonatomic, strong, readonly) UIViewController       *topViewController;
@property (nonatomic, strong, readonly) UINavigationController *currentNavigationController;
@property (nonatomic, strong          ) NSString               *phone;
@property (nonatomic, strong         ) NSString *token;


+ (PSContentManager *)sharedInstance;
- (void)resetContent;
- (void)launchContent;
@end
