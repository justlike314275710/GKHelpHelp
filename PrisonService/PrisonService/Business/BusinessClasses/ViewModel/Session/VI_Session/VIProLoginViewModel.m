//
//  VIProLoginViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIProLoginViewModel.h"
#import "PSBusinessConstants.h"
#import <AFNetworking/AFNetworking.h>
#import "MJExtension.h"
#import "PSUUIDs.h"
@interface VIProLoginViewModel()

@property (nonatomic, strong) NSMutableArray *logs;

@end
@implementation VIProLoginViewModel

- (NSArray *)accountNumbers{
    return _logs;
}
- (void)requestVietnamPreLoginCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    
    NSString*url=[NSString stringWithFormat:@"%@/families/vietnamPreLogin",ServerUrl];
    //    NSString *utf = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary*parmeters=@{
                             @"phone":self.phoneNumber,
                             @"loginPwd":self.loginPwd
                             };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:parmeters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.logs=[PSUUIDs mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"families"]];
        self.msg=responseObject[@"msg"];
        self.code=[responseObject[@"code"] integerValue];
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
