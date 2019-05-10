//
//  PSSessionDeniedViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/9/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSSessionNoneViewController.h"
#import "PSRegisterViewController.h"
#import "PSRegisterViewModel.h"
#import "NSString+Date.h"
#import "PSLoginViewModel.h"
#import "PSSessionManager.h"
#import "PSAlertView.h"
#import "VIRegisterViewController.h"
#import "VIRegisterViewModel.h"
#import "PSContentManager.h"


@interface PSSessionNoneViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic , strong) NSString *subTitle;
@property (nonatomic , strong) NSString *titleSting;
@property (nonatomic , strong) NSString *btnTitle;
@property (nonatomic , strong) PSRegistration *RegistrationModel;
@property (nonatomic , strong) UIButton *operationButton ;
@end

@implementation PSSessionNoneViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestLoginStatus];
    NSString*userCenterAccreditation
    =NSLocalizedString(@"userCenterAccreditation", @"家属认证");
    self.title = userCenterAccreditation;
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)requestLoginStatus {
    
    PSLoginViewModel *loginViewModel =[[PSLoginViewModel alloc]init];
    [loginViewModel loginCompleted:^(PSResponse *response) {
        
        if (loginViewModel.session.registrations.count>0) {
          self.RegistrationModel=loginViewModel.session.registrations[0];
        }
        NSString*repalyTime=[self.RegistrationModel.createdAt timestampToDateString]?[self.RegistrationModel.createdAt timestampToDateString]:[[PSSessionManager sharedInstance].session.families.createdAt timestampToDateString];
        
        if ([loginViewModel.session.status isEqualToString:@"PENDING"]) {
            NSString*session_PENDING=NSLocalizedString(@"session_PENDING", @"待审核");
            NSString*session_PENDING_title=NSLocalizedString(@"session_PENDING_title", @"您于%@提交的认证申请正在审核,请耐心等待");
            _loginStatus = PSLoginPending;
            _titleSting=session_PENDING;
            _subTitle= [NSString stringWithFormat:session_PENDING_title,repalyTime];
            _btnTitle=@"";
        }
        else if ([loginViewModel.session.status isEqualToString:@"DENIED"]){
            _loginStatus=PSLoginDenied;
            NSString*session_DENIED=NSLocalizedString(@"session_DENIED", @"未通过");
            NSString*session_DENIED_title=NSLocalizedString(@"session_DENIED_title", @"您于%@提交的认证申请没有通过审核,请重新认证");
            NSString*session_DENIED_btntitle=NSLocalizedString(@"session_DENIED_btntitle", @"重新认证");
            
            _titleSting=session_DENIED;
            _subTitle= [NSString stringWithFormat:session_DENIED_title,repalyTime];
            _btnTitle=session_DENIED_btntitle;
            //没有时间,从未认证
            if (!repalyTime) {
                NSString*session_NONE=NSLocalizedString(@"session_NONE", @"未认证");
                NSString*session_NONE_title=NSLocalizedString(@"session_NONE_title", @"您还未进行家属认证");
                NSString*session_NONE_btntitle=NSLocalizedString(@"session_NONE_btntitle", @"马上认证");
                _titleSting=session_NONE;
                _subTitle = session_NONE_title;
                _btnTitle=session_NONE_btntitle;
            }
            
        }
        else if ([loginViewModel.session.status isEqualToString:@"PASSED"]){
            _loginStatus = PSLoginPassed;
            NSString*session_PASSED=NSLocalizedString(@"session_PASSED", @"已认证");
            _titleSting=session_PASSED;
        }
        else{
            _loginStatus=PSLoginNone;
            NSString*session_NONE=NSLocalizedString(@"session_NONE", @"未认证");
            NSString*session_NONE_title=NSLocalizedString(@"session_NONE_title", @"您还未进行家属认证");
            NSString*session_NONE_btntitle=NSLocalizedString(@"session_NONE_btntitle", @"马上认证");
            _titleSting=session_NONE;
            _subTitle = session_NONE_title;
            _btnTitle=session_NONE_btntitle;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self renderContents];
        });
    } failed:^(NSError *error) {
        [self showNetError:error];
    }];
    
}


