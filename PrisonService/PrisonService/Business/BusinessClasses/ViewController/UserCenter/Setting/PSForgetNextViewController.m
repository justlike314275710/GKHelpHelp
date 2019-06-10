//
//  PSForgetNextViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/6/3.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSForgetNextViewController.h"
#import "PSPasswordViewModel.h"
@interface PSForgetNextViewController ()
@property (nonatomic , strong) UITextField *passwordTextfield;
@end

@implementation PSForgetNextViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"设置密码";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    // Do any additional setup after loading the view.
}
- (void)renderContents{
    self.view.backgroundColor=[UIColor groupTableViewBackgroundColor];
    CGFloat horizontalSpace = 15.0f;
    UILabel*tipsLabel=[UILabel new];
    [self.view addSubview:tipsLabel];
    tipsLabel.font=FontOfSize(12);
    tipsLabel.textColor=AppBaseTextColor1;
    tipsLabel.text=@"设置密码后，你可以通过手机号和密码登录狱务通。";
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(20);
    }];
    
    UIView*bgView=[UIView new];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLabel.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    
    self.passwordTextfield=[UITextField new];
    [bgView addSubview:self.passwordTextfield];
    self.passwordTextfield.placeholder=@"8-16位，至少含数字/字母/字符2种组合";
    self.passwordTextfield.font=FontOfSize(12);
    [self.passwordTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLabel.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(44);
    }];
    self.passwordTextfield.secureTextEntry=YES;
    
    UIButton*showPasswordButton=[UIButton new];
    [showPasswordButton setImage:IMAGE_NAMED(@"显示密码") forState:UIControlStateNormal];
    [showPasswordButton setImage:IMAGE_NAMED(@"不显示密码") forState:UIControlStateSelected];
    [bgView addSubview:showPasswordButton];
    [showPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordTextfield.top).offset(horizontalSpace);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(16);
    }];
    [showPasswordButton addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIButton*passwordButton=[UIButton new];
    ViewRadius(passwordButton, 4);
    [passwordButton setTitle:@"确定" forState:0];
    [passwordButton setTitleColor:[UIColor whiteColor] forState:0];
    passwordButton.titleLabel.font=FontOfSize(14);
    passwordButton.backgroundColor=AppBaseTextColor3;
    [self.view addSubview:passwordButton];
    [passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordTextfield.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(44);
    }];
    [passwordButton bk_whenTapped:^{
        [self passwordButtonClicked];
    }];
}

- (void)passwordButtonClicked {
    PSPasswordViewModel *ViewModel  =(PSPasswordViewModel *)self.viewModel;
    ViewModel.phone_newPassword=self.passwordTextfield.text;
    [ViewModel checkNewPhoneDataWithCallback:^(BOOL successful, NSString *tips) {
        if (successful) {
            [ViewModel requestByVerficationCodeCompleted:^(PSResponse *response) {
                [PSTipsView showTips:@"密码修改成功!"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } failed:^(NSError *error) {
                [PSTipsView showTips:@"密码修改失败!"];
            }];
        }else{
            [PSTipsView showTips:tips];
        }
    }];
    
}

- (void) rightBarButtonItemClicked:(UIButton *)sender{
    self.passwordTextfield.secureTextEntry=! self.passwordTextfield.secureTextEntry;
    sender.selected=!sender.selected;
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
