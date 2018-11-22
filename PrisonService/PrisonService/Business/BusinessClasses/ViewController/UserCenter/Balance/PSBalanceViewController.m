 //
//  PSBalanceViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBalanceViewController.h"
#import "PSBalanceTopView.h"
#import "PSAlertView.h"
#import "PSSessionManager.h"
#import "AccountsViewModel.h"
#import "Accounts.h"
#import "PSRefundViewController.h"
#import "PSRefundViewModel.h"
#import "PSTransactionRecordViewModel.h"
#import "PSBusinessConstants.h"

@interface PSBalanceViewController ()

@property (nonatomic, strong) PSBalanceTopView *balanceTopView;
@property (nonatomic,strong)  NSString*balanceSting;

@end

@implementation PSBalanceViewController
//- (id)init {
//    self = [super init];
//    if (self) {
//        self.title = @"我的余额";
//    }
//    return self;
//}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmRefundAction{
    PSRefundViewModel*refundViewModel=[[PSRefundViewModel alloc]init];
    [refundViewModel requestRefundCompleted:^(PSResponse *response) {
        if (response.code==200) {
           // [PSTipsView showTips:response.msg];
            [PSAlertView showWithTitle:@"退款成功" message:refundViewModel.msgData messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==0) {
                    [self requestBalance];
                }
            } buttonTitles:@"确定", nil];
        }
        else{
            [PSTipsView showTips:response.msg];
        }
    } failed:^(NSError *error) {
         [PSTipsView showTips:@"退款失败"];
    }];
}

//- (BOOL)hiddenNavigationBar{
//    return YES;
//}


- (void)refundAction {

    [PSAlertView showWithTitle:nil message:[NSString stringWithFormat:@"确定退款%.2f元",[self.balanceSting floatValue]] messageAlignment:NSTextAlignmentCenter image:[UIImage imageNamed:@"userCenterBalanceRefund"] handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex==1) {
            [self confirmRefundAction];//确定退款
        }
    } buttonTitles:@"取消",@"确定退款", nil];

    
}

-(void)requestBalance{
    [[PSLoadingView sharedInstance]show];
    [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
    AccountsViewModel*accountsModel=[[AccountsViewModel alloc]init];
    [accountsModel requestAccountsCompleted:^(PSResponse *response) {
        self.balanceTopView.balanceLabel.text = [NSString stringWithFormat:@"¥%.2f",[accountsModel.blance floatValue]];
        self.balanceSting=accountsModel.blance;
        [[PSLoadingView sharedInstance]dismiss];
        if ([accountsModel.blance floatValue]==0.00){
            [self.balanceTopView.refundButton setBackgroundImage:[UIImage imageNamed:@"universalButtongrayBg"] forState:UIControlStateNormal];
            self.balanceTopView.refundButton.userInteractionEnabled=NO;
  
        }
        else{
            [self.balanceTopView.refundButton setBackgroundImage:[UIImage imageNamed:@"universalButtonBg"] forState:UIControlStateNormal];
            self.balanceTopView.refundButton.userInteractionEnabled=YES;
        }
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance]dismiss];
        [PSTipsView showTips:@"获取余额失败"];
    }];
}

- (void)renderContents {
 
    self.balanceTopView = [PSBalanceTopView new];
    @weakify(self)
    [self.balanceTopView.refundButton bk_whenTapped:^{
        @strongify(self)
        [self refundAction];
    }];
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString* language = langArr.firstObject;
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        self.balanceTopView.refundButton.hidden=YES;
    }
    else{
        self.balanceTopView.refundButton.hidden=NO;
    }

    CGFloat topHeight = SCREEN_WIDTH * self.balanceTopView.topRate + SCREEN_WIDTH * self.balanceTopView.infoRate - 40;
    [self.view addSubview:self.balanceTopView];
    [self.balanceTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(topHeight);
    }];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"userCenterAccountBack"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44,40));
        make.top.mas_equalTo(StatusHeight);
    }];
    
    
    UIButton *balanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [balanceButton addTarget:self action:@selector(AccountDetails) forControlEvents:UIControlEventTouchUpInside];
    NSString*Account_details=NSLocalizedString(@"Account_details", @"账号明细");
    [balanceButton setTitle:Account_details forState:UIControlStateNormal];
    balanceButton.titleLabel.font=AppBaseTextFont2;
    balanceButton.titleLabel.numberOfLines=0;
    [self.view addSubview:balanceButton];
    [balanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.size.mas_equalTo(CGSizeMake(60,40));
        make.top.mas_equalTo(StatusHeight);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
     NSString*userCenterBalance=NSLocalizedString(@"userCenterBalance", @"我的余额");
    titleLabel.text = userCenterBalance;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backButton.mas_top);
        make.bottom.mas_equalTo(backButton.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(100);
    }];
}


-(void)AccountDetails{
    
    PSRefundViewController *refundViewController = [[PSRefundViewController alloc] initWithViewModel:[PSTransactionRecordViewModel new]];
    [self.navigationController pushViewController:refundViewController  animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
  
    [self requestBalance];
    [self renderContents];
 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(BOOL)hiddenNavigationBar {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    self.balanceSting=nil;
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
