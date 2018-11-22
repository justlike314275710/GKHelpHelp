//
//  PSfaceChangeViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/14.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSfaceChangeViewController.h"
#import "PSFaceAuthViewController.h"
#import "PSUnderlineTextField.h"
#import "PSLoginViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "PSfaceNextViewController.h"
#import "Expression.h"
#import "PSAlertView.h"
@interface PSfaceChangeViewController ()
@property (nonatomic,strong) PSUnderlineTextField *phoneTextField;
@property (nonatomic,strong) PSUnderlineTextField *codeTextField;
@property (nonatomic,strong) UIButton* codeButton;
@property (nonatomic,strong) UIButton* sureChangeButton;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic,strong) NSString*phoneNew;
@property (nonatomic,strong) NSString*avatarUrl;
@end

@implementation PSfaceChangeViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //注册检测网络通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nonetWork) name:NotificationNoNetwork object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    self.title=@"更换手机号码";
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNoNetwork object:nil];
}

#pragma mark - Notification
-(void)nonetWork {
    [PSAlertView showWithTitle:@"提示" message:@"请检查网络设置" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {
        }
    } buttonTitles:@"取消",@"确认", nil];
}

-(void)renderContents{
    
    self.view.backgroundColor= [UIColor colorWithRed:249/255.0 green:248/255.0 blue:254/255.0 alpha:1];
    CGFloat sidePadding = 20;
    _phoneTextField = [[PSUnderlineTextField alloc] initWithFrame:CGRectZero];
    _phoneTextField.font = AppBaseTextFont2;
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.textColor = AppBaseTextColor1;
    _phoneTextField.textAlignment = NSTextAlignmentCenter;
    _phoneTextField.placeholder = @"请输入旧手机号";
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_phoneTextField];
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(44);
    }];
//    [_phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//        loginViewModel.phoneNumber = textField.text;
//        self.phoneNew=textField.text;
//    }];
    
    UILabel*phoneLable=[UILabel new];
    phoneLable.text=@"旧手机号";
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
    _codeTextField.placeholder = @"请输入身份证号码";
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_codeTextField];
    [_codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.top.mas_equalTo(_phoneTextField.mas_bottom);
        make.height.mas_equalTo(44);
    }];
    
    UILabel*codeLable=[UILabel new];
    codeLable.text=@"身份证号码";
    codeLable.font= AppBaseTextFont2;
    [self.view addSubview:codeLable];
    [codeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_codeTextField.mas_top);
        make.left.mas_equalTo(_codeTextField.mas_left);
        make.bottom.mas_equalTo(_codeTextField.mas_bottom);
        make.width.mas_equalTo(70);
    }];
    
    _sureChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureChangeButton.titleLabel.font = AppBaseTextFont1;
    [_sureChangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sureChangeButton setTitle:@"人脸识别" forState:UIControlStateNormal];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)pushNextTip{
    PSLoginViewModel *loginViewModel = (PSLoginViewModel *)self.viewModel;
    PSfaceNextViewController*faceNextViewController=[[PSfaceNextViewController alloc]initWithViewModel:loginViewModel];
    [self.navigationController pushViewController:faceNextViewController animated:YES];
    faceNextViewController.oldPhone=self.phoneTextField.text;
    faceNextViewController.uuid=self.codeTextField.text;
    faceNextViewController.faceNextViewController=self;
}
- (void)checkFaceAuth {
    PSFaceAuthViewController *authViewController = [[PSFaceAuthViewController alloc] initWithViewModel:nil];
    [self.navigationController pushViewController:authViewController animated:NO];
   // authViewController.FaceAuthViewController=self;
    authViewController.iconUrl=self.avatarUrl;
    [authViewController setCompletion:^(BOOL successful) {
        if (successful) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:NO];
                [self pushNextTip];
            });
           
        }
  
        else{
            [PSTipsView showTips:@"人脸身份验证失败"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

}
-(void)getavatarUrl{
    NSString*url=[NSString stringWithFormat:@"%@/api/families/getFamilyByPhone",ServerUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary*parmeters=@{
                             @"uuid":self.codeTextField.text
                             };
    [manager GET:url parameters:parmeters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"]intValue]==200) {
            self.avatarUrl= responseObject[@"data"][@"family"][@"avatarUrl"];
            [self checkFaceAuth];
        } else {
            [PSTipsView showTips:@"身份证号码错误"];
        }
      self.avatarUrl= responseObject[@"data"][@"family"][@"avatarUrl"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showNetError];
    }];
    

}
-(void)checkDataAcition{
    if([Expression validateIDCard:_codeTextField.text]&&[Expression validatePhoneId:self.phoneTextField.text]) {
        [self getavatarUrl];
        return;
    }
    else{
        NSString*text;
        if (_phoneTextField.text.length == 0) {
            text = @"请输入手机号";
            
        }
        else if (![Expression validatePhoneId:_phoneTextField.text])
        {
            text = @"手机号码错误";
        }
        else if(_codeTextField.text.length== 0)
        {
            text = @"请输入身份证号";
        }
        else
        {
            text = @"身份证号码错误";
        }
        
        [PSTipsView showTips:text];
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
