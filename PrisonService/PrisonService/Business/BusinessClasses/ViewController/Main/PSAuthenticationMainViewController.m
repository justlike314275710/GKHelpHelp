//
//  PSAuthenticationViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/9/10.
//  Copyright © 2018年 calvin. All rights reserved.
//



#import "PSAuthenticationMainViewController.h"
#import "PSAuthenticationHomeViewController.h"
#import "PSServiceCentreViewController.h"
#import "PSUserCenterViewController.h"
#import "PSHomePageViewController.h"
#import "PSNavigationController.h"
#import "PSHomeViewController.h"
#import "PSMeViewController.h"
#import "PSContentManager.h"
#import "PSHomeViewModel.h"

@interface PSAuthenticationMainViewController ()<UITabBarControllerDelegate>

@end

@implementation PSAuthenticationMainViewController

- (id)init {
    PSHomeViewModel *homeViewModel = [[PSHomeViewModel alloc]init];;
    PSHomePageViewController*homeViewController=
        [[PSHomePageViewController alloc]initWithViewModel:homeViewModel];
    PSServiceCentreViewController*ServiceCentreViewController=
    [[PSServiceCentreViewController alloc]initWithViewModel:homeViewModel];
    PSMeViewController*meViewController=[[PSMeViewController alloc]initWithViewModel:homeViewModel];
    self.delegate = self;
   
    if (self) {
        NSString*home_page=NSLocalizedString(@"home_page", @"首页");
        NSString*service_centre=NSLocalizedString(@"service_centre", @"服务中心");
        NSString*home_me=NSLocalizedString(@"home_me", @"我的");
        [self setChildViewController:homeViewController Image:@"首页－默认" selectedImage:@"首页－选中" title:home_page];
        [self setChildViewController:ServiceCentreViewController Image:@"服务中心－灰" selectedImage:@"服务中心－蓝" title:service_centre];
        [self setChildViewController:meViewController Image:@"我的－灰" selectedImage:@"我的－蓝" title:home_me];
    }
   return self;
}


+ (void)initialize
{
    UITabBarItem *tabBarItem = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[self]];
     
    
    NSMutableDictionary *dictNormal = [NSMutableDictionary dictionary];
    dictNormal[NSForegroundColorAttributeName] = UIColorFromRGBA(45, 45, 45, 1);
    dictNormal[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    NSMutableDictionary *dictSelected = [NSMutableDictionary dictionary];
    dictSelected[NSForegroundColorAttributeName] =UIColorFromRGBA(0, 43, 113, 1);
    dictSelected[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    [tabBarItem setTitleTextAttributes:dictNormal forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:dictSelected forState:UIControlStateSelected];
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {

    PSNavigationController *navigationContoller = (PSNavigationController *)viewController;
    UIViewController *vc = navigationContoller.viewControllers.firstObject;
    if ([vc isKindOfClass:[PSHomePageViewController class]]) {
        [SDTrackTool logEvent:CLICK_HOME_PAGE];
    } else if ([vc isKindOfClass:[PSServiceCentreViewController class]]) {
        [SDTrackTool logEvent:CLICK_CENTER_SERVICE];
    } else if ([vc isKindOfClass:[PSMeViewController class]]) {
        [SDTrackTool logEvent:CLICK_MINE_PAGE];
    }
}


- (void)setChildViewController:(UIViewController *)Vc Image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title
{
    
    PSNavigationController *NA_VC = [[PSNavigationController alloc] initWithRootViewController:Vc];    
    UIImage *myImage = [UIImage imageNamed:image];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Vc.tabBarItem.image = myImage;
    
    UIImage *mySelectedImage = [UIImage imageNamed:selectedImage];
    mySelectedImage = [mySelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Vc.tabBarItem.selectedImage = mySelectedImage;
    Vc.tabBarItem.title=title;
    [self addChildViewController:NA_VC];
    
}


- (BOOL)shouldAutorotate {
   // NSLog(@"%@",[PSContentManager sharedInstance].topViewController.shouldAutorotate);
    return [PSContentManager sharedInstance].topViewController.shouldAutorotate;
    //return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [PSContentManager sharedInstance].topViewController.supportedInterfaceOrientations;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
