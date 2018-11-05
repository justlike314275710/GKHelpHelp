//
//  PSContentManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/3.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "PSHomePageViewController.h"
#import "PSServiceCentreViewController.h"
#import "PSContentManager.h"
#import "PSMainViewController.h"
#import "PSSessionManager.h"
#import "PSAuthenticationMainViewController.h"
#import "PSCache.h"
#import "PSBusinessConstants.h"
#import "PSNavigationController.h"
#import "PSMeViewController.h"

@implementation PSContentManager
@synthesize rootViewController = _rootViewController;

+ (PSContentManager *)sharedInstance {
    static PSContentManager *contentManager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!contentManager) {
            contentManager = [[PSContentManager alloc] init];
        
        }
    });
    return contentManager;
}




- (void)launchContent {
    PSAuthenticationMainViewController *mainViewController = [[PSAuthenticationMainViewController alloc] init];
    _rootViewController = mainViewController;
    [[[UIApplication sharedApplication] delegate] window].rootViewController = _rootViewController;
//    if ([LXFileManager readUserDataForKey:@"phoneNumber"]||[LXFileManager readUserDataForKey:@"access_token"]) {
//        self.phone=[LXFileManager readUserDataForKey:@"phoneNumber"];
//        self.token=[LXFileManager readUserDataForKey:@"access_token"];
//    }
//    if ([PSSessionManager sharedInstance].loginStatus==PSLoginDenied||[PSSessionManager sharedInstance].loginStatus==PSLoginNone||[PSSessionManager sharedInstance].loginStatus == PSLoginPending) {
//       // [self saveDefaults];
//        PSAuthenticationMainViewController *mainViewController = [[PSAuthenticationMainViewController alloc] init];
//         _rootViewController = mainViewController;
//        [[[UIApplication sharedApplication] delegate] window].rootViewController = _rootViewController;
//    }
//
//    else {
//        PSMainViewController *mainViewController = [[PSMainViewController alloc] init];
//        _rootViewController = mainViewController;
//        [[[UIApplication sharedApplication] delegate] window].rootViewController = _rootViewController;
//    }
    
}



- (UINavigationController *)currentNavigationController {
    if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)_rootViewController;
    }
    else if ([_rootViewController isKindOfClass:[PSAuthenticationMainViewController class]]){
        PSAuthenticationMainViewController *mainViewController = (PSAuthenticationMainViewController *)_rootViewController;
        UIViewController *centerViewController = mainViewController.selectedViewController;
        if ([centerViewController isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)centerViewController;
        }
    }
    else if ([_rootViewController isKindOfClass:[PSMainViewController class]]) {

        PSMainViewController *mainViewController = (PSMainViewController *)_rootViewController;
        UIViewController *centerViewController = mainViewController.centerViewController;
        if ([centerViewController isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)centerViewController;
        }
    }
   
    return nil;
}

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:self.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        return [self topViewControllerWithRootViewController:[(UITabBarController *)rootViewController selectedViewController]];
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerWithRootViewController:[[navigationController viewControllers] lastObject]];
    }
    if ([rootViewController isKindOfClass:[MMDrawerController class]]) {
        return [self topViewControllerWithRootViewController:((MMDrawerController *)rootViewController).centerViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewControllerWithRootViewController:rootViewController.presentedViewController];
    }
    return rootViewController;
}

- (void)resetContent {
    UIViewController *rootViewController = self.rootViewController;
    if ([rootViewController isKindOfClass:[PSMainViewController class]]) {
        [(PSMainViewController *)rootViewController closeDrawerAnimated:YES completion:nil];
    }
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    [self launchContent];
    if (completion) {
        completion(YES);
    }
}

@end
