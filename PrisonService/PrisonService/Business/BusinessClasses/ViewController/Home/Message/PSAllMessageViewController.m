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



@interface PSAllMessageViewController ()<PSMessageTopTabViewDelegate>
@property(nonatomic,strong)NSArray *viewControllers;

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
    viewModel1.type = @"2,3";
    viewModel1.prisonerDetail = self.prisonerDetail;
    PSMessageViewController *messageViewController = [[PSMessageViewController alloc] initWithViewModel:viewModel1];
    messageViewController.dotIndex = [self.model.visitUnreadCount integerValue];
    PSMessageTopTabView *topTabbarView = [[PSMessageTopTabView alloc] initWithFrame:CGRectZero titles:titles normalImages:normalImages selectedImages:selectedImages currentIndex:0 delegate:self  viewController:self numbers:dotnumbles];

    //互动平台消息
    PSPlatMessageViewModel *viewModel2 = [[PSPlatMessageViewModel alloc] init];
    viewModel2.prisonerDetail = self.prisonerDetail;
    PSInteractiveMessageViewController *intMessageVC = [[PSInteractiveMessageViewController alloc] initWithViewModel:viewModel2];
    intMessageVC.dotIndex = [self.model.pointsUnreadCount integerValue];
    
    topTabbarView.viewControllers = @[adMessageVC,messageViewController,intMessageVC];
    self.viewControllers = @[adMessageVC,messageViewController,intMessageVC];
    [self.view addSubview:topTabbarView];
}

- (IBAction)actionOfLeftItem:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
  
}

#pragma mark - Delegate
//MARK:PSMessageTopTabViewDelegate
- (void)pagescrollMenuViewItemOnClick:(YLButton *)button index:(NSInteger)index lastindex:(NSInteger)lastindex{
    if (index==1) {
        KPostNotification(KNotificationRefreshts_message_1, nil);
    } else if (index==2) {
        KPostNotification(KNotificationRefreshhd_message_1, nil);
    }
    UIViewController *vc = [self.viewControllers objectAtIndex:lastindex];
    if ([vc isKindOfClass:[PSAdvisoryMesssageViewController class]]) {
        PSAdvisoryMesssageViewController *adMessageVC = (PSAdvisoryMesssageViewController *)vc;
        [adMessageVC reloadDataReddot]; 
    } else if ([vc isKindOfClass:[PSMessageViewController class]]) {
        PSMessageViewController *mesasgeVC = (PSMessageViewController *)vc;
        [mesasgeVC reloadDataReddot];
    } else if ([vc isKindOfClass:[PSInteractiveMessageViewController class]]) {
        PSInteractiveMessageViewController *intMesasgeVC = (PSInteractiveMessageViewController *)vc;
        [intMesasgeVC reloadDataReddot];
    }
}




@end
