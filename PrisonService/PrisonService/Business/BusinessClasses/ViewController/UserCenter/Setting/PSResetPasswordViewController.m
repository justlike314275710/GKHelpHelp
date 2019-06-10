//
//  PSResetPasswordViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/21.
//  Copyright © 2019年 calvin. All rights reserved.
//
#import "PSResetPasswordViewController.h"
#import "PSPasswordViewModel.h"
#import "PSForgetPasswordViewController.h"
@interface PSResetPasswordViewController ()
@property (nonatomic , strong) UITextField *oldPasswordTextfield;
@property (nonatomic , strong) UITextField *novaPasswordTextfield;
@property (nonatomic , strong) UITextField *confirmPasswordTextfield;

@end

@implementation PSResetPasswordViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"重置密码";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    [self createRightBarButtonItemWithTarget:self action:@selector(completeButtonClick) title:@"完成"];
    // Do any additional setup after loading the view.
}

- (void)renderContents{
    self.view.backgroundColor=[UIColor colorWithRed:249/255.0 green:248/255.0 blue:254/255.0 alpha:1.0];
    CGFloat horizontalSpace = 15.0f;
    CGFloat defultTag = 999;

    
    UIView*bgView=[UIView new];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(132);
    }];
    bgView.userInteractionEnabled=YES;
    
    UILabel*oldLable=[UILabel new];
    [bgView addSubview:oldLable];
    oldLable.text=@"旧密码";
    oldLable.font=FontOfSize(12);
    oldLable.textColor=[UIColor blackColor];
    [oldLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(14);
    }];
    
    self.oldPasswordTextfield=[UITextField new];
    [bgView addSubview:self.oldPasswordTextfield];
    self.oldPasswordTextfield.placeholder=@"若包含字母,请注意区别大小写";
    self.oldPasswordTextfield.font=FontOfSize(12);
    [self.oldPasswordTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(oldLable.mas_right).offset(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(14);
    }];
    self.oldPasswordTextfield.secureTextEntry=YES;
    
    UIButton*oldShowPasswordButton=[UIButton new];
    [oldShowPasswordButton setImage:IMAGE_NAMED(@"显示密码") forState:UIControlStateNormal];
    [oldShowPasswordButton setImage:IMAGE_NAMED(@"不显示密码") forState:UIControlStateSelected];
    [bgView addSubview:oldShowPasswordButton];
    [oldShowPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.oldPasswordTextfield.top).offset(horizontalSpace);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(16);
    }];
    oldShowPasswordButton.tag=0+defultTag;
    [oldShowPasswordButton addTarget:self action:@selector(IsShowPasswordItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView*line_one=[UIView new];
    line_one.backgroundColor=AppBaseLineColor;
    [bgView addSubview:line_one];
    [line_one mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.oldPasswordTextfield.mas_bottom).offset(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.height.mas_equalTo(1);
    }];
    
    
    
    UILabel*newLable=[UILabel new];
    [bgView addSubview:newLable];
    newLable.text=@"新密码";
    newLable.font=FontOfSize(12);
    newLable.textColor=[UIColor blackColor];
    [newLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_one.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(14);
    }];
    
    self.novaPasswordTextfield=[UITextField new];
    [bgView addSubview:self.novaPasswordTextfield];
    self.novaPasswordTextfield.placeholder=@"8-16位，至少含数字/字母/字符2种组合";
    self.novaPasswordTextfield.font=FontOfSize(12);
    [self.novaPasswordTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_one.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(oldLable.mas_right).offset(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(14);
    }];
    self.novaPasswordTextfield.secureTextEntry=YES;
    
    UIButton*newShowPasswordButton=[UIButton new];
    [newShowPasswordButton setImage:IMAGE_NAMED(@"显示密码") forState:UIControlStateNormal];
    [newShowPasswordButton setImage:IMAGE_NAMED(@"不显示密码") forState:UIControlStateSelected];
    [bgView addSubview:newShowPasswordButton];
    [newShowPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_one.mas_top).offset(horizontalSpace);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(16);
    }];
    newShowPasswordButton.tag=1+defultTag;
    [newShowPasswordButton addTarget:self action:@selector(IsShowPasswordItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIView*line_two=[UIView new];
    line_two.backgroundColor=AppBaseLineColor;
    [bgView addSubview:line_two];
    [line_two mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.novaPasswordTextfield.mas_bottom).offset(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.height.mas_equalTo(1);
    }];
    
    

    UILabel*confirmLable=[UILabel new];
    [bgView addSubview:confirmLable];
    confirmLable.text=@"确定密码";
    confirmLable.font=FontOfSize(12);
    confirmLable.textColor=[UIColor blackColor];
    [confirmLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_two.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(14);
    }];

    self.confirmPasswordTextfield=[UITextField new];
    [bgView addSubview:self.confirmPasswordTextfield];
    self.confirmPasswordTextfield.placeholder=@"8-16位，至少含数字/字母/字符2种组合";
    self.confirmPasswordTextfield.font=FontOfSize(12);
    [self.confirmPasswordTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_two.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(confirmLable.mas_right).offset(5);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(14);
    }];
    self.confirmPasswordTextfield.secureTextEntry=YES;

    UIButton*confirmShowPasswordButton=[UIButton new];
    [confirmShowPasswordButton setImage:IMAGE_NAMED(@"显示密码") forState:UIControlStateNormal];
    [confirmShowPasswordButton setImage:IMAGE_NAMED(@"不显示密码") forState:UIControlStateSelected];
    [bgView addSubview:confirmShowPasswordButton];
    [confirmShowPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_two.mas_top).offset(horizontalSpace);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(16);
    }];
    confirmShowPasswordButton.tag=2+defultTag;
    [confirmShowPasswordButton addTarget:self action:@selector(IsShowPasswordItemClicked:) forControlEvents:UIControlEventTouchUpInside];

   
    UIButton*forgetPasswordButton=[UIButton new];
    [forgetPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetPasswordButton setTitleColor:AppBaseTextColor3 forState:0];
    forgetPasswordButton.titleLabel.font=FontOfSize(12);
    [self.view addSubview:forgetPasswordButton];
    [forgetPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_bottom).offset(horizontalSpace);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(60);
    }];
    [forgetPasswordButton bk_whenTapped:^{
        [self forgetPasswordItemClicked];
    }];
    

}
-(void)forgetPasswordItemClicked{
     PSPasswordViewModel *ViewModel  =(PSPasswordViewModel *)self.viewModel;
    [self.navigationController pushViewController:[[PSForgetPasswordViewController alloc]initWithViewModel:ViewModel] animated:YES];
}

