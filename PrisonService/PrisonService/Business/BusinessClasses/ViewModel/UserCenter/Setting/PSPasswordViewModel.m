//
//  PSPasswordViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/20.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPasswordViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
@implementation PSPasswordViewModel
{
    AFHTTPSessionManager *manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.f;
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
        [ manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    return self;
}

- (void)requestPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSDictionary*parmeters=@{@"newPassword":self.phone_password,};
    NSString*url=[NSString stringWithFormat:@"%@/users/me/password",EmallHostUrl];
    [manager PUT:url parameters:parmeters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}
@end
