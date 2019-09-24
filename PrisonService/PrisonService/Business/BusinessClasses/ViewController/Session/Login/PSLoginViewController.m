//
//  PSLoginViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLoginViewController.h"
#import "PSLoginBackgroundView.h"
#import "PSRegisterViewController.h"
#import "PSLoginTopView.h"
#import "PSLoginMiddleView.h"
#import "PSPreLoginViewModel.h"
#import "PSRegisterViewModel.h"
#import "PSCountdownManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MJExtension.h"
#import "PSUUIDs.h"
#import "ZJBLStoreShopTypeAlert.h"
#import "PSSessionManager.h"
#import "PSVisitorViewController.h"
#import "PSchangPhoneViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "PSSessionPendingController.h"
#import "PSEcomRegisterViewmodel.h"
#import "PSEcomLoginViewmodel.h"
#import "PSAlertView.h"
#import "VIRegisterViewController.h"
#import "VIRegisterViewModel.h"
#import "VIProLoginViewModel.h"
#import "PSContentManager.h"
#import "NSString+Date.h"
#import "PSVistorHomeViewController.h"
#import "PSHomeViewModel.h"
#import <YYText/YYText.h>
#import "PSProtocolViewController.h"
#import "PSAuthenticationMainViewController.h"
#import "PSContentManager.h"
#import "NSObject+version.h"
typedef NS_ENUM(NSInteger, PSLoginModeType) {
    PSLoginModeCode,
    PSLoginModePassword,
};
@interface PSLoginViewController ()<PSCountdownObserver,UIAlertViewDelegate>
@property (nonatomic ,assign) PSLoginModeType loginModeType;
@property (nonatomic ,strong) NSString *mode;
@property (nonatomic, strong) PSLoginMiddleView *loginMiddleView;
@property (nonatomic , strong) UIButton *loginTypeButton ;
@property (nonatomic , strong) UIButton *publicTypeButton ;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, strong) NSMutableArray*titles;
@property (nonatomic ,strong) NSMutableArray *token;
@property (nonatomic ,strong) NSString *language ;
@property (nonatomic ,assign) NSInteger RefreshCode;
@property (nonatomic, strong) YYLabel *protocolLabel;
@property (nonatomic, strong, readonly) UIViewController *rootViewController;
@end

@implementation PSLoginViewController
#pragma mark  - setter & getter
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
        self.loginModeType=PSLoginModeCode;
        self.mode=@"sms_verification_code";
    }
    return self;
}

- (void)dealloc {
    [[PSCountdownManager sharedInstance] removeObserver:self];
}

#pragma mark -- 注册
- (IBAction)actionOfRegister:(id)sender {

    if ([_language isEqualToString:@"vi-US"]||[_language isEqualToString:@"vi-CN"]||[_language isEqualToString:@"vi-VN"]) {
        VIRegisterViewController *registerViewController = [[VIRegisterViewController alloc] initWithViewModel:[[VIRegisterViewModel alloc] init]];
        [registerViewController setCallback:^(BOOL successful, id session) {
            if (self.callback) {
                self.callback(successful,session);
            }
        }];
        [self.navigationController pushViewController:registerViewController animated:YES];
    }
    else{
    PSRegisterViewController *registerViewController = [[PSRegisterViewController alloc] initWithViewModel:[[PSRegisterViewModel alloc] init]];
    [registerViewController setCallback:^(BOOL successful, id session) {
        if (self.callback) {
            self.callback(successful,session);
        }
    }];
    [self.navigationController pushViewController:registerViewController animated:YES];
    }
}

