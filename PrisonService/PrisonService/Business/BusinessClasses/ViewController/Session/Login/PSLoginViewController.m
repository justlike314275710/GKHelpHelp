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

typedef NS_ENUM(NSInteger, PSLoginModeType) {
    PSLoginModeCode,
    PSLoginModePassword,
};
@interface PSLoginViewController ()<PSCountdownObserver,UIAlertViewDelegate>
@property (nonatomic ,assign) PSLoginModeType loginModeType;
@property (nonatomic ,strong) NSString *mode;
@property (nonatomic ,strong) PSLoginMiddleView *loginMiddleView;
@property (nonatomic ,strong) UIButton *loginTypeButton ;
@property (nonatomic ,strong) UIButton *publicTypeButton ;
@property (nonatomic ,assign) NSInteger seconds;
@property (nonatomic ,strong) NSMutableArray*titles;
@property (nonatomic ,strong) NSMutableArray *token;
@property (nonatomic ,strong) NSString *language ;
@property (nonatomic ,assign) NSInteger RefreshCode;
@property (nonatomic ,strong) YYLabel *protocolLabel;
@property (nonatomic ,strong, readonly) UIViewController *rootViewController;
@end

@implementation PSLoginViewController

#pragma mark ---------- LifeCycle
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
        self.loginModeType=PSLoginModeCode;
        self.mode=@"sms_verification_code";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)dealloc {
    [[PSCountdownManager sharedInstance] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)hiddenNavigationBar {
    return YES;
}
#pragma mark ---------- Private Method
/** 视图初始化 */
- (void)setupUI {
    
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
    
    @weakify(self)
    [self.loginMiddleView.codeButton bk_whenTapped:^{
        @strongify(self)
        [self codeClicks];//连续点击获取验证码
    }];
    [self.loginMiddleView.codeTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        loginViewModel.messageCode =textField.text;
    }];
    [self.loginMiddleView.loginButton addTarget:self action:@selector(checkDataIsEmpty) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.loginMiddleView.loginButton bk_whenTapped:^{
//        @strongify(self)
//        [self checkDataIsEmpty];
//        _loginMiddleView.loginButton.enabled=NO;
//        _loginMiddleView.loginButton.selected = NO;
//    }];
    
    [self.view addSubview:self.protocolLabel];
    [self.protocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-15);
        make.size.mas_equalTo(CGSizeMake(220, 30));
    }];
    [self updateProtocolText];
    
    [self.view addSubview:self.loginTypeButton];
    [self.loginTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginMiddleView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 40));
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
    [self.view addSubview:self.publicTypeButton];
    [self.publicTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginMiddleView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 40));
        make.left.mas_equalTo(self.loginMiddleView.mas_left).offset(2);
    }];
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
//保存游客模式标志
- (void)saveDefaults{
    [LXFileManager removeUserDataForkey:@"isVistor"];
    [LXFileManager saveUserData:@"YES" forKey:@"isVistor"];
}
//MARK:获取验证码
-(void)requestForVerificationCode{
    [_loginMiddleView.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_loginMiddleView.codeButton setTitleColor:AppBaseTextColor2  forState:UIControlStateNormal];
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
                _loginMiddleView.codeButton.enabled=YES;
                [_loginMiddleView.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                [_loginMiddleView.codeButton setTitleColor:AppBaseTextColor3  forState:UIControlStateNormal];
                [self showNetError:error];
            }];
        } else {
            [PSTipsView showTips:tips];
            _loginMiddleView.codeButton.enabled = YES;
            [_loginMiddleView.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [_loginMiddleView.codeButton setTitleColor:AppBaseTextColor3  forState:UIControlStateNormal];
        }
    }];
}

//MARK:越南版注册
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
        [self showNetError:error];
        
    }];
}
//MARK:公共服务登录
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
            [self getUserIminfo];
        } else {
            NSString*account_code_error=NSLocalizedString(@"account_code_error", nil);
            [PSTipsView showTips:account_code_error];
            self.loginMiddleView.loginButton.enabled=YES;
            self.loginMiddleView.loginButton.selected=YES;
        }
    } failed:^(NSError *error) {
        [self showNetError:error];
        self.loginMiddleView.loginButton.enabled=YES;
        self.loginMiddleView.loginButton.selected=YES;
    }];
}
//MARK:查询(同步)当前IM信息
-(void)getUserIminfo{
    PSEcomLoginViewmodel*ecomViewmodel=[[PSEcomLoginViewmodel alloc]init];
    [ecomViewmodel loginGetImifnoComplete:^(PSResponse *response) {
        [self logInAction];
    } failed:^(NSError *error) {
        NSString*account_code_error=NSLocalizedString(@"account_code_error", nil);
        [PSTipsView showTips:account_code_error];
        self.loginMiddleView.loginButton.enabled=YES;
        self.loginMiddleView.loginButton.selected=YES;
    }];
}
//MARK:狱务通登录
- (void)logInAction {
    [[PSLoadingView sharedInstance] show];
    PSLoginViewModel *loginViewModel =(PSLoginViewModel *)self.viewModel;
    @weakify(self)
    @weakify(loginViewModel)
    [loginViewModel loginCompleted:^(PSResponse *response) {
        @strongify(self)
        @strongify(loginViewModel)
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
            if (self.callback&&loginViewModel.session.account) {
                self.callback(YES,loginViewModel.session);
            }
        }
        else{
            [PSTipsView showTips:loginViewModel.message? loginViewModel.message : @"登录失败"];
        }
        self.loginMiddleView.loginButton.enabled=YES;
        self.loginMiddleView.loginButton.selected=YES;
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
        self.loginMiddleView.loginButton.enabled=YES;
        self.loginMiddleView.loginButton.selected=YES;
    }];
}

