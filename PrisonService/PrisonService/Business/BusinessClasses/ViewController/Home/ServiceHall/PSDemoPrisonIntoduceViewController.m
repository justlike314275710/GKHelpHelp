//
//  PSDemoPrisonIntoduceViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/9/20.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSDemoPrisonIntoduceViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "PSTipsConstants.h"
#import "XXEmptyView.h"
#import "UIView+Empty.h"
#import "PSBusinessConstants.h"
@interface PSDemoPrisonIntoduceViewController ()

@end

@implementation PSDemoPrisonIntoduceViewController

- (id)init {
    
    NSString*vistorid= [LXFileManager readUserDataForKey:@"vistorId"]?[LXFileManager readUserDataForKey:@"vistorId"]:@"72";
    NSString*newLawUrl=[NSString stringWithFormat:@"%@%@t=%@",PrisonDetailUrl,vistorid,[NSDate getNowTimeTimestamp]];
    self = [super initWithURL:[NSURL URLWithString:newLawUrl]];
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