#pragma mark -- 验证登陆
- (void)logInAction {
    [[PSLoadingView sharedInstance] show];
    PSLoginViewModel *loginViewModel =(PSLoginViewModel *)self.viewModel;
    @weakify(self)
    @weakify(loginViewModel)
    [loginViewModel loginCompleted:^(PSResponse *response) {
        @strongify(self)
        @strongify(loginViewModel)
        //[LXFileManager removeUserDataForkey:@"phoneNumber"];
        [LXFileManager saveUserData:loginViewModel.phoneNumber forKey:@"phoneNumber"];
        //去除游客状态
        [LXFileManager removeUserDataForkey:@"isVistor"];
   
        [[PSLoadingView sharedInstance] dismiss];
        if (loginViewModel.code == 200) {
            if (self.callback) {
                self.callback(YES,loginViewModel.session);
            }
        }
       else if (loginViewModel.code==400) {
            [[PSLoadingView sharedInstance]dismiss];
          if (self.callback&&loginViewModel.session.account) {
              self.callback(YES,loginViewModel.session);
          }
//           [[PSContentManager sharedInstance]launchContent];
        }
       else{
            [PSTipsView showTips:loginViewModel.message? loginViewModel.message : @"登录失败"];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}


#pragma mark -- 授权注册登陆 刷新token
- (void)checkDataIsEmpty {
     [self.view endEditing:YES];
    PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;
    @weakify(self)
    [loginViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            if ([_language isEqualToString:@"vi-US"]||[_language isEqualToString:@"vi-VN"]||[_language isEqualToString:@"vi-CN"]) {
                [self EcommerceOfVietnamRegister];
            }
            else{
                if (self.loginModeType==PSLoginModePassword) {
                     [self EcommerceOfLogin];
                }
                if (self.loginModeType==PSLoginModeCode){
                     [self EcommerceOfRegister];
                }
           
            }
        }else{
            [PSTipsView showTips:tips];
        }
    }];
}


#pragma mark - 登录
-(void)EcommerceOfRegister{
    
    PSEcomRegisterViewmodel*ecomRegisterViewmodel=[[PSEcomRegisterViewmodel alloc]init];
    @weakify(self)
    ecomRegisterViewmodel.phoneNumber=self.loginMiddleView.phoneTextField.text;
    ecomRegisterViewmodel.verificationCode=self.loginMiddleView.codeTextField.text;
    [ecomRegisterViewmodel requestEcomRegisterCompleted:^(PSResponse *response) {
        @strongify(self)
        if (ecomRegisterViewmodel.statusCode==201) {
            [self EcommerceOfLogin];
        }
        else {
            NSString*account_code_error=NSLocalizedString(@"account_code_error", nil);
            [PSTipsView showTips:account_code_error];
            
        }
    } failed:^(NSError *error) {
        @strongify(self)
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSString*code=body[@"code"];
        if ([code isEqualToString:@"user.PhoneNumberExisted"]) {
            [self EcommerceOfLogin];
        } else if([code isEqualToString:@"user.SmsVerificationCodeNotMatched"]) {
            [PSTipsView showTips:@"验证码错误"];
        } else if ([code isEqualToString:@"user.password.NotMatched"]){
            NSString*account_error=NSLocalizedString(@"account_error", nil);
            [PSTipsView showTips:account_error];
        }
        else if ([code isEqualToString:@"sms.verification-code.NotMatched"]){
            [PSTipsView showTips:@"验证码错误"];
        }
        else if ([code isEqualToString:@"unauthorized"]){
            [PSTipsView showTips:@"账号不存在"];
        }
        else if ([code isEqualToString:@"user.group.NotMatched"]){
            [PSTipsView showTips:@"账号不属于该群组"];
        }
        else if ([code isEqualToString:@"invalid_grant"]){
            [PSTipsView showTips:@"账号已禁用"];
        }
        else {
            [self showNetError:error];
        }
    }];
}
//越南版注册
-(void)EcommerceOfVietnamRegister{
    
    PSEcomRegisterViewmodel*ecomRegisterViewmodel=[[PSEcomRegisterViewmodel alloc]init];
    @weakify(self)
    ecomRegisterViewmodel.phoneNumber=self.loginMiddleView.phoneTextField.text;
    ecomRegisterViewmodel.verificationCode=self.loginMiddleView.codeTextField.text;
    [ecomRegisterViewmodel requestVietnamEcomRegisterCompleted:^(PSResponse *response) {
        @strongify(self)
        if (ecomRegisterViewmodel.statusCode==201) {
            [self EcommerceOfLogin];
        }
        else {
            NSString*account_code_error=NSLocalizedString(@"account_code_error", nil);
            [PSTipsView showTips:account_code_error];
            
        }
    } failed:^(NSError *error) {
        @strongify(self)
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (data) {
            id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString*message=body[@"message"];
            if (message) {
                [PSTipsView showTips:message];
            } else {
                [self showNetError:error];
            }
        }
        else{
            [self showInternetError];
        }
    }];
}


-(void)EcommerceOfLogin{
    PSEcomLoginViewmodel*ecomViewmodel=[[PSEcomLoginViewmodel alloc]init];
    ecomViewmodel.username=self.loginMiddleView.phoneTextField.text;
    ecomViewmodel.password=self.loginMiddleView.codeTextField.text;
    ecomViewmodel.loginMode=self.mode;
    @weakify(ecomViewmodel)
    @weakify(self)
    [ecomViewmodel postEcomLogin:^(PSResponse *response) {
        @strongify(ecomViewmodel)
        @strongify(self)
        if (ecomViewmodel.statusCode==200) {
            [ecomViewmodel loginGetImifnoComplete:^(PSResponse *response) {
                [self logInAction];
            } failed:^(NSError *error) {
                NSString*account_code_error=NSLocalizedString(@"account_code_error", nil);
                [PSTipsView showTips:account_code_error];
            }];
        }
        else {
            NSString*account_code_error=NSLocalizedString(@"account_code_error", nil);
            [PSTipsView showTips:account_code_error];
        }

    } failed:^(NSError *error) {
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (data) {
            id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString*message=body[@"message"];
            if (message) {
                [PSTipsView showTips:message];
            } else {
                [self showNetError:error];
            }
        }
    }];

}



#pragma mark - 游客模式
-(void)actionforVistor{
    
    if ([_language isEqualToString:@"vi-US"]||[_language isEqualToString:@"vi-VN"]||[_language isEqualToString:@"vi-CN"]) {
        PSAuthenticationMainViewController *mainViewController = [[PSAuthenticationMainViewController alloc] init];
        [[[UIApplication sharedApplication] delegate] window].rootViewController = mainViewController;
        [self saveDefaults];
    }
    else{
        PSAuthenticationMainViewController *mainViewController = [[PSAuthenticationMainViewController alloc] init];
        [[[UIApplication sharedApplication] delegate] window].rootViewController = mainViewController;
        [self saveDefaults];
   }
}

- (void)saveDefaults{
    [LXFileManager removeUserDataForkey:@"isVistor"];
    [LXFileManager saveUserData:@"YES" forKey:@"isVistor"];
}

//连续点击获取验证码 加的方法
-(void)codeClicks{
    _loginMiddleView.codeButton.enabled=NO;
    [self requestForVerificationCode];
}


-(void)requestForVerificationCode{
    [self.view endEditing:YES];
    PSEcomRegisterViewmodel*regiestViewModel=[[PSEcomRegisterViewmodel alloc]init];
    @weakify(regiestViewModel)
    regiestViewModel.phoneNumber=self.loginMiddleView.phoneTextField.text;
    [regiestViewModel checkPhoneDataWithCallback:^(BOOL successful, NSString *tips) {
         @strongify(regiestViewModel)
        if (successful) {
            @weakify(self)
            [regiestViewModel requestCodeCompleted:^(PSResponse *response) {
                if (regiestViewModel.messageCode==201||regiestViewModel.messageCode==204) {
                    [PSTipsView showTips:@"已发送"];
                    self.seconds=60;
                }else{
                    [PSTipsView showTips:@"获取验证码失败"];
                    _loginMiddleView.codeButton.enabled=YES;
                }
            } failed:^(NSError *error) {
                @strongify(self)
                NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [self showNetError:error];
                 _loginMiddleView.codeButton.enabled=YES;
            }];
        } else {
            [PSTipsView showTips:tips];
            _loginMiddleView.codeButton.enabled = YES;
        }
    }];

}


/**
 登录方式变化
 */
-(void)loginTypeChange{
    if (self.loginModeType==PSLoginModePassword) {
        self.loginModeType=PSLoginModeCode;
        self.mode=@"sms_verification_code";
        self.loginMiddleView.codeButton.hidden=NO;
        self.loginMiddleView.codeTextField.placeholder=@"请输入验证码";
        self.loginMiddleView.codeLable.text=@"验证码";
        self.loginMiddleView.codeTextField.secureTextEntry = NO;
        [self.loginTypeButton setTitle:@"使用密码登录" forState:0];
    }
   else if (self.loginModeType==PSLoginModeCode){
         self.loginModeType=PSLoginModePassword;
         self.mode=@"account_password";
         self.loginMiddleView.codeButton.hidden=YES;
         self.loginMiddleView.codeTextField.placeholder=@"请输入密码";
         self.loginMiddleView.codeLable.text=@"密码";
         self.loginMiddleView.codeTextField.secureTextEntry = YES;
         [self.loginTypeButton setTitle:@"使用验证码登录" forState:0];
       
    }
   else{
       
   }
   
}

-(void)changePhoneAction{
     PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;
    [self.navigationController pushViewController:[[PSchangPhoneViewController alloc]initWithViewModel:loginViewModel] animated:YES];
}



#pragma mark -- 注册协议
- (void)openProtocol {
    PSProtocolViewController *protocolViewController = [[PSProtocolViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:protocolViewController animated:YES completion:nil];
}



- (void)updateProtocolStatus {
    PSLoginViewModel *loginViewModel =(PSLoginViewModel *)self.viewModel;
    loginViewModel.agreeProtocol = !loginViewModel.agreeProtocol;
    [self updateProtocolText];
}

- (void)updateProtocolText {
    NSString*read_agree=NSLocalizedString(@"read_agree", nil);
    NSString*usageProtocol=NSLocalizedString(@"usageProtocol", nil);
    NSMutableAttributedString *protocolText = [NSMutableAttributedString new];
    UIFont *textFont = FontOfSize(12);
    [protocolText appendAttributedString:[[NSAttributedString alloc] initWithString:read_agree attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor2}]];
    [protocolText appendAttributedString:[[NSAttributedString  alloc] initWithString: usageProtocol attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor3}]];
    [protocolText appendAttributedString:[[NSAttributedString  alloc] initWithString:@" " attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor3}]];
    PSLoginViewModel *loginViewModel =(PSLoginViewModel *)self.viewModel;
     UIImage *statusImage = loginViewModel.agreeProtocol ? [UIImage imageNamed:@"抢单已勾选"] : [UIImage imageNamed:@"未选"];
    [protocolText insertAttributedString:[NSAttributedString yy_attachmentStringWithContent:statusImage contentMode:UIViewContentModeCenter attachmentSize:statusImage.size alignToFont:textFont alignment:YYTextVerticalAlignmentCenter] atIndex:0];
    protocolText.yy_alignment = NSTextAlignmentRight ;
    self.protocolLabel.attributedText = protocolText;
    self.protocolLabel.numberOfLines=0;
}