//MARK:注册
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
        id body = [self errorData:error];
        if (body) {
            NSString*code=body[@"code"];            
            if ([code isEqualToString:@"user.PhoneNumberExisted"]) { //用户手机号码存在
                [self EcommerceOfLogin];
            } else {
                [self showNetError:error];
            }
        } else {
            [self showNetError:error];
        }
    }];
}
#pragma mark ---------- Target Mehtods
//MARK:游客模式
-(void)actionforVistor:(UIButton*)sender{
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
//MARK:获取验证码防止连续点击
-(void)codeClicks{
    _loginMiddleView.codeButton.enabled=NO;
    [self requestForVerificationCode];
}
//MARK:注册协议
- (void)openProtocol {
    PSProtocolViewController *protocolViewController = [[PSProtocolViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:protocolViewController animated:YES completion:nil];
}
//MARK:是否同意协议
- (void)updateProtocolStatus {
    PSLoginViewModel *loginViewModel =(PSLoginViewModel *)self.viewModel;
    loginViewModel.agreeProtocol = !loginViewModel.agreeProtocol;
    [self updateProtocolText];
}
//MARK:登录方式变化
-(void)loginTypeChange{
    self.loginMiddleView.codeTextField.text = @"";
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
}
//MARK:验证数据
- (void)checkDataIsEmpty {
    
    _loginMiddleView.loginButton.enabled=NO;
    _loginMiddleView.loginButton.selected = NO;
    [self.view endEditing:YES];
    PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;
    @weakify(self)
    [loginViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            if ([NSObject judegeIsVietnamVersion]) { //越南版
                [self EcommerceOfVietnamRegister];
            } else{
                if (self.loginModeType==PSLoginModePassword) {
                    [self EcommerceOfLogin];
                    [SDTrackTool logEvent:PSW_Login];
                }
                if (self.loginModeType==PSLoginModeCode){
                    [self EcommerceOfRegister];
                    [SDTrackTool logEvent:VER_Login];
                }
            }
        }else{
            [PSTipsView showTips:tips];
            _loginMiddleView.loginButton.enabled=YES;
            _loginMiddleView.loginButton.selected = YES;
            
        }
    }];
}
#pragma mark ---------- PSCountdownObserver
- (void)countdown {
    if (_seconds > 0) {
        _seconds --;
        [_loginMiddleView.codeButton setTitle:[NSString stringWithFormat:@"重发(%ld)",(long)_seconds] forState:UIControlStateNormal];
        if (self.seconds==0) {
            _loginMiddleView.codeButton.enabled = YES;
            [_loginMiddleView.codeButton setTitleColor:AppBaseTextColor3  forState:UIControlStateNormal];
            [_loginMiddleView.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        }
    }
}
#pragma mark ---------- Setter & Getter
//公众版本
-(UIButton *)publicTypeButton{
    if(_publicTypeButton==nil){
        _publicTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicTypeButton addTarget:self action:@selector(actionforVistor:) forControlEvents:UIControlEventTouchUpInside];
        [_publicTypeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
        _publicTypeButton.titleLabel.font = AppBaseTextFont3;
        _publicTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_publicTypeButton setTitle:@"公众版本" forState:UIControlStateNormal];
    }
    return _publicTypeButton;
}
-(YYLabel*)protocolLabel{
    if (!_protocolLabel) {
        _protocolLabel = [YYLabel new];
        _protocolLabel.textAlignment=NSTextAlignmentCenter;
        @weakify(self)
        NSString*usageProtocol=NSLocalizedString(@"usageProtocol", nil);
        [_protocolLabel setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
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
    }
    return _protocolLabel;
}
-(UIButton *)loginTypeButton{
    if (!_loginTypeButton) {
        _loginTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginTypeButton addTarget:self action:@selector(loginTypeChange) forControlEvents:UIControlEventTouchUpInside];
        [_loginTypeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
        _loginTypeButton.titleLabel.font = AppBaseTextFont3;
        _loginTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_loginTypeButton setTitle:@"使用密码登录" forState:UIControlStateNormal];
    }
    return _loginTypeButton;
}


@end

