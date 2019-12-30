//
//  PSGuideManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSGuideManager.h"
#import "PSGuideViewController.h"

#define DID_GUIDE_KEY @"DID_GUIDE_KEY"

@implementation PSGuideManager

+ (PSGuideManager *)sharedInstance {
    static PSGuideManager *manager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken,^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (void)guideAction:(LaunchTaskCompletion)completion {
    //每次更新出现一次 加上版本号
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    NSString *key = [NSString stringWithFormat:@"%@_%@",localVersion,DID_GUIDE_KEY];
    BOOL didGuide = [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
    if (didGuide) {
        if (completion) {
            completion(YES);
        }
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        PSGuideViewController *guideViewController = [PSGuideViewController new];
        NSString*guideOne=NSLocalizedString(@"guideOne", @"guideOne");
        NSString*guideTwo=NSLocalizedString(@"guideTwo", @"guideTwo");
        NSString*guideThree=NSLocalizedString(@"guideThree", @"guideThree");
        [guideViewController setNamesGroup:^NSArray *{
            return @[guideOne,guideTwo,guideThree];
        }];
        [guideViewController setCompleted:^{
            if (completion) {
                completion(YES);
            }
        }];
        [UIApplication sharedApplication].keyWindow.rootViewController = guideViewController;
    }
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    [self guideAction:^(BOOL completed) {
        if (completion) {
            completion(YES);
        }
    }];
}

@end
