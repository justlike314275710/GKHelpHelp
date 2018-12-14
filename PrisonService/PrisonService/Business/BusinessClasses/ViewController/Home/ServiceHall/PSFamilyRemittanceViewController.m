//
//  PSFamilyRemittanceViewController.m
//  PrisonService
//
//  Created by kky on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFamilyRemittanceViewController.h"
#import "PSREmittanceRecodeViewController.h"
#import "PSRemittancePayStateViewController.h"
#import "PSSeleView.h"
#import "PSHomeViewModel.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"
#import "PSUserSession.h"
#import "PSCache.h"
#import "PSPayInfo.h"
#import "PSSessionManager.h"
#import "PSPayCenter.h"
#import "PSFamilyRemittanceViewModel.h"
#import "PSRemittanceRecodeViewModel.h"

@interface PSFamilyRemittanceViewController ()<UITextFieldDelegate>

@property(nonatomic, strong) UILabel *nameLab;
@property(nonatomic, strong) UITextField *amountField;
@property(nonatomic, strong) UIView *wxPayView;
@property(nonatomic, strong) UIView *aliPayView;
@property(nonatomic, strong) UIImageView *aliIconStateImg;
@property(nonatomic, strong) UIImageView *wxIconStateImg;
@property(nonatomic, strong) PSSeleView *seleView;
@property(nonatomic, strong) NSArray<PSPrisonerDetail *> *prisoners;
@property(nonatomic, strong) PSPrisonerDetail *prisoner;
@property(nonatomic, strong) NSString *payWay;
@property(nonatomic, assign) NSInteger index;

@end

@implementation PSFamilyRemittanceViewController

#pragma mark - CycleLife
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString * remittance=NSLocalizedString(@"family_remittance", @"家属汇款");
        self.title = remittance;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(248, 247, 254);
    NSString*title=NSLocalizedString(@"remittance_record", @"汇款记录");
    [self createRightBarButtonItemWithTarget:self action:@selector(remittanceRecord) title:title];
    [self p_initData];
    [self p_setUI];
}

#pragma mark - PrivateMethods

