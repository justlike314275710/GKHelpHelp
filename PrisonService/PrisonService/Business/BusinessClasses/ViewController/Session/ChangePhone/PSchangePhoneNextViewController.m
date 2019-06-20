//
//  PSchangePhoneNextViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/14.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSchangePhoneNextViewController.h"
#import "PSCountdownManager.h"
#import "PSUnderlineTextField.h"
#import "PSLoginViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "PSLoginViewController.h"
#import "Expression.h"
#import "PSAlertView.h"
#import "PSEcomRegisterViewmodel.h"
@interface PSchangePhoneNextViewController ()<PSCountdownObserver>
@property (nonatomic,strong) PSUnderlineTextField *phoneTextField;
@property (nonatomic,strong) PSUnderlineTextField *codeTextField;
@property (nonatomic,strong) UIButton* codeButton;
@property (nonatomic,strong) UIButton* sureChangeButton;
@property (nonatomic, assign) NSInteger seconds;
@end

@implementation PSchangePhoneNextViewController
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
    self.title=@"更换手机号码";
    // Do any additional setup after loading the view.
}

-(void)renderContents{
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
//    [_phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//
//        regiestViewModel.phoneNumber = textField.text;
//    }];
    
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
    
    
    _sureChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureChangeButton.titleLabel.font = AppBaseTextFont1;
    [_sureChangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sureChangeButton setTitle:@"确定" forState:UIControlStateNormal];
    [_sureChangeButton setBackgroundColor:AppBaseTextColor3];
    [self.view addSubview:_sureChangeButton];
    [_sureChangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_codeTextField.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-50, 44));
    }];
    
    [_sureChangeButton bk_whenTapped:^{
        [self checkPhoneData];
    }];
}

-(void)checkPhoneData{
    
    if ([Expression validatePhoneId:self.phoneTextField.text]&&[Expression validateVetifyCode:self.codeTextField.text]) {
        [self sureChangePhoneAcition];
        return;
    } else {
        NSString*text;
        if (_phoneTextField.text.length == 0) {
            text = @"请输入手机号码";
            
        }
        else if (_codeTextField.text.length==0){
            text=@"请输入验证码";
        }
        else if (![Expression validatePhoneId:_phoneTextField.text])
        {
            text = @"手机号码错误";
        }
 
        [PSTipsView showTips:text];
    }
}

-(void)sureChangePhoneAcition{
    [[PSLoadingView sharedInstance]show];
    NSString*url=[NSString stringWithFormat:@"%@/users/me/phone-number",EmallHostUrl];
    NSDictionary*parmeters=@{
                             @"phoneNumber":_phoneTextField.text,
                             @"verificationCode":_codeTextField.text
                             };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.f;

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [ manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager PUT:url parameters:parmeters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[PSLoadingView sharedInstance]dismiss];
        [self synchronizationPhone];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[PSLoadingView sharedInstance]dismiss];
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSString*message=body[@"message"];
        if (message) {
            [PSTipsView showTips:message];
        } else {
            [self showNetError:error];
        }
    }];
    
}
- (void)synchronizationPhone {
    NSString*url=[NSString stringWithFormat:@"%@/families/updatePhone",ServerUrl];
    NSDictionary*parmeters=@{
                             @"newPhone":_phoneTextField.text
                             };
    NSLog(@"%@",parmeters);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [ manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager POST:url parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [PSAlertView showWithTitle:nil message:@"更换手机号码成功" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==0) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } buttonTitles:@"确定", nil];
        NSLog(@"平台同步%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [PSTipsView showTips:@"更换手机号码失败"];
    }];
    
}

- (void)requestMessageCode {
    [self.view endEditing:YES];
    PSEcomRegisterViewmodel*regiestViewModel=[[PSEcomRegisterViewmodel alloc]init];
    regiestViewModel.phoneNumber=_phoneTextField.text;
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

- (void)dealloc {
    [[PSCountdownManager sharedInstance] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
