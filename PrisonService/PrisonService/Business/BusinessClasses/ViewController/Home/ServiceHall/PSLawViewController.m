//
//  PSLawViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLawViewController.h"
#import "PSBusinessConstants.h"
#import "PSPrisonerDetail.h"
#import "PSSessionManager.h"
#import "PSTipsConstants.h"
#import <AFNetworking/AFNetworking.h>
#import "XXEmptyView.h"
#import "UIView+Empty.h"
@interface PSLawViewController ()
@end

@implementation PSLawViewController
- (id)init {
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    NSString*prierid=prisonerDetail.prisonerId;
    NSString*newLawUrl=[[NSString alloc]init];
    if (prierid) {
        newLawUrl=[NSString stringWithFormat:@"%@&prisonerId=%@",LawUrl,prierid];
    } else {
         newLawUrl=[NSString stringWithFormat:@"%@&prisonerId=0",LawUrl];
    }
    NSLog(@"%@",newLawUrl);
    self = [super initWithURL:[NSURL URLWithString:newLawUrl]];
    if (self) {
        NSString*laws_regulations=NSLocalizedString(@"Laws and regulations", @"法律法规");
                self.enableUpdateTitle = NO;
                self.title = laws_regulations;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