- (void)p_setUI {
    
    UIView *memberView = [UIView new];
    memberView.backgroundColor = [UIColor whiteColor];
    memberView.layer.masksToBounds = YES;
    memberView.layer.cornerRadius = 4;
    [self.view addSubview:memberView];
    @weakify(self);
    [memberView bk_whenTapped:^{
        @strongify(self);
        [self selectMember];
    }];
    [memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(50);
    }];

    UIImageView *headImg = [UIImageView new];
    headImg.image = [UIImage imageNamed:@"head"];
    [memberView addSubview:headImg];
    [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(30);
    }];
    [memberView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(64);
        make.centerY.mas_equalTo(memberView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(250);
    }];
    UIImageView *arrowImg = [UIImageView new];
    arrowImg.image = [UIImage imageNamed:@"icon-arrow1"];
    [memberView addSubview:arrowImg];
    [arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(11);
        make.width.mas_equalTo(6);
    }];
    
    UIView *amountView = [UIView new];
    amountView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:amountView];
    [amountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(memberView.mas_bottom).offset(15);
        make.height.mas_equalTo(90);
    }];
    UILabel *hklabel = [UILabel new];
    NSString *hktext =NSLocalizedString(@"remittance_amount", @"汇款金额");
    hklabel.text = hktext;
    hklabel.font = FontOfSize(12);
    hklabel.textColor = UIColorFromRGB(51, 51, 51);
    [amountView addSubview:hklabel];
    [hklabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(150);
    }];
    
    UILabel *fhlabel = [UILabel new];
    fhlabel.text = @"¥";
    fhlabel.font = FontOfSize(24);
    fhlabel.textColor = UIColorFromRGB(51, 51, 51);
    [amountView addSubview:fhlabel];
    [fhlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
    }];
    [amountView addSubview:self.amountField];
    [self.amountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(fhlabel.mas_right).offset(10);
        make.height.centerY.mas_equalTo(fhlabel);
        make.width.mas_equalTo(300);
        
    }];
    
    UIView *payWayView = [UIView new];
    payWayView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:payWayView];
    [payWayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(amountView.mas_bottom).offset(10);
        make.height.mas_equalTo(100);
    }];
    
    [payWayView addSubview:self.aliPayView];
    [self.aliPayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    UIImageView *alIconImg = [UIImageView new];
    alIconImg.image = [UIImage imageNamed:@"aliicon"]; //wxicon
    [self.aliPayView addSubview:alIconImg];
    [alIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.width.height.mas_equalTo(25);
    }];
    UILabel *alLab = [UILabel new];
    NSString *alLabtext =NSLocalizedString(@"alipay_payment", @"支付宝支付");
    alLab.text = alLabtext;
    alLab.font = FontOfSize(14);
    alLab.textAlignment = NSTextAlignmentLeft;
    alLab.textColor = UIColorFromRGB(45, 45, 45);
    [self.aliPayView addSubview:alLab];
    [alLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(55);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(alIconImg);
    }];

    [self.aliPayView addSubview:self.aliIconStateImg];
    [self.aliIconStateImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(15);
        make.centerY.mas_equalTo(alLab);
    }];
    
    [payWayView addSubview:self.wxPayView];
    [self.wxPayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    UIImageView *wxIconImg = [UIImageView new];
    wxIconImg.image = [UIImage imageNamed:@"wxicon"]; //wxicon
    [self.wxPayView addSubview:wxIconImg];
    [wxIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(5);
        make.width.height.mas_equalTo(25);
    }];
    UILabel *wxLab = [UILabel new];
    NSString *wxLabtext =NSLocalizedString(@"weChat_payment", @"微信支付");
    wxLab.text = wxLabtext;
    wxLab.font = FontOfSize(14);
    wxLab.textAlignment = NSTextAlignmentLeft;
    wxLab.textColor = UIColorFromRGB(45, 45, 45);
    [self.wxPayView addSubview:wxLab];
    [wxLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(55);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(wxIconImg);
    }];
    [self.wxPayView addSubview:self.wxIconStateImg];
    [self.wxIconStateImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(15);
        make.centerY.mas_equalTo(wxLab);
    }];
    
    UIButton *remittanceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *remittanceBtnText =NSLocalizedString(@"immediate_remittance", @"立即汇款");
    [remittanceBtn setTitle:remittanceBtnText forState:UIControlStateNormal];
    remittanceBtn.titleLabel.font = FontOfSize(14);
    [remittanceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    remittanceBtn.backgroundColor = UIColorFromRGB(100,140,214);
    remittanceBtn.layer.masksToBounds = YES;
    remittanceBtn.layer.cornerRadius = 4;
    [self.view addSubview:remittanceBtn];
    [remittanceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(44);
    }];
    [remittanceBtn bk_whenTapped:^{
        @strongify(self);
        PSFamilyRemittanceViewModel *RemittanceViewModel = (PSFamilyRemittanceViewModel *)self.viewModel;
        RemittanceViewModel.money = self.amountField.text;
        [RemittanceViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
            if (successful) {
                [self immediatelyPay];
            }else{
                [PSTipsView showTips:tips];
            }
        }];
    }];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0,0,0,0));
    }];
    
    UIImageView *bgImg = [UIImageView new];
    [bgView addSubview:bgImg];
    bgImg.image = [UIImage R_imageNamed:@"敬请期待图"];
    bgImg.contentMode = UIViewContentModeScaleAspectFit;
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.centerY.mas_equalTo(bgView);
        make.top.mas_equalTo(104);
        make.width.mas_equalTo(315);
        make.height.mas_equalTo(225);
    }];
}

- (void)p_initData {
    //绑定的服刑人员
    self.payWay = @"ALIPAY";
    PSFamilyRemittanceViewModel *RemittanceViewModel = (PSFamilyRemittanceViewModel *)self.viewModel;
    NSArray *datalist = RemittanceViewModel.criminals;
     _index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    self.prisoners = datalist;
    if (self.prisoners.count > _index) {
       self.prisoner = [datalist objectAtIndex:_index];
    }
}

- (void)p_showPayResult:(PayState)state PSPayInfo:(PSPayInfo *)info {
    PSRemittancePayStateViewController *payStateVC = [[PSRemittancePayStateViewController alloc] init];
    @weakify(self)
    payStateVC.completeBlock = ^(PayState state) {
        @strongify(self);
        if (state == payScuess) {
            [self remittanceRecord];
        }
    };
    payStateVC.info = info;
    payStateVC.state = state;
    payStateVC.prisoner = self.prisoner;
    [self.navigationController presentViewController:payStateVC animated:YES completion:nil];
}
#pragma mark - TouchEvent
- (void)remittanceRecord {
    PSREmittanceRecodeViewController *RecodeViewController = [[PSREmittanceRecodeViewController alloc] initWithViewModel:[PSRemittanceRecodeViewModel new]];
    [self.navigationController pushViewController:RecodeViewController animated:YES];
}

- (void)selectMember {
    [self.amountField resignFirstResponder];
    if (self.prisoners.count > 0) [self.seleView showView];
}

