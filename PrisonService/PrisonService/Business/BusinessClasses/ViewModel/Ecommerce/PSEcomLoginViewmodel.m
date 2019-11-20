//
//  ecomLoginViewmodel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSEcomLoginViewmodel.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"


@implementation PSEcomLoginViewmodel
{
    AFHTTPSessionManager *manager;
}
-(id)init{
    self=[super init];
    if (self) {
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.f;

        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencode" forHTTPHeaderField:@"Content-Type"];
         [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"prison.trade.m" password:@"1688c4f69fc6404285aadbc996f5e429"];
    }
    return self;
}

//MARK:公共服务登录
-(void)postEcomLogin:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
   NSString*url=[NSString stringWithFormat:@"%@/oauth/token",EmallHostUrl];
    NSDictionary*parmeters=@{
                             @"username":self.username,
                             @"password":self.password,
                             @"grant_type":@"password",
                             @"mode":self.loginMode
                             };
    NSMutableString *paraString = [NSMutableString string];
    for (NSString *key in [parmeters allKeys]) {
        [paraString appendFormat:@"&%@=%@", key, parmeters[key]];
    }
    [paraString deleteCharactersInRange:NSMakeRange(0, 1)]; // 删除多余的&;号
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPMethod=@"POST";
//    NSString*uid=@"consumer.m.app";
//    NSString*cipherText=@"1688c4f69fc6404285aadbc996f5e429";
    NSString * part1 = [NSString stringWithFormat:@"%@:%@",AppUIdKey,AppUIdValue];
    NSData *data = [part1 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64Encoding];
   //  NSString *stringBase64 = [data base64EncodedStringWithOptions:0];
    NSString * authorization = [NSString stringWithFormat:@"Basic %@",stringBase64];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];

    NSURLSessionDataTask * dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        self.statusCode=responseStatusCode;
        NSLog(@"%@",responseObject);
        if (error) {
            if (failedCallback) {
                failedCallback(error);
            }
        }
        else {
            if (responseStatusCode == 200) {
                NSString*cookieToken=[self dictionaryToJson:responseObject];
                NSString*token=responseObject[@"access_token"];
                NSString*refresh_token=responseObject[@"refresh_token"];
                [LXFileManager removeUserDataForkey:@"access_token"];
                [LXFileManager removeUserDataForkey:@"refresh_token"];
                [LXFileManager removeUserDataForkey:@"cookieToken"];
                [LXFileManager saveUserData:token forKey:@"access_token"];
                [LXFileManager saveUserData:refresh_token forKey:@"refresh_token"];
                [LXFileManager saveUserData:cookieToken forKey:@"cookieToken"];
            }
            if (completedCallback) {
                completedCallback(responseObject);
            }
        }
    }];
    [dataTask resume];
}
#pragma mark - 查询当前IM用户
- (void)loginGetImifnoComplete:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
    manager=[AFHTTPSessionManager manager];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    NSString*url=[NSString stringWithFormat:@"%@/im/users/me",EmallHostUrl];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        if (responses.statusCode == 200) {
            //云信账号密码
            NSString*account =responseObject[@"account"];
            NSString*token  =responseObject[@"token"];
            NSString*username = responseObject[@"username"];
            [LXFileManager removeUserDataForkey:@"account"];
            [LXFileManager removeUserDataForkey:@"token"];
            [LXFileManager removeUserDataForkey:@"username"];
            [LXFileManager saveUserData:account forKey:@"account"];
            [LXFileManager saveUserData:token forKey:@"token"];
            [LXFileManager saveUserData:username forKey:@"username"];
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


-(NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString*newString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    newString = [newString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //去除掉首尾的空白字符和换行字符使用
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return  newString;
       
}
#pragma mark - 刷新token
-(void)postRefreshEcomLogin:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*Url=[NSString stringWithFormat:@"%@/oauth/token",EmallHostUrl];
    NSString*refresh_token=[LXFileManager readUserDataForKey:@"refresh_token"];
    NSDictionary*parmeters=@{
                             @"refresh_token":refresh_token,
                             @"grant_type":@"refresh_token"
                             };
    NSMutableString *paraString = [NSMutableString string];
    for (NSString *key in [parmeters allKeys]) {
        [paraString appendFormat:@"&%@=%@", key, parmeters[key]];
    }
    [paraString deleteCharactersInRange:NSMakeRange(0, 1)]; // 删除多余的&;号
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:Url]];
    [request setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPMethod=@"POST";
//    NSString*uid=@"consumer.m.app";
//    NSString*cipherText=@"1688c4f69fc6404285aadbc996f5e429";
    NSString * part1 = [NSString stringWithFormat:@"%@:%@",AppUIdKey,AppUIdValue];
    NSData *data = [part1 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64Encoding];
    //  NSString *stringBase64 = [data base64EncodedStringWithOptions:0];
    NSString * authorization = [NSString stringWithFormat:@"Basic %@",stringBase64];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        self.statusCode=responseStatusCode;
        if (error) {
            if (failedCallback) {
                failedCallback(error);
            }
        }
        else {
            if (completedCallback) {
                completedCallback(responseObject);
            }
            if (responseStatusCode == 200) {
                NSString*token=responseObject[@"access_token"];
                NSString*refresh_token=responseObject[@"refresh_token"];
                
                [LXFileManager removeUserDataForkey:@"access_token"];
                [LXFileManager saveUserData:token forKey:@"access_token"];
                [LXFileManager removeUserDataForkey:@"refresh_token"];
                [LXFileManager saveUserData:refresh_token forKey:@"refresh_token"];
            
            }else {
                [PSTipsView showTips:@"电子商务登陆失败"];
            }
        }
    }];
    
    [dataTask resume];
}
    
  


@end
