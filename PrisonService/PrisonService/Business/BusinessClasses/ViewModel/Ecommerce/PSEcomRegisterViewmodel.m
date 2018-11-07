//
//  EcomLoginViewmodel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSEcomRegisterViewmodel.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"

@implementation PSEcomRegisterViewmodel
{
    AFHTTPSessionManager *manager;
}

-(id)init{
    self=[super init];
    if (self) {
        
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}


- (void)requestEcomRegisterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    NSString*url=[NSString stringWithFormat:@"%@/users/of-mobile",EmallHostUrl];
    NSDictionary*parmeters=@{
                             @"phoneNumber":self.phoneNumber,
                             @"verificationCode":self.verificationCode,
                             @"name":self.phoneNumber,//姓名是手机号码
                             @"group":@"CUSTOMER"
                             };
    [manager POST:url parameters:parmeters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        self.statusCode=responses.statusCode;
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }

    }];

}

- (void)requestVietnamEcomRegisterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/users/of-username",EmallHostUrl];
    NSDictionary*parmeters=@{
                             @"username":self.phoneNumber,
                             @"password":self.verificationCode,
                             @"name":self.phoneNumber,//姓名是手机号码
                             @"group":@"CUSTOMER"
                             };
    [manager POST:url parameters:parmeters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        self.statusCode=responses.statusCode;
        if (completedCallback) {
            completedCallback(responseObject);
        }
        NSLog(@"%@",responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


-(void)requestCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/users/%@/verification-codes/login",EmallHostUrl,self.phoneNumber];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        self.messageCode=responses.statusCode;
        if (completedCallback) {
            completedCallback(responseObject);
        }
   
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)checkDataWithCallback:(CheckDataCallback)callback {
    if (self.phoneNumber.length == 0) {
        if (callback) {
            NSString*please_enter_phone_number=NSLocalizedString(@"please_enter_phone_number", @"请输入手机号码");
            callback(NO,please_enter_phone_number);
        }
        return;
    }

    if (self.verificationCode.length == 0) {
        if (callback) {
            NSString*please_enter_verify_code=NSLocalizedString(@"please_enter_verify_code", @"请输入短信验证码");
            callback(NO,please_enter_verify_code);
        }
        return;
    }
  
    if (callback) {
        callback(YES,nil);
    }
}

- (void)checkPhoneDataWithCallback:(CheckDataCallback)callback {
    if (self.phoneNumber.length == 0) {
        if (callback) {
        NSString*please_enter_phone_number=NSLocalizedString(@"please_enter_phone_number", @"请输入手机号码");
            callback(NO,please_enter_phone_number);
        }
        return;
    }
    
    if (self.phoneNumber.length != 11) {
        if (callback) {
            callback(NO,@"请输入正确的手机号码");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}


@end
