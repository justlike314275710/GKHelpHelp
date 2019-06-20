//
//  PSchangPhoneViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/14.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSchangPhoneViewController.h"
#import "PSUnderlineTextField.h"
#import "PSCountdownManager.h"
#import "PSLoginViewModel.h"
#import "PSchangePhoneNextViewController.h"
#import "PSfaceChangeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "Expression.h"
#import "PSAlertView.h"
#import "PSEcomRegisterViewmodel.h"
#import "PSEcomLoginViewmodel.h"
#import "PSSessionManager.h"
@interface PSchangPhoneViewController ()<PSCountdownObserver>
@property (nonatomic,strong) PSUnderlineTextField *phoneTextField;
@property (nonatomic,strong) PSUnderlineTextField *cardTextField;
@property (nonatomic,strong) PSUnderlineTextField *codeTextField;
@property (nonatomic,strong) UIButton*codeButton;
@property (nonatomic,strong) UIButton*nextButton;
@property (nonatomic, assign) NSInteger seconds;
@end

@implementation PSchangPhoneViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
    }
    return self;
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
    [self showInternetError];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"更换手机号码";
    [self renderContents];
    // Do any additional setup after loading the view.
}

-(void)renderContents{
   
    self.view.backgroundColor= [UIColor colorWithRed:249/255.0 green:248/255.0 blue:254/255.0 alpha:1];
    CGFloat sidePadding = 20;
//    _phoneTextField = [[PSUnderlineTextField alloc] initWithFrame:CGRectZero];
//    _phoneTextField.font = AppBaseTextFont2;
//    _phoneTextField.borderStyle = UITextBorderStyleNone;
//    _phoneTextField.textColor = AppBaseTextColor1;
//    _phoneTextField.textAlignment = NSTextAlignmentCenter;
//    _phoneTextField.placeholder = @"请输入旧手机号";
//    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
//    [self.view addSubview:_phoneTextField];
//    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(sidePadding);
//        make.right.mas_equalTo(-sidePadding);
//        make.top.mas_equalTo(20);
//        make.height.mas_equalTo(44);
//    }];
//    [_phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//         regiestViewModel.phoneNumber = textField.text;
//    }];
    
    UILabel*phoneLable=[UILabel new];
    NSString*phoneNumber=[PSSessionManager sharedInstance].session.families.phone;
    phoneLable.text=NSStringFormat(@"更换手机号，下次登录可使用新手机号登录。当前手机号:%@",phoneNumber);
    phoneLable.textColor=AppBaseTextColor1;
    phoneLable.numberOfLines=0;
    phoneLable.font= FontOfSize(12);
    [self.view addSubview:phoneLable];
    [phoneLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sidePadding);
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(44);
    }];
    

    
    _codeTextField = [[PSUnderlineTextField alloc] initWithFrame:CGRectZero];
    _codeTextField.font = AppBaseTextFont2;
    _codeTextField.borderStyle = UITextBorderStyleNone;
    _codeTextField.textColor = AppBaseTextColor1;
    _codeTextField.textAlignment = NSTextAlignmentCenter;
    _codeTextField.placeholder = @"请输入验证码";
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_codeTextField];
    [_codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.top.mas_equalTo(phoneLable.mas_bottom);
        make.height.mas_equalTo(44);
    }];
//    [_codeTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//        //loginViewModel.messageCode = textField.text;
//    }];
    
    UILabel*codeLable=[UILabel new];
    codeLable.text=@"验证码";
    codeLable.font= AppBaseTextFont2;
    [self.view addSubview:codeLable];
    [codeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_codeTextField.mas_top);
        make.left.mas_equalTo(_codeTextField.mas_left);
        make.bottom.mas_equalTo(_codeTextField.mas_bottom);
        make.width.mas_equalTo(70);
    }];
    

    _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeButton.titleLabel.font = AppBaseTextFont2;
    [_codeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    [_codeButton setTitleColor:AppBaseTextColor2 forState:UIControlStateDisabled];
    [_codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.view addSubview:_codeButton];
    [_codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_codeTextField.mas_top);
        make.right.mas_equalTo(_codeTextField.mas_right);
        make.bottom.mas_equalTo(_codeTextField.mas_bottom);
        make.width.mas_equalTo(70);
    }];
    [_codeButton bk_whenTapped:^{
        [self requestMessageCode];
    }];
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextButton.titleLabel.font = AppBaseTextFont1;
    [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextButton setBackgroundColor:AppBaseTextColor3];
    [self.view addSubview:_nextButton];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_codeTextField.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-50, 44));
    }];
    
    [_nextButton bk_whenTapped:^{
        [self checkDataAcition];
    }];
    
    
}


-(void)checkDataAcition{
     
    if([Expression validateVetifyCode:_codeTextField.text]) {
        [self EcommerceOfLogin];
        return;
    }
     else{
         NSString*text;
         if (_phoneTextField.text.length == 0) {
             text = @"请输入手机号";
             
         }
         else if (![Expression validatePhoneId:_phoneTextField.text])
         {
             text = @"手机号错误";
         }
         else if (_codeTextField.text.length==0)
         {
             text = @"请输入验证码";
         }
         
         [PSTipsView showTips:text];
     }
}



-(void)requestMessageCode{
    [self.view endEditing:YES];
    PSEcomRegisterViewmodel*regiestViewModel=[[PSEcomRegisterViewmodel alloc]init];
    regiestViewModel.phoneNumber=[PSSessionManager sharedInstance].session.families.phone;
    @weakify(regiestViewModel)
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
                }
            } failed:^(NSError *error) {
                @strongify(self)
                [self showNetError:error];
            }];
        } else {
            [PSTipsView showTips:tips];
        }
    }];
}
-(void)EcommerceOfLogin{
    PSEcomLoginViewmodel*ecomViewmodel=[[PSEcomLoginViewmodel alloc]init];
    ecomViewmodel.username=[PSSessionManager sharedInstance].session.families.phone;
    ecomViewmodel.password=self.codeTextField.text;
    @weakify(ecomViewmodel)
    @weakify(self)
    [ecomViewmodel postEcomLogin:^(PSResponse *response) {
        @strongify(ecomViewmodel)
        @strongify(self)
        if (ecomViewmodel.statusCode==200) {
            [self.navigationController pushViewController:[[PSchangePhoneNextViewController alloc]initWithViewModel:[[PSEcomRegisterViewmodel alloc]init]] animated:YES];
        }
        else {
            [PSTipsView showTips:@"手机号码或验证码错误"];
        }
        
    } failed:^(NSError *error) {
        [PSTipsView showTips:@"手机号码或验证码错误"];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[PSCountdownManager sharedInstance] removeObserver:self];
}
#pragma mark - PSCountdownObserver
- (void)countdown {
   _codeButton.enabled = _seconds == 0;
    if (_seconds > 0) {
        [_codeButton setTitle:[NSString stringWithFormat:@"重发(%ld)",(long)_seconds] forState:UIControlStateDisabled];
        _seconds --;
    }
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