- (void)renderContents {

    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString*language = langArr.firstObject;
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-CN"]||[language isEqualToString:@"vi-VN"]) {
        
    }
    else{
        
    }
    CGFloat LableWidth = 150;//150
    CGFloat horSpace = 20;
    _titleLabel = [UILabel new];
    _titleLabel.font = AppBaseTextFont1;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = AppBaseTextColor1;
    _titleLabel.text = _titleSting;
    [self.view addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(LableWidth);
        make.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.view);
    }];
    
    if ([self.RegistrationModel.status isEqualToString:@"PASSED"]||[PSSessionManager sharedInstance].loginStatus == PSLoginPassed) {
            _loginStatus = PSLoginPassed;
            NSString*session_PASSED=NSLocalizedString(@"session_PASSED", @"已认证");
            _titleSting=session_PASSED;
            _subTitle=@"";
        UIButton*passedIcon=[[UIButton alloc]init];
        [passedIcon setImage:[UIImage imageNamed:@"certifiedIcon"] forState:UIControlStateNormal];
        [self.view addSubview:passedIcon];
        
        [passedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_titleLabel.mas_right);
            make.width.height.mas_equalTo(16);
            make.centerY.mas_equalTo(self.view);
        }];
    }
    
    _subTitleLabel = [UILabel new];
    _subTitleLabel.font = AppBaseTextFont2;
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    _subTitleLabel.textColor = AppBaseTextColor2;
    _subTitleLabel.numberOfLines=0;
   _subTitleLabel.text = _subTitle;
    [self.view addSubview:_subTitleLabel];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSpace);
        make.right.mas_equalTo(-horSpace);
        make.height.mas_equalTo(34);
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(6);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sessionPendingIcon"]];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(_titleLabel.mas_top).offset(-35);
        make.size.mas_equalTo(imageView.frame.size);
    }];
    
    CGFloat btWidth = 100; //89
    CGFloat btHeight = 40; //34
    _operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _operationButton.layer.borderWidth = 1.0;
    _operationButton.layer.borderColor = AppBaseTextColor1.CGColor;
    _operationButton.layer.cornerRadius = btHeight / 2;
    _operationButton.titleLabel.font = AppBaseTextFont1;
    [_operationButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    [_operationButton setTitle:_btnTitle forState:UIControlStateNormal];
    if ([_btnTitle isEqualToString:@""]||!_btnTitle) {
        _operationButton.hidden = YES;
    } else {
        _operationButton.hidden = NO;
    }

    @weakify(self)
    [_operationButton bk_whenTapped:^{
        @strongify(self)
        [self actionForRegister];
    }];
    [self.view addSubview:_operationButton];
    [_operationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_subTitleLabel.mas_bottom).offset(44);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(btWidth);
        make.height.mas_equalTo(btHeight);
    }];
    _operationButton.titleLabel.numberOfLines=0;
    
    if ([self.RegistrationModel.status isEqualToString:@"PENDING"]||[self.RegistrationModel.status isEqualToString:@"PASSED"]||[PSSessionManager sharedInstance].loginStatus == PSLoginPassed) {
        _operationButton.hidden=YES;
    }
}

- (UIImage *)leftItemImage {
    return [UIImage imageNamed:@"universalBackIcon"];
}

-(void)actionForRegister{
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString*language = langArr.firstObject;
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-CN"]||[language isEqualToString:@"vi-VN"]) {
        VIRegisterViewController *registerViewController = [[VIRegisterViewController alloc] initWithViewModel:[[VIRegisterViewModel alloc] init]];
        [registerViewController setCallback:^(BOOL successful, id session) {
            if (self.callback) {
                self.callback(successful,session);
            }
        }];
        [self.navigationController pushViewController:registerViewController animated:YES];
    }
    else{
        [SDTrackTool logEvent:CLICK_GO_AUTH];
        PSRegisterViewController *registerViewController = [[PSRegisterViewController alloc] initWithViewModel:[[PSRegisterViewModel alloc] init]];
        [registerViewController setCallback:^(BOOL successful, id session) {
            if (self.callback) {
                self.callback(successful,session);
            }
        }];
        [self.navigationController pushViewController:registerViewController animated:YES];
    }
    
}


- (IBAction)actionOfLeftItem:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (_loginStatus!=[PSSessionManager sharedInstance].loginStatus) {
        if (_loginStatus==PSLoginDenied) {
            [PSAlertView showWithTitle:@"温馨提示" message:@"您的家属认证申请已被撤回,请重新登录,授权认证!" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==0) {
                    [[PSSessionManager sharedInstance]doLogout];
                }
            } buttonTitles:@"确定", nil];
        }
        if (_loginStatus==PSLoginPassed) {
            [PSSessionManager sharedInstance].loginStatus=PSLoginPassed;
            [[PSContentManager sharedInstance]launchContent];
//            [PSAlertView showWithTitle:@"温馨提示" message:@"您的家属认证申请已通过,请重新登录!" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
//                if (buttonIndex==1) {
//                    [[PSSessionManager sharedInstance]doLogout];
//                }
//            } buttonTitles:@"取消",@"确定", nil];
        }
   
    }
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

- (void)initialize {
    
}

@end
