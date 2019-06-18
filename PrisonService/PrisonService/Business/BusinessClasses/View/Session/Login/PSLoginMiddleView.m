//
//  PSLoginMiddleView.m
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLoginMiddleView.h"

@interface PSLoginMiddleView ()

@end

@implementation PSLoginMiddleView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        CGFloat sidePadding = RELATIVE_WIDTH_VALUE(15);

        _phoneTextField = [[PSUnderlineTextField alloc] initWithFrame:CGRectZero];
        _phoneTextField.font = AppBaseTextFont2;
        _phoneTextField.borderStyle = UITextBorderStyleNone;
        _phoneTextField.textColor = AppBaseTextColor1;
        _phoneTextField.textAlignment = NSTextAlignmentCenter;
       NSString*please_enter_phone_number=NSLocalizedString(@"please_enter_phone_number", nil);
        _phoneTextField.placeholder =please_enter_phone_number;
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        NSLog(@"%@",[LXFileManager readUserDataForKey:@"phoneNumber"]);
        if ([LXFileManager readUserDataForKey:@"phoneNumber"]) {
            _phoneTextField.text = [LXFileManager readUserDataForKey:@"phoneNumber"];
        }
        [self addSubview:_phoneTextField];
        [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(sidePadding);
            make.right.mas_equalTo(-sidePadding);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(44);
        }];
        
        UILabel*phoneLable=[UILabel new];
        NSString*phonenumber=NSLocalizedString(@"phoneNumber", nil);
        phoneLable.text=phonenumber;
        phoneLable.font= AppBaseTextFont2;
        [self addSubview:phoneLable];
        [phoneLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_phoneTextField.mas_top);
            make.left.mas_equalTo(_phoneTextField.mas_left);
            make.bottom.mas_equalTo(_phoneTextField.mas_bottom);
            make.width.mas_equalTo(70);
        }];
        phoneLable.numberOfLines=0;
 
        _codeTextField = [[PSUnderlineTextField alloc] initWithFrame:CGRectZero];
        _codeTextField.font = AppBaseTextFont2;
        _codeTextField.borderStyle = UITextBorderStyleNone;
        _codeTextField.textColor = AppBaseTextColor1;
        _codeTextField.textAlignment = NSTextAlignmentCenter;
        NSString*please_enter_verify_code=NSLocalizedString(@"please_enter_verify_code", nil);
        _codeTextField.placeholder = please_enter_verify_code;
        _codeTextField.keyboardType =UIKeyboardTypeDefault;
        [self addSubview:_codeTextField];
        [_codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(sidePadding);
            make.right.mas_equalTo(-sidePadding);
            make.top.mas_equalTo(_phoneTextField.mas_bottom);
            //make.bottom.mas_equalTo(0);
            make.height.equalTo(_phoneTextField);
        }];

        _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _codeButton.titleLabel.font = AppBaseTextFont2;
        [_codeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
        [_codeButton setTitleColor:AppBaseTextColor2 forState:UIControlStateDisabled];
        [_codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self addSubview:_codeButton];
        [_codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_codeTextField.mas_top);
            make.right.mas_equalTo(_codeTextField.mas_right);
            make.bottom.mas_equalTo(_codeTextField.mas_bottom);
            make.width.mas_equalTo(70);
        }];
        
        NSString*verifycode=NSLocalizedString(@"verifycode", nil);
       self.codeLable=[UILabel new];
       self.codeLable.text=verifycode;
       self.codeLable.font= AppBaseTextFont2;
        [self addSubview:self.codeLable];
        [self.codeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_codeTextField.mas_top);
            make.left.mas_equalTo(_codeTextField.mas_left);
            make.bottom.mas_equalTo(_codeTextField.mas_bottom);
            make.width.mas_equalTo(70);
        }];
        self.codeLable.numberOfLines=0;
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.titleLabel.font = AppBaseTextFont1;
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSString*login=NSLocalizedString(@"login", nil);
        [_loginButton setTitle:login forState:UIControlStateNormal];
//        [_loginButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
        [_loginButton setBackgroundColor:AppBaseTextColor3];
        [self addSubview:_loginButton];
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_codeTextField.mas_bottom).offset(70);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-50, 44));
        }];
    }
    return self;
}


@end
