//
//  PSReportArticleViewModel.m
//  PrisonService
//
//  Created by kky on 2019/10/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSReportArticleViewModel.h"
#import <AFNetworking/AFNetworking.h>

@implementation PSReportArticleViewModel

- (void)requestReportArticleCompleted:(RequestDataTaskCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSDictionary *params = @{@"articleId":self.detailModel.id,
                             @"reportReason":self.reportReason,
                             @"type":@"1"};
    NSString *url = NSStringFormat(@"%@%@",ServerUrl,URL_api_reportArticle);
//    http://120.79.251.238:8022/ywgk-app/api/article/reportArticle
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            if (completedCallback) {
                completedCallback(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

@end
