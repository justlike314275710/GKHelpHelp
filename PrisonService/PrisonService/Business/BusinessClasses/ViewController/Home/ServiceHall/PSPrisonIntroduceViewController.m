//
//  PSPrisonIntroduceViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonIntroduceViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "PSTipsConstants.h"
#import "XXEmptyView.h"
#import "UIView+Empty.h"
#import "PSPrisonerDetail.h"
#import "PSSessionManager.h"
#import "PSBusinessConstants.h"

@interface PSPrisonIntroduceViewController ()

@end

@implementation PSPrisonIntroduceViewController
- (instancetype)initWithURL:(NSURL *)url {
    self = [super initWithURL:url];
    NSLog(@"%@",url);
    if (self) {
        self.enableUpdateTitle = NO;
         NSString*prison_introduction=NSLocalizedString(@"prison_introduction", @"监狱简介");
        self.title = prison_introduction;
    }
    return self;
}
- (UIImage *)leftItemImage {
    return [UIImage imageNamed:@"universalBackIcon"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden=YES;
    //注册检测网络通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nonetWork) name:NotificationNoNetwork object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNoNetwork object:nil];
}

#pragma mark - Notification
-(void)nonetWork {
     self.view.ly_emptyView = [XXEmptyView emptyViewWithImageStr:@"universalNetErrorIcon" titleStr:NET_ERROR detailStr:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
