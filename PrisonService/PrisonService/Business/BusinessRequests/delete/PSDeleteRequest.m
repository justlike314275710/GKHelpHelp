//
//  PSDeleteRequest.m
//  PrisonService
//
//  Created by kky on 2018/12/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSDeleteRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"


@implementation PSDeleteRequest

+ (void)requestPUTWithURLStr:(NSString *)urlStr paramDic:(NSDictionary *)paramDic  finish:(void(^)(id responseObject))finish enError:(void(^)(NSError *error))enError{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain", nil];
    [manager.requestSerializer setValue:AppToken forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager DELETE:urlStr parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *code = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            finish(responseObject);
        }else{
            NSString *errmsg = [responseObject objectForKey:@"msg"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        enError(error);
    }];
}


@end
