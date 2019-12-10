//
//  PSForgetPasswordViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/6/3.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSForgetPasswordViewController.h"
#import "PSSessionManager.h"
#import "PSCountdownManager.h"
#import "PSPasswordViewModel.h"
#import "PSForgetNextViewController.h"
@interface PSForgetPasswordViewController ()<PSCountdownObserver>
@property (nonatomic , strong) UIButton *codeButton;
@property (nonatomic , strong) UITextField*codeTextField;
@property (nonatomic, assign) NSInteger seconds;
@end

@implementation PSForgetPasswordViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"填写验证码";
        [[PSCountdownManager sharedInstance] addObserver:self];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    // Do any additional setup after loading the view.
}
-(void)renderContents{
    self.view.backgroundColor=[UIColor colorWithRed:249/255.0 green:248/255.0 blue:254/255.0 alpha:1.0];
    CGFloat horizontalSpace = 15.0f;
    NSString*phone=[LXFileManager readUserDataForKey:@"phoneNumber"];
    UILabel*tipsLable=[UILabel new];
    tipsLable.text=[NSString stringWithFormat:@"短信验证码已发送至手机上，手机号为:%@",phone];
    tipsLable.font=FontOfSize(12);
    tipsLable.textColor=AppBaseTextColor1;
    [self.view addSubview:tipsLable];
    [tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(20);
    }];
    
    UIView*bgView=[UIView new];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLable.mas_bottom).offset(horizontalSpace);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    UILabel*codeLable=[UILabel new];
    codeLable.text=@"验证码";
    codeLable.font=FontOfSize(12);
    codeLable.textColor=[UIColor blackColor];
    [bgView addSubview:codeLable];
    [codeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_top).offset(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(14);
    }];
    
    
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _codeTextField.font = AppBaseTextFont2;
    _codeTextField.textColor = AppBaseTextColor1;
    _codeTextField.textAlignment = NSTextAlignmentLeft;
    _codeTextField.placeholder = @"请输入验证码";
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [bgView addSubview:_codeTextField];
    [_codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(codeLable.mas_right);
        make.right.mas_equalTo(-horizontalSpace);
        make.top.mas_equalTo(bgView.mas_top).offset(horizontalSpace);
        make.height.mas_equalTo(14);
    }];


    _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeButton.titleLabel.font = AppBaseTextFont2;
    [_codeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    [_codeButton setTitleColor:AppBaseTextColor2 forState:UIControlStateDisabled];
    [_codeButton setTitle:@"|获取验证码" forState:UIControlStateNormal];
    [bgView addSubview:_codeButton];
    [_codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_top).offset(horizontalSpace);
        make.right.mas_equalTo(_codeTextField.mas_right);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(80);
    }];
    [_codeButton bk_whenTapped:^{
         [self requestMessageCode];
        _codeButton.enabled = NO;
        
    }];
    
    UIButton*nextTipButton=[UIButton new];
    [nextTipButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextTipButton setTitleColor:[UIColor whiteColor] forState:0];
    ViewRadius(nextTipButton, 4);
    [nextTipButton setBackgroundColor:AppBaseTextColor3];
    nextTipButton.titleLabel.font=FontOfSize(14);
    [self.view addSubview:nextTipButton];
    [nextTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_bottom).offset(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.height.mas_equalTo(44);
    }];
    [nextTipButton bk_whenTapped:^{
        [self nextTipItemClicked];
    }];
    
}

-(void)nextTipItemClicked{
     PSPasswordViewModel *ViewModel  =(PSPasswordViewModel *)self.viewModel;
     ViewModel.VerificationCode=_codeTextField.text;
    if (_codeTextField.text.length==0) {
        [PSTipsView showTips:@"请输入验证码!"];
        return;
    }
    [ViewModel requestCodeVerificationCompleted:^(PSResponse *response) {
        [self.navigationController pushViewController:[[PSForgetNextViewController alloc]initWithViewModel:ViewModel] animated:YES];
    } failed:^(NSError *error) {
        [PSTipsView showTips:@"验证码输入错误!"];
    }];
}


- (void)requestMessageCode {
    PSPasswordViewModel *ViewModel  =(PSPasswordViewModel *)self.viewModel;
    [ViewModel requestCodeCompleted:^(PSResponse *response) {
        if (ViewModel.Code==201||ViewModel.Code==204) {
            [PSTipsView showTips:@"已发送"];
            self.seconds=60;
        }else{
            [PSTipsView showTips:@"获取验证码失败"];
        }
    } failed:^(NSError *error) {
         [self showNetError:error];
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
