//
//  PSPasswordViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/20.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"

@interface PSPasswordViewModel : PSViewModel
@property (nonatomic , strong) NSString *phone_oldpassword;
@property (nonatomic , strong) NSString *phone_newPassword;
@property (nonatomic , strong) NSString *determine_password;

@property (nonatomic, assign) NSInteger Code;//返回码
@property (nonatomic, strong) NSString  *errorMsg;
@property (nonatomic, strong) NSString  *VerificationCode;//短信验证码
/**
 第一次我的密码 验证码格式正则匹配校验
 */
- (void)checkPhoneDataWithCallback:(CheckDataCallback)callback ;

/**
 忘记密码 验证码格式正则匹配校验
 */
- (void)checkNewPhoneDataWithCallback:(CheckDataCallback)callback ;

/**
修改我的密码 验证码格式正则匹配校验
 */
- (void)checkDataWithCallback:(CheckDataCallback)callback ;
/**
 获取是否设置了密码
 */
- (void)requestBoolPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
/**
第一次设置密码
 */
- (void)requestPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
/**
修改我的密码
 */
- (void)requestResetPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
/**
根据短信验证码重置我的密码
 */
- (void)requestByVerficationCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
/**
 获取验证码
 */
-(void)requestCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
/**
校验验证码
 */
-(void)requestCodeVerificationCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;


@end
