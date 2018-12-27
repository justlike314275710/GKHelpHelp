//
//  STNavigationViewController.m
//  NavAnimation
//
//  Created by calvin on 14-6-25.
//  Copyright (c) 2014年 BuBuGao. All rights reserved.
//

#import "PSNavigationController.h"

@interface PSNavigationController ()<UINavigationControllerDelegate>

@property (nonatomic, assign) UIInterfaceOrientation targetOrientation;
@property (nonatomic, assign) NSTimeInterval afterDelay;

@end

@implementation PSNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initializatio
    }
    return self;
}

- (void)rotate {
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationUnknown) forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:@(self.targetOrientation) forKey:@"orientation"];
}

- (void)resetOrientationWithOrientationMask:(UIInterfaceOrientationMask)orientationmask {
    self.targetOrientation = orientationmask == UIInterfaceOrientationMaskPortrait ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight;
    if (self.afterDelay > 0) {
        [self performSelector:@selector(rotate) withObject:nil afterDelay:self.afterDelay];
    }else {
        [self rotate];
    }
}




- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    UIViewController *topViewController = self.topViewController;
    BOOL popAnimated = animated;
    if (topViewController) {
        UIInterfaceOrientationMask orientationMask = [topViewController supportedInterfaceOrientations];
        UIInterfaceOrientationMask willOrientationMask = [viewController supportedInterfaceOrientations];
        if (orientationMask != willOrientationMask) {
            popAnimated = NO;
        }
    }
    viewController.hidesBottomBarWhenPushed=YES;
    [super pushViewController:viewController animated:popAnimated];
    viewController.hidesBottomBarWhenPushed=NO;
    //处理iPhone X上push时导致的tabBar上移问题
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
    if (topViewController) {
        UIInterfaceOrientationMask orientationMask = [topViewController supportedInterfaceOrientations];
        UIInterfaceOrientationMask willOrientationMask = [viewController supportedInterfaceOrientations];
        if (orientationMask != willOrientationMask) {
            self.afterDelay = 0.005f;
            [self resetOrientationWithOrientationMask:willOrientationMask];
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    NSInteger count = [self.viewControllers count];
    UIViewController *willShowViewController = count >= 2 ? self.viewControllers[count - 1 - 1] : nil;
    UIViewController *topViewController = self.topViewController;
    BOOL popAnimated = animated;
    if (willShowViewController) {
        UIInterfaceOrientationMask willShowOrientationMask = [willShowViewController supportedInterfaceOrientations];
        UIInterfaceOrientationMask topOrientationMask = [topViewController supportedInterfaceOrientations];
        if (willShowOrientationMask != topOrientationMask) {
            popAnimated = NO;
        }
    }
    UIViewController *viewController = [super popViewControllerAnimated:popAnimated];
    if (willShowViewController) {
        UIInterfaceOrientationMask willShowOrientationMask = [willShowViewController supportedInterfaceOrientations];
        UIInterfaceOrientationMask topOrientationMask = [topViewController supportedInterfaceOrientations];
        if (willShowOrientationMask != topOrientationMask) {
            self.afterDelay = 0.0f;
            [self resetOrientationWithOrientationMask:willShowOrientationMask];
        }
    }
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate=self;
    // Do any additional setup after loading the view.
    //设置标题字体

}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //self.tabBarController.tabBar.hidden=NO;
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}




- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
