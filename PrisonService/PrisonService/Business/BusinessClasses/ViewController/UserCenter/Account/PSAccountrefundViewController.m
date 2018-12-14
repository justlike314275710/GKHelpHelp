//
//  PSAccountrefundViewController.m
//  PrisonService
//
//  Created by kky on 2018/11/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAccountrefundViewController.h"
#import "PSAlertView.h"
#import "PSRefundViewModel.h"
#import "AccountsViewModel.h"
#import "PSBusinessConstants.h"
@interface PSAccountrefundViewController ()
@property (nonatomic, strong)UILabel *babalance;
@property (nonatomic, strong)UILabel *refundLab;
@property (nonatomic, strong)UIButton *refund;
@property (nonatomic,strong)NSString *balanceSting;

@end

@implementation PSAccountrefundViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"余额退款";
    [self requestBalance];
    [self p_setUI];
}

- (void)p_setUI {
    
    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(25, 30, SCREEN_WIDTH-50, 154)];
    bgImg.image = [UIImage imageNamed:@"矩形 45"];
    [self.view addSubview:bgImg];
    
    UILabel *keyBalanceLab = [[UILabel alloc] initWithFrame:CGRectMake((bgImg.width-100)/2, 20, 100, 20)];
    keyBalanceLab.text = @"当前余额";
    keyBalanceLab.textAlignment = NSTextAlignmentCenter;
    keyBalanceLab.textColor = [UIColor whiteColor];
    keyBalanceLab.font = FontOfSize(12);
    [bgImg addSubview:keyBalanceLab];
    
    _babalance = [[UILabel alloc] initWithFrame:CGRectMake((bgImg.width-200)/2, keyBalanceLab.bottom+5, 200, 40)];
    _babalance.text = [NSString stringWithFormat:@"%.2f",[self.balanceSting floatValue]];
    _babalance.textAlignment = NSTextAlignmentCenter;
    _babalance.textColor = [UIColor whiteColor];
    _babalance.font = FontOfSize(38);
    [bgImg addSubview:_babalance];
    
    UILabel *k_refundLab = [[UILabel alloc] initWithFrame:CGRectMake(25,bgImg.bottom, 100, 20)];
    k_refundLab.text = @"退款金额";
    k_refundLab.textAlignment = NSTextAlignmentLeft;
    k_refundLab.textColor = UIColorFromRGB(102, 102, 102);
    k_refundLab.font = FontOfSize(12);
    [self.view addSubview:k_refundLab];
    
    _refundLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-125,bgImg.bottom, 100, 20)];
    _refundLab.text = [NSString stringWithFormat:@"%.2f",[self.balanceSting floatValue]];
    _refundLab.textAlignment = NSTextAlignmentRight;
    _refundLab.textColor = UIColorFromRGB(102, 102, 102);
    _refundLab.font = FontOfSize(12);
    [self.view addSubview:_refundLab];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25, k_refundLab.bottom+5, SCREEN_WIDTH-50, 1)];
    line.backgroundColor = UIColorFromRGB(234, 235, 238);
    [self.view addSubview:line];
    
    UILabel *k_accountDetail = [[UILabel alloc] initWithFrame:CGRectMake(25,line.bottom+5, 100, 20)];
    k_accountDetail.text = @"交易明细";
    k_accountDetail.textAlignment = NSTextAlignmentLeft;
    k_accountDetail.textColor = UIColorFromRGB(102, 102, 102);
    k_accountDetail.font = FontOfSize(12);
    [self.view addSubview:k_accountDetail];
    
    UILabel *accountDetail = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-125,line.bottom+5, 100, 20)];
    accountDetail.text = @"原路返回";
    accountDetail.textAlignment = NSTextAlignmentRight;
    accountDetail.textColor = UIColorFromRGB(102, 102, 102);
    accountDetail.font = FontOfSize(12);
    [self.view addSubview:accountDetail];
    
    UIView*bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, accountDetail.bottom+5, SCREEN_WIDTH, SCREEN_HEIGHT-accountDetail.bottom-64-2)];
    bottomView.backgroundColor = UIColorFromRGB(234, 235, 238);
    [self.view addSubview:bottomView];
    
    UILabel *k_tkLab = [[UILabel alloc] initWithFrame:CGRectMake(25,5, 100, 20)];
    k_tkLab.text = @"退款说明";
    k_tkLab.textAlignment = NSTextAlignmentLeft;
    k_tkLab.textColor = UIColorFromRGB(102, 102, 102);
    k_tkLab.font = FontOfSize(12);
    [bottomView addSubview:k_tkLab];
    
    UILabel *tkLab = [[UILabel alloc] initWithFrame:CGRectMake(25,k_tkLab.bottom,SCREEN_WIDTH-50,80)];
    tkLab.text = @"1、通过支付宝或微信支付充值，1年内可申请退款原路退回，不收取手续费；\n2、超过1年申请退款,平台自动扣除手续费0.06%,且用户需提供支付宝账号,系统以转账形式，将余额退回到用户支付宝账号中。";
    tkLab.textAlignment = NSTextAlignmentLeft;
    tkLab.textColor = UIColorFromRGB(153,153,153);
    tkLab.font = FontOfSize(10);
    tkLab.numberOfLines = 0;
    [bottomView addSubview:tkLab];
    
    _refund = [UIButton buttonWithType:UIButtonTypeCustom];
    _refund.backgroundColor = UIColorFromRGB(100,140,214);
    _refund.frame = CGRectMake(15,SCREEN_HEIGHT-64-64, SCREEN_WIDTH-30, 44);
    _refund.layer.cornerRadius = 2.0f;
    [_refund setTitle:@"申请退款" forState:UIControlStateNormal];
    [_refund bk_whenTapped:^{
        if ([self.balanceSting floatValue]==0) {
             [PSTipsView showTips:@"当前没有可退款金额！"];
            return ;
        }
        [_refund setEnabled:NO];
        
        [PSAlertView showWithTitle:nil message:[NSString stringWithFormat:@"确定退款%.2f元",[self.balanceSting floatValue]] messageAlignment:NSTextAlignmentCenter image:[UIImage imageNamed:@"userCenterBalanceRefund"] handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex==1) {
                [self confirmRefundAction];//确定退款
                //禁掉按钮点击时间
            } else {
                [_refund setEnabled:YES];
            }
        } buttonTitles:@"取消",@"确定退款", nil];
    }];
    [self.view addSubview:_refund];
    
}

-(void)confirmRefundAction {
    
    PSRefundViewModel*refundViewModel=[[PSRefundViewModel alloc]init];
    [refundViewModel requestRefundCompleted:^(PSResponse *response) {
         [_refund setEnabled:YES];
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
        [_refund setEnabled:YES];
        
    }];
}

-(void)requestBalance{
    [[PSLoadingView sharedInstance]show];
    [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
    AccountsViewModel*accountsModel=[[AccountsViewModel alloc]init];
    @weakify(self);
    [accountsModel requestAccountsCompleted:^(PSResponse *response) {
        @strongify(self);
        self.balanceSting=accountsModel.blance;
        self.refundLab.text = [NSString stringWithFormat:@"%.2f",[self.balanceSting floatValue]];
        self.babalance.text = [NSString stringWithFormat:@"%.2f",[self.balanceSting floatValue]];
        if (self.refundBlock) {
            self.refundBlock(accountsModel.blance);
        }
        [[PSLoadingView sharedInstance]dismiss];
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance]dismiss];
        [PSTipsView showTips:@"获取余额失败"];
    }];
}



@end
