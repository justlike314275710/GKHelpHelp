//
//  PSAllMessageViewController.m
//  PrisonService
//
//  Created by kky on 2019/9/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSAllMessageViewController.h"
#import "PSMessageTopTabView.h"
#import "PSMessageViewController.h"
#import "PSAdvisoryMesssageViewController.h"
#import "PSInteractiveMessageViewController.h"
#import "PSMessageViewModel.h"
#import "PSPlatMessageViewModel.h"
#import "PSPrisonIntroduceViewController.h"



@interface PSAllMessageViewController ()<PSMessageTopTabViewDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource>{
}
@property(nonatomic, strong)NSArray *viewControllers;
@property(nonatomic, strong)PSMessageTopTabView *topTabbarView;
@property(nonatomic, strong)UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property(nonatomic, strong)UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property(nonatomic, strong)UIPageViewController *pageViewController;



@end

@implementation PSAllMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    NSArray *titles = @[@"咨询消息",@"探视消息",@"互动平台"];
    NSArray *normalImages = @[@"未选中资讯消息icon",@"未选中探视消息icon",@"未选中互动平台icon"];
    NSArray *selectedImages = @[@"已选中资讯消息icon",@"已选中探视消息icon",@"已选中互动平台icon"];
    NSString *visitUnreadCount = self.model.visitUnreadCount?self.model.visitUnreadCount:@"0";
    NSString *pointsUnreadCount = self.model.pointsUnreadCount?self.model.pointsUnreadCount:@"0";
    NSArray *dotnumbles = @[@"0",visitUnreadCount,pointsUnreadCount];
    
    //咨询消息
    PSMessageViewModel *viewModel = [[PSMessageViewModel alloc] init];
    viewModel.prisonerDetail = self.prisonerDetail;
    PSAdvisoryMesssageViewController *adMessageVC = [[PSAdvisoryMesssageViewController alloc] initWithViewModel:viewModel];
    adMessageVC.dotIndex = 0;
    //探视消息
    PSMessageViewModel *viewModel1 = [[PSMessageViewModel alloc] init];
    viewModel1.type = @"1,2,3";
    viewModel1.prisonerDetail = self.prisonerDetail;
    PSMessageViewController *messageViewController = [[PSMessageViewController alloc] initWithViewModel:viewModel1];
    messageViewController.dotIndex = [self.model.visitUnreadCount integerValue];
    _topTabbarView = [[PSMessageTopTabView alloc] initWithFrame:CGRectZero titles:titles normalImages:normalImages selectedImages:selectedImages currentIndex:_current delegate:self  viewController:self numbers:dotnumbles];
    _lastIndex = _current;
    //互动平台消息
    PSPlatMessageViewModel *viewModel2 = [[PSPlatMessageViewModel alloc] init];
    viewModel2.prisonerDetail = self.prisonerDetail;
    PSInteractiveMessageViewController *intMessageVC = [[PSInteractiveMessageViewController alloc] initWithViewModel:viewModel2];
    intMessageVC.dotIndex = [self.model.pointsUnreadCount integerValue];
    self.viewControllers = @[adMessageVC,messageViewController,intMessageVC];
    [self.view addSubview:_topTabbarView];
    [self pageViewController];
    //滑动到第几个
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollviewIndex:) name:KNOtificationALLMessageScrollviewIndex object:nil];
    
    
}
#pragma mark -----------PrivateMethods
-(void)scrollviewIndex:(NSNotification *)noti {
    NSInteger index = [noti.object integerValue];
    [self scrollviewItemIndex:index];
    [self pagescrollMenuViewItemOnClick:nil index:index lastindex:_current];
}
-(void)scrollviewItemIndex:(NSInteger)index{
    [_topTabbarView scrollviewItemIndex:index];
}
- (IBAction)actionOfLeftItem:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"%@",self.navigationController.viewControllers);
}

#pragma mark - Delegate
//MARK:PSMessageTopTabViewDelegate
- (void)pagescrollMenuViewItemOnClick:(YLButton *)button index:(NSInteger)index lastindex:(NSInteger)lastindex{
    
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    if (index >lastindex) {
        [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
    } else {
        [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        }];
    }
    [self reloadRed:lastindex];
    _lastIndex = index;
    _current = index;
}

- (UIPageViewController *)pageViewController
{
    if(!_pageViewController)
    {
        NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                           forKey: UIPageViewControllerOptionSpineLocationKey];
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:options];
        [[_pageViewController view] setFrame:CGRectMake(0,55, KScreenWidth,KScreenHeight-45)];

        // 设置UIPageViewController的配置项
        [_pageViewController setViewControllers:[NSArray arrayWithObjects:_viewControllers[_current], nil]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        
    }
    return _pageViewController;
    
}

#pragma mark
#pragma mark ----- UIPageViewControllerDataSource -----
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexForViewController:viewController];
    if (index == 0) {
        index = [self.viewControllers count] - 1;
    } else {
        index--;
    }
    NSLog(@"-------%@",[self viewControllerAtIndex:index]);
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexForViewController:viewController];
    index++;
    if (index == [self.viewControllers count]) {
        index = 0;
    }
    NSLog(@"-------%@",[self viewControllerAtIndex:index]);
    return [self viewControllerAtIndex:index];
}
- (NSUInteger)indexForViewController:(UIViewController *)viewController
{
    return [self.viewControllers indexOfObject:viewController];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index > [self.viewControllers count]) {
        return nil;
    }
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    return vc;
}

#pragma mark
#pragma mark ----- UIPageViewControllerDelegate -----
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIViewController *vc = pendingViewControllers[0];
    _current = [self indexForViewController:vc];
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self reloadRed:_lastIndex];
        _lastIndex = _current;
        [self scrollviewItemIndex:_current];
    }
}

-(void)reloadRed:(NSInteger)index{
    UIViewController *vc = [self viewControllerAtIndex:index];
    if ([vc isKindOfClass:[PSAdvisoryMesssageViewController class]]) {
        [(PSAdvisoryMesssageViewController *)vc reloadDataReddot];
    } else if ([vc isKindOfClass:[PSMessageViewController class]]) {
        [(PSMessageViewController *)vc reloadDataReddot];
    } else if ([vc isKindOfClass:[PSInteractiveMessageViewController class]]) {
        [(PSInteractiveMessageViewController *)vc reloadDataReddot];
    }
    [_topTabbarView hidebadgeIndex:_lastIndex];
}

@end
