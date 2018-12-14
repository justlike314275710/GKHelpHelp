//
//  PSMeetJailsnnmeViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/18.
//  Copyright © 2018年 calvin. All rights reserved.
//获取所属监狱内所有人
#import "PSCache.h"
#import "PSSessionManager.h"
#import "PSMeetJailsnnmeViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "MeetJails.h"
#import "MJExtension.h"
#import "PSSessionManager.h"
@implementation PSMeetJailsnnmeViewModel
{
    AFHTTPSessionManager *manager;
}

-(id)init{
    self=[super init];
    if (self) {
         _array=[NSMutableArray array];
        _prisons = [NSMutableArray array];
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.f;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"" password:@""];
        NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        
    }
    return self;
}
//获取单个监狱绑定的罪犯
- (void)requestMeetJailsterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/prisoners/getPrisoners",ServerUrl];
    
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
  
    NSString*jailId=prisonerDetail.jailId;
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*familiesId=self.session.families.id;
    NSDictionary*parmeters=@{
                             @"familyId":familiesId,
                             @"jailId":jailId
                             };
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parmeters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSArray*jailsArray=[MeetJails mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"prisoners"]];
            for (int i=0; i<jailsArray.count; i++) {
                MeetJails*model=jailsArray[i];
                 [_array addObject:model.name];
                [_prisons addObject:model];
            }
        self.jailsSting = [_array componentsJoinedByString:@"、"];
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)requestMeetAllJailsterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
    NSString*url=[NSString stringWithFormat:@"%@/api/families/bindPrisonersList",ServerUrl];

    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*familiesId=self.session.families.id;
    NSDictionary*parmeters=@{
                             @"familyId":familiesId,
                             };
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parmeters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray*jailsArray=[MeetPrisonserModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"bindList"]];
        for (int i=0; i<jailsArray.count; i++) {
            MeetPrisonserModel*model=jailsArray[i];
            [_prisons addObject:model];
        }
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