#pragma mark -- UI
- (void)renderContents {
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    self.language = langArr.firstObject;
    PSLoginBackgroundView *backgroundView = [PSLoginBackgroundView new];
    [self.view addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;
    PSEcomRegisterViewmodel*registViewModel=[[PSEcomRegisterViewmodel alloc]init];

    self.loginMiddleView = [PSLoginMiddleView new];
    [self.view addSubview:self.loginMiddleView];
    [self.loginMiddleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(160);
        make.centerY.mas_equalTo(self.view).offset(50);
    }];
    
    loginViewModel.phoneNumber = self.loginMiddleView.phoneTextField.text;
    registViewModel.phoneNumber = self.loginMiddleView.phoneTextField.text;
    [self.loginMiddleView.phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        loginViewModel.phoneNumber = textField.text;
        registViewModel.phoneNumber=textField.text;

    }];
    /*
    if ([_language isEqualToString:@"vi-US"]||[_language isEqualToString:@"vi-VN"]||[_language isEqualToString:@"vi-CN"]) {
        midView.codeButton.hidden=YES;

    }
    else {
         midView.codeButton.hidden=NO;
         @weakify(self)
        [midView.codeButton bk_whenTapped:^{
            @strongify(self)
            [self codeClicks];//连续点击获取验证码
        }];
        NSString*change_phone=NSLocalizedString(@"change_phone", nil);
        UIButton *changePhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [changePhoneButton addTarget:self action:@selector(changePhoneAction) forControlEvents:UIControlEventTouchUpInside];
        [changePhoneButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
         changePhoneButton.titleLabel.font = AppBaseTextFont1;
        [changePhoneButton setTitle:change_phone forState:UIControlStateNormal];
        [self.view addSubview:changePhoneButton];
        [changePhoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-10);
            make.size.mas_equalTo(CGSizeMake(100, 40));
            make.centerX.mas_equalTo(self.view);
        }];
        changePhoneButton.titleLabel.numberOfLines=0;
    }
     */
    @weakify(self)
    [self.loginMiddleView.codeButton bk_whenTapped:^{
        @strongify(self)
        [self codeClicks];//连续点击获取验证码
    }];
    #warning TODO 2.1.24除去更换手机号码
    /*
    NSString*change_phone=NSLocalizedString(@"change_phone", nil);
    UIButton *changePhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changePhoneButton addTarget:self action:@selector(changePhoneAction) forControlEvents:UIControlEventTouchUpInside];
    [changePhoneButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    changePhoneButton.titleLabel.font = AppBaseTextFont1;
    [changePhoneButton setTitle:change_phone forState:UIControlStateNormal];
    [self.view addSubview:changePhoneButton];
    [changePhoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-10);
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.centerX.mas_equalTo(self.view);
    }];
    changePhoneButton.titleLabel.numberOfLines=0;
    */
    [self.loginMiddleView.codeTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        loginViewModel.messageCode =textField.text;
    }];
    [self.loginMiddleView.loginButton bk_whenTapped:^{
        @strongify(self)
       [self checkDataIsEmpty];

    }];
   // _loginMiddleView = midView;
    self.protocolLabel = [YYLabel new];
    self.protocolLabel.textAlignment=NSTextAlignmentCenter;
    NSString*usageProtocol=NSLocalizedString(@"usageProtocol", nil);
    [self.protocolLabel setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        @strongify(self)
        NSString *tapString = [text yy_plainTextForRange:range];
        NSString *protocolString = usageProtocol;
        if (tapString) {
            if ([protocolString containsString:tapString]) {
                [self openProtocol];
            }else{
                [self updateProtocolStatus];
            }
        }
    }];
    [self.view addSubview:self.protocolLabel];
    [self.protocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-15);
        make.size.mas_equalTo(CGSizeMake(220, 30));
    }];
    [self updateProtocolText];

    

    
    self.loginTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginTypeButton addTarget:self action:@selector(loginTypeChange) forControlEvents:UIControlEventTouchUpInside];
    [self.loginTypeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    self.loginTypeButton.titleLabel.font = AppBaseTextFont3;
    self.loginTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.loginTypeButton setTitle:@"使用密码登录" forState:UIControlStateNormal];
    [self.view addSubview:self.loginTypeButton];
    [self.loginTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginMiddleView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.right.mas_equalTo(self.loginMiddleView.mas_right);
    }];
    PSLoginTopView *topView = [PSLoginTopView new];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.loginMiddleView.mas_top).offset(-RELATIVE_HEIGHT_VALUE(60));
        make.height.mas_equalTo(86);
    }];
    
    //公众版本
    self.publicTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.publicTypeButton addTarget:self action:@selector(actionforVistor) forControlEvents:UIControlEventTouchUpInside];
    [self.publicTypeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    self.publicTypeButton.titleLabel.font = AppBaseTextFont3;
    self.publicTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.publicTypeButton setTitle:@"公众版本" forState:UIControlStateNormal];
    [self.view addSubview:self.publicTypeButton];
    [self.publicTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginMiddleView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.left.mas_equalTo(self.loginMiddleView.mas_left).offset(2);
    }];
    
}

- (void)initialize {
    
}

- (BOOL)hiddenNavigationBar {
    return YES;
}

#pragma mark  - life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self renderContents];
}



#pragma mark - PSCountdownObserver
- (void)countdown {
    if (_seconds > 0) {
        [_loginMiddleView.codeButton setTitle:[NSString stringWithFormat:@"重发(%ld)",(long)_seconds] forState:UIControlStateDisabled];
        _seconds --;
         if (self.seconds==0) _loginMiddleView.codeButton.enabled = YES;
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

@end
