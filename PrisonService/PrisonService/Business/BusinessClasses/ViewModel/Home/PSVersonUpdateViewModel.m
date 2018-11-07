//
//  PSVersonUpdateViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSVersonUpdateViewModel.h"

@implementation PSVersonUpdateViewModel

-(void)VersonUpdate{
    //定义的app的地址
    NSString *urld = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",@"1102307635"];
    //网络请求app的信息，主要是取得我说需要的Version
    NSURL *url = [NSURL URLWithString:urld];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) { NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            //data是有关于App所有的信息
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            
            if ([[receiveDic valueForKey:@"resultCount"] intValue]>0)
            { [receiveStatusDic setValue:@"1" forKey:@"status"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"] forKey:@"version"];
                //请求的有数据，进行版本比较
                [self performSelectorOnMainThread:@selector(receiveData:) withObject:receiveStatusDic waitUntilDone:NO]; }
            else{ [receiveStatusDic setValue:@"-1" forKey:@"status"]; } }
        else{ [receiveStatusDic setValue:@"-1" forKey:@"status"]; } }];
    [task resume];
    
}

-(void)receiveData:(id)sender { //获取APP自身版本号CFBundleShortVersionString
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    //NSString*AppstoreVersion=sender[@"version"];
    NSArray *localArray = [localVersion componentsSeparatedByString:@"."];
    NSArray *versionArray = [sender[@"version"] componentsSeparatedByString:@"."];
    NSInteger minArrayLength = MIN(localArray.count, versionArray.count);
    BOOL needUpdate = NO;
    for (int i = 0; i<minArrayLength; i++) {
        NSString *localElement = localArray[i];
        NSString *appElement = versionArray[i];
        NSInteger localValue = localElement.integerValue;
        NSInteger appValue = appElement.integerValue;
        if (localValue<appValue) {
            needUpdate = YES;
            break;
        } else {
            needUpdate = NO;
        }
    }
    
    if (needUpdate) {
        [self updateVersion];
    }
    
    //    if ((versionArray.count == 3) && (localArray.count == versionArray.count))
    //    {
    //        if ([localArray[0] intValue] > [versionArray[0] intValue]){
    //        [self updateVersion];
    //        }
    //       else if ([localArray[0] intValue] == [versionArray[0] intValue]) {
    //            if ([localArray[1] intValue] > [versionArray[1] intValue]) {
    //                [self updateVersion];
    //            }
    //            else if ([localArray[1] intValue] == [versionArray[1] intValue]) {
    //                if ([localArray[2] intValue] > [versionArray[2] intValue]) {
    //                    [self updateVersion];
    //                }
    //            }
    //       }
    //    }
}

-(void)updateVersion{
    NSString *msg = [NSString stringWithFormat:@"更新最新版本，优惠信息提前知"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"升级提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"现在升级"style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action) {
        NSString *urlString = @"https://itunes.apple.com/cn/app/狱务通/id1102307635?mt=8";
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
        [[UIApplication sharedApplication]openURL:url];
        
    }];
    [alertController addAction:otherAction];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
}

@end
