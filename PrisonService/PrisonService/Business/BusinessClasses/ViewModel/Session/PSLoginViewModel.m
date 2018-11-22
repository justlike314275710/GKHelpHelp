//
//  PSLoginViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLoginViewModel.h"
#import "PSLoginRequest.h"
#import "PSSendCodeRequest.h"
#import "PSCheckCodeRequest.h"
#import "PSWhiteListRequest.h"
#import "PSValidTouristResponse.h"
#import "PSValidTouristRequest.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "PSBusinessConstants.h"
#import "PSSessionManager.h"
#import "AppDelegate.h"
@interface PSLoginViewModel ()

@property (nonatomic, strong) PSSendCodeRequest *sendCodeRequest;
@property (nonatomic, strong) PSLoginRequest *loginRequest;
@property (nonatomic, strong) PSCheckCodeRequest *checkCodeRequest;
@property (nonatomic, strong) PSWhiteListRequest *whiteListRequest;
@property (nonatomic, strong) PSValidTouristRequest *validTouristRequest;

@end

@implementation PSLoginViewModel
{
    AFHTTPSessionManager *manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.agreeProtocol = YES;
    }
    return self;
}
- (void)checkDataWithCallback:(CheckDataCallback)callback {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appdelegate.IS_NetWork == NO) {
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

    if (self.messageCode.length == 0) {
        if (callback) {
            NSString*please_enter_verify_code=NSLocalizedString(@"please_enter_verify_code", @"请输入短信验证码");
            callback(NO,please_enter_verify_code);
        }
        return;
    }
    if (!self.agreeProtocol) {
        if (callback) {
        NSString*read_agree_usageProtocol=NSLocalizedString(@"read_agree_usageProtocol", @"请阅读并同意《狱务通使用协议》");
            callback(NO,read_agree_usageProtocol);
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
    if (callback) {
        callback(YES,nil);
    }
}

- (void)setSession:(PSUserSession *)session {
    _session = session;
}

- (void)requestCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.sendCodeRequest = [PSSendCodeRequest new];
    self.sendCodeRequest.phone = @"15111212933";
    [self.sendCodeRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
       
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
       
    }];
}



- (void)checkCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.checkCodeRequest = [PSCheckCodeRequest new];
    self.checkCodeRequest.phone = self.phoneNumber;
    self.checkCodeRequest.code = self.messageCode;
    [self.checkCodeRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
        
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)loginCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    manager=[AFHTTPSessionManager manager];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];

    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    NSString*url=[NSString stringWithFormat:@"%@/families/validTourist",ServerUrl];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.code=[responseObject[@"code"]integerValue];
        self.message=responseObject[@"msg"];
        if ([responseObject[@"code"]integerValue] == 200) {
            if (responseObject[@"data"]) {
                self.session =[[PSUserSession alloc]initWithDictionary:responseObject[@"data"] error:nil];
                //[PSSessionManager sharedInstance].session=self.session;
            }
        }
        if (completedCallback) {
            completedCallback(responseObject);
        }
        NSLog(@"***%@",responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
    
}

- (void)checkWhiteListCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.whiteListRequest = [PSWhiteListRequest new];
    self.whiteListRequest.phone = self.phoneNumber;
    [self.whiteListRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


//-(void)requestValidCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
//    NSString*url=[NSString stringWithFormat:@"%@/families/validTourist",ServerUrl];
//    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        self.code=[responseObject[@"code"]integerValue];
//        if ([responseObject[@"code"]integerValue] == 200) {
//            if (responseObject[@"data"]) {
//                self.session = [PSUserSession mj_objectWithKeyValues:responseObject[@"data"]];
//            }
//        }
//        if (completedCallback) {
//            completedCallback(responseObject);
//        }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failedCallback) {
//            failedCallback(error);
//        }
//    }];
//}

@end
