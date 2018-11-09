//
//  PSAccountEmailViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/23.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "PSCache.h"
#import "AFNetworking.h"
#import "PSAccountEditEmailViewModel.h"
#import "PSBusinessConstants.h"
#import "PSSessionManager.h"
@implementation PSAccountEditEmailViewModel
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
        manager.requestSerializer.timeoutInterval = 10.f;

        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}
- (void)requestAccountEmailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    
    NSString*Url=[NSString stringWithFormat:@"%@/families/updatePostalCode?familyId=%@&postalCode=%@",ServerUrl,self.session.families.id,self.email];
    Url = [Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager PUT:Url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        self.msg=responseObject[@"msg"];
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
