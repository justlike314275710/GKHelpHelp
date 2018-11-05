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
    NSString*newLawUrl=[NSString stringWithFormat:@"%@%@",PrisonDetailUrl,vistorid];
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
    [self reachability];
    // Do any additional setup after loading the view.
}

- (void)reachability {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                self.view.ly_emptyView = [XXEmptyView emptyViewWithImageStr:@"universalNetErrorIcon" titleStr:NET_ERROR detailStr:nil];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
            break; } }];
    [mgr startMonitoring];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
