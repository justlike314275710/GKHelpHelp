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
#import "AppDelegate.h"

@implementation PSEcomRegisterViewmodel
{
    AFHTTPSessionManager *manager;
}

-(id)init{
    self=[super init];
    if (self) {
        
        manager=[AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer.timeoutInterval = 5.0f;
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}

//注册手机用户
- (void)requestEcomRegisterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    NSString*url=[NSString stringWithFormat:@"%@%@",EmallHostUrl,URL_public_users_of_mobile];
    NSDictionary*parmeters=@{
                             @"phoneNumber":self.phoneNumber,
                             @"verificationCode":self.verificationCode,
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
    NSString*url=[NSString stringWithFormat:@"%@/sms/verification-codes",EmallHostUrl];
    NSDictionary *params = @{@"phoneNumber":self.phoneNumber};
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appdelegate.isHaveNet) {
        if (callback) {
            NSString*No_network_connection=NSLocalizedString(@"No network connection", @"无网络连接");
            callback(NO,No_network_connection);
        }
        return;
    }
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
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appdelegate.isHaveNet) {
        if (callback) {
            NSString*No_network_connection=NSLocalizedString(@"No network connection", @"无网络连接");
            callback(NO,No_network_connection);
        }
        return;
    }
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