- (void)immediatelyPay {
    
    PSPayInfo *payInfo = [PSPayInfo new];
    payInfo.familyId = [PSSessionManager sharedInstance].session.families.id;
    payInfo.jailId = self.prisoner.jailId;
    payInfo.money = self.amountField.text;
    payInfo.payment = self.payWay;
    payInfo.prisonerId = self.prisoner.prisonerId;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [[PSPayCenter payCenter] goPayWithPayInfo:payInfo type:PayTypeRem callback:^(BOOL result, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
            [[PSSessionManager sharedInstance] synchronizeUserBalance];
        });
        if (error) {
            if (error.code != 106 && error.code != 206) {
                if (error.code == 202 ||error.code == 205||error.code == 102) { //输入金额不正确 (202)  系统错误(支付宝返回205)   未安装微信（202）
                    [PSTipsView showTips:error.domain dismissAfterDelay:1];
                } else { //可能点击取消返回
                    [self p_showPayResult:payCancel PSPayInfo:payInfo];
                }
            } else {
                [self p_showPayResult:payFailure PSPayInfo:payInfo];
            }
        }else{
                [self p_showPayResult:payScuess PSPayInfo:payInfo];
        }
    }];
}

- (void)wxPay{
    self.wxIconStateImg.image = [UIImage imageNamed:@"支付已勾选"];
    self.aliIconStateImg.image = [UIImage imageNamed:@"支付未勾选"];
    self.payWay = @"WEIXIN";
}
- (void)aliPay {
    self.aliIconStateImg.image = [UIImage imageNamed:@"支付已勾选"];
    self.wxIconStateImg.image = [UIImage imageNamed:@"支付未勾选"];
    self.payWay = @"ALIPAY";
}

#pragma mark - Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //    限制只能输入数字
    BOOL isHaveDian = YES;
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    if ([textField.text rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {//数据格式正确
            
            if([textField.text length] == 0){
                if(single == '.') {
                    NSString *tip = NSLocalizedString(@"Incorrect data format",@"数据格式有误");
                    [PSTipsView showTips:tip];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian = YES;
                    return YES;
                    
                }else{
                    NSString *tip = NSLocalizedString(@"Incorrect data format",@"数据格式有误");
                    [PSTipsView showTips:tip];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    //判断小数点的位数
                    NSRange ran = [textField.text rangeOfString:@"."];
                    if (range.location - ran.location <= 2) {
                        return YES;
                    }else{
                        NSString *tip = NSLocalizedString(@"Up to two decimal places",@"最多两个小数");
                        [PSTipsView showTips:tip];
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{
            NSString *tip = NSLocalizedString(@"Incorrect data format",@"数据格式有误");
            [PSTipsView showTips:tip];
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    else
    {
        return YES;
    }
}


#pragma mark - Setting&Getting
- (PSSeleView *)seleView {
    if (!_seleView) {
        _seleView = [[PSSeleView alloc] initWithFrame:CGRectZero dataList:self.prisoners index:_index];
        @weakify(self);
        _seleView.firmSelecteBlock = ^(NSInteger index) {
            @strongify(self);
            self.nameLab.text = [self.prisoners objectAtIndex:index].name;
            self.prisoner = [self.prisoners objectAtIndex:index];
        };
    }
    return _seleView;
}

-(UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [UILabel new];
        if (self.prisoners.count > _index) {
          _nameLab.text = self.prisoners[_index].name;
        }
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.textColor = UIColorFromRGB(51, 51, 51);
        _nameLab.font = FontOfSize(14);
    }
    return _nameLab;
}

- (UITextField *)amountField {
    if (!_amountField) {
        _amountField = [[UITextField alloc] init];
        _amountField.font = FontOfSize(24);
        NSString *placeholder =NSLocalizedString(@"please_enter_remittance_amount", @"请输入汇款金额");
        _amountField.placeholder = placeholder;
        _amountField.textColor = UIColorFromRGB(51, 51, 51);
        _amountField.keyboardType =  UIKeyboardTypeDecimalPad; //UIKeyboardTypeNumberPad
        _amountField.delegate = self;
    }
    return _amountField;
}

- (UIView *)wxPayView {
    if (!_wxPayView) {
        _wxPayView = [UIView new];
        @weakify(self);
        [_wxPayView bk_whenTapped:^{
            @strongify(self);
            [self wxPay];
        }];
    }
    return _wxPayView;
}

- (UIImageView *)aliIconStateImg {
    if (!_aliIconStateImg) {
        _aliIconStateImg = [UIImageView new];
        _aliIconStateImg.image = [UIImage imageNamed:@"支付已勾选"];
    }
    return _aliIconStateImg;
}

- (UIImageView *)wxIconStateImg {
    if (!_wxIconStateImg) {
        _wxIconStateImg = [UIImageView new];
        _wxIconStateImg.image = [UIImage imageNamed:@"支付未勾选"];
    }
    return _wxIconStateImg;
}

- (UIView *)aliPayView {
    if (!_aliPayView) {
        _aliPayView = [UIView new];
         @weakify(self);
        [_aliPayView bk_whenTapped:^{
            @strongify(self);
            [self aliPay];
        }];
    }
    return _aliPayView;
}

- (NSArray<PSPrisonerDetail *>*)prisoners {
    if (!_prisoners) {
        _prisoners = [NSArray array];
    }
    return _prisoners;
}

@end