- (void) IsShowPasswordItemClicked:(UIButton *)sender{
    if (sender.tag==999) {
        self.oldPasswordTextfield.secureTextEntry=!
        self.oldPasswordTextfield.secureTextEntry;
        sender.selected=!sender.selected;
        return;
    }
    if (sender.tag==1000) {
        self.novaPasswordTextfield.secureTextEntry=!
        self.novaPasswordTextfield.secureTextEntry;
        sender.selected=!sender.selected;
        return;
    }
    if (sender.tag==1001) {
        self.confirmPasswordTextfield.secureTextEntry=!
        self.confirmPasswordTextfield.secureTextEntry;
        sender.selected=!sender.selected;
        return;
    }
   
   // sender.selected=!sender.selected;
}


-(void)completeButtonClick{
    PSPasswordViewModel *ViewModel  =(PSPasswordViewModel *)self.viewModel;
    ViewModel.phone_oldpassword=self.oldPasswordTextfield.text;
    ViewModel.phone_newPassword=self.novaPasswordTextfield.text;
    ViewModel.determine_password=self.confirmPasswordTextfield.text;
    [ViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        if (successful) {
            [ViewModel requestResetPasswordCompleted:^(PSResponse *response) {
                [PSTipsView showTips:@"重置密码成功!"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } failed:^(NSError *error) {
                [PSTipsView showTips:@"重置密码失败!"];
            }];
        }else{
            [PSTipsView showTips:tips];
        }
    }];

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
