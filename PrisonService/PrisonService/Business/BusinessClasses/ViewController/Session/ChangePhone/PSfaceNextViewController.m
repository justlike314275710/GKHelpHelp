//
//  PSfaceNextViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/15.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSfaceNextViewController.h"
#import "PSLoginViewModel.h"
#import "PSCountdownManager.h"
#import "PSUnderlineTextField.h"
#import "PSBusinessConstants.h"
#import <AFNetworking/AFNetworking.h>
#import "PSLoginViewController.h"
#import "Expression.h"
#import "PSAlertView.h"
@interface PSfaceNextViewController ()<PSCountdownObserver>
@property (nonatomic,strong) PSUnderlineTextField *phoneTextField;
@property (nonatomic,strong) PSUnderlineTextField *codeTextField;
@property (nonatomic,strong) UIButton* codeButton;
@property (nonatomic,strong) UIButton* sureChangeButton;
@property (nonatomic, assign) NSInteger seconds;
@end

@implementation PSfaceNextViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    self.title=@"更改手机号码";
    // Do any additional setup after loading the view.
}

-(void)renderContents{
    PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;
    self.view.backgroundColor= [UIColor colorWithRed:249/255.0 green:248/255.0 blue:254/255.0 alpha:1];
    CGFloat sidePadding = 20;
    _phoneTextField = [[PSUnderlineTextField alloc] initWithFrame:CGRectZero];
    _phoneTextField.font = AppBaseTextFont2;
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.textColor = AppBaseTextColor1;
    _phoneTextField.textAlignment = NSTextAlignmentCenter;
    _phoneTextField.placeholder = @"请输入新手机号";
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_phoneTextField];
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(44);
    }];
        [_phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
            loginViewModel.phoneNumber = textField.text;
           // self.phoneNew=textField.text;
        }];
    
    UILabel*phoneLable=[UILabel new];
    phoneLable.text=@"新手机号";
    phoneLable.font= AppBaseTextFont2;
    [self.view addSubview:phoneLable];
    [phoneLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_phoneTextField.mas_top);
        make.left.mas_equalTo(_phoneTextField.mas_left);
        make.bottom.mas_equalTo(_phoneTextField.mas_bottom);
        make.width.mas_equalTo(70);
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
        make.top.mas_equalTo(_phoneTextField.mas_bottom);
        make.height.mas_equalTo(44);
    }];
    
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
    
    
    _sureChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureChangeButton.titleLabel.font = AppBaseTextFont1;
    [_sureChangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sureChangeButton setTitle:@"确认" forState:UIControlStateNormal];
    [_sureChangeButton setBackgroundColor:AppBaseTextColor3];
    [self.view addSubview:_sureChangeButton];
    [_sureChangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_codeTextField.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-50, 44));
    }];
    
    [_sureChangeButton bk_whenTapped:^{
        [self checkDataAcition];
    }];
}


- (void)requestMessageCode {
    [self.view endEditing:YES];
    PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;

    @weakify(loginViewModel)
    [loginViewModel checkPhoneDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(loginViewModel)
        if (successful) {
            @weakify(self)
            [loginViewModel requestCodeCompleted:^(PSResponse *response) {
                @strongify(self)
                if (response.code == 200) {
                    [PSTipsView showTips:@"已发送"];
                    self.seconds = 60;
                }else{
                    [PSTipsView showTips:response.msg ? response.msg : @"获取验证码失败"];
                }
            } failed:^(NSError *error) {
                @strongify(self)
                [self showNetError:error];
            }];
        }else{
            [PSTipsView showTips:tips];
        }
    }];
}
-(void)sureChangePhoneAcition{
    [[PSLoadingView sharedInstance]show];
    NSString*url=[NSString stringWithFormat:@"%@/api/families/updatePhone",ServerUrl];
    NSDictionary*parmeters=@{
                             @"oldPhone":self.oldPhone,
                             @"newPhone":self.phoneTextField.text,
                             @"uuid":self.uuid,
                              @"flag":@"true",
                             @"validateCode":self.codeTextField.text
                             };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:parmeters progress:^(NSProgress * _Nonnull uploadProgress) {
    }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
              if ([responseObject[@"code"]intValue]==200) {
                  //[PSTipsView showTips:responseObject[@"msg"]];
                  [[PSLoadingView sharedInstance]dismiss];
                  [PSAlertView showWithTitle:@"提示" message:@"更换手机号码成功" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                      if (buttonIndex==1) {
                           [self.navigationController popToRootViewControllerAnimated:NO];
                      }
                  } buttonTitles:@"确定", nil];
               
              }
              else{
                   [[PSLoadingView sharedInstance]dismiss];
                  NSString*text=responseObject[@"msg"];
                  [PSTipsView showTips:text?text:@"更换手机号码失败"];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               [[PSLoadingView sharedInstance]dismiss];
              [self showNetError:error];
          }];
}

-(void)checkDataAcition{
    if([Expression validatePhoneId:self.phoneTextField.text]&&[Expression validateVetifyCode:_codeTextField.text]) {
        [self sureChangePhoneAcition];
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
        else{
            text=@"验证码错误";
        }
        [PSTipsView showTips:text];
    }
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
