//
//  PSPhonePassport.m
//  Start
//  
//  Created by Glen on 16/6/23.
//  Copyright © 2016年 DingSNS. All rights reserved.
//

#import "PSPhonePassport.h"

@interface PSPhonePassport ()

@property (nonatomic, strong) NSString *loginVerifyCode; //验证码

@end

@implementation PSPhonePassport
@synthesize loginID = _loginID;
@synthesize usertoken = _usertoken;
@synthesize type = _type;
@synthesize newUser = _newUser;
@synthesize imId = _imId;
@synthesize imToken = _imToken;

- (id)init {
    self = [super init];
    if (self) {
        _type = PSPassportPhone;
    }
    return self;
}

- (id)initWithLoginID:(NSString *)loginID smsCode:(NSString *)smsCode {
    self = [super init];
    if (self) {
        _loginID = loginID;
        _loginVerifyCode = smsCode;
    }
    return self;
}


- (id)initWithPhoneNum:(NSString *)phone {
    self = [super init];
    if (self) {
        _loginID = phone;
    }
    return self;
}

- (void)setLoginID:(NSString *)loginID {
    _loginID = loginID;
}

- (void)setUsertoken:(NSString *)usertoken {
    _usertoken = usertoken;
}

- (void)setType:(PSPassportType)type {
    _type = type;
}

- (void)setNewUser:(BOOL)newUser {
    _newUser = newUser;
}

- (void)setImId:(NSString *)imId {
    _imId = imId;
}

- (void)setImToken:(NSString *)imToken {
    _imToken = imToken;
}

- (void)doLogin {
    if ([_loginID length] == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(passportLoginFailed:error:)]) {
            [self.delegate passportLoginFailed:self error:[NSError errorWithDomain:[NSString stringWithFormat:@"请输入手机号码"] code:406 userInfo:nil]];
            return;
        }
    }
    if ([_loginVerifyCode length] == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(passportLoginFailed:error:)]) {
            [self.delegate passportLoginFailed:self error:[NSError errorWithDomain:[NSString stringWithFormat:@"请输入短信验证码"] code:406 userInfo:nil]];
            return;
        }
    }
}

/**
 *  获取短信验证码
 */
- (void)getAuthCode{
    if ([_loginID length] == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(passportLoginFailed:error:)]) {
            [self.delegate passportGetAuthCodeFailed:self error:[NSError errorWithDomain:[NSString stringWithFormat:@"请输入手机号码"] code:406 userInfo:nil]];
            return;
        }
        
    }
}

/**
 *  完善个人信息
 */
- (void)doRegisterUserInfo{
    
}


- (void)doLogout {
    _loginID = nil;
    _loginVerifyCode = nil;
    _usertoken = nil;
    _imId = nil;
    _imToken = nil;
}


- (void)cancelAllRequests {
    
}

- (void)dealloc {
    [self cancelAllRequests];
}

@end
