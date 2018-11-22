//
//  PSVersonUpdateViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSVersonUpdateViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "UpDateModel.h"
//static NSString *const updateApi = @"https://www.yuwugongkai.com/ywgk-app/api/versions/page";
#define updateApi  [NSString stringWithFormat:@"%@/api/versions/page",ServerUrl]


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
    //服务器 -->2.1.9     本地->2.2.0
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    //NSString*AppstoreVersion=sender[@"version"];
    NSArray *localArray = [localVersion componentsSeparatedByString:@"."];
    NSArray *versionArray = [sender[@"version"] componentsSeparatedByString:@"."];
    NSInteger minArrayLength = MIN(localArray.count, versionArray.count);
    BOOL needUpdate = NO;
    for (int i = 0; i<minArrayLength; i++) {      //每一个位置比较
        NSString *localElement = localArray[i];
        NSString *appElement = versionArray[i];
        NSInteger localValue = localElement.integerValue;
        NSInteger appValue = appElement.integerValue;
        if (localValue<appValue) {     //9>0 需要更新
            needUpdate = YES;
            break;
        } else {
            if (i<minArrayLength-1&&localValue>appValue) {
                needUpdate = NO;
                break;
            }
            needUpdate = NO;
        }
    }
    
    if (needUpdate) {
        [self p_VersonUpdate];
    }
    
    /*
        if ((versionArray.count == 3) && (localArray.count == versionArray.count))
        {
            if ([localArray[0] intValue] > [versionArray[0] intValue]){
            [self updateVersion];
            }
           else if ([localArray[0] intValue] == [versionArray[0] intValue]) {
                if ([localArray[1] intValue] > [versionArray[1] intValue]) {
                    [self updateVersion];
                }
                else if ([localArray[1] intValue] == [versionArray[1] intValue]) {
                    if ([localArray[2] intValue] > [versionArray[2] intValue]) {
                        [self updateVersion];
                    }
                }
           }
        }
     */
}

-(void)updateVersion:(UpDateModel *)model{
    
    NSString *msg = model.des.length > 0 ? model.des : @"更新最新版本，优惠信息提前知";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"升级提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"现在升级"style:UIAlertActionStyleDestructive handler:^(UIAlertAction*action) {
        NSString *urlString = @"https://itunes.apple.com/cn/app/狱务通/id1102307635?mt=8";
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
        [[UIApplication sharedApplication]openURL:url];
        
    }];
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    UIAlertAction *cancerAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //非强制更新----取消----> 更新只出现一次(每一个版本)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"1" forKey:[NSString stringWithFormat:@"%@",localVersion]];
        [defaults synchronize];
    }];
    [alertController addAction:otherAction];
    //强制更新---->不要取消
    if ([model.isForce integerValue] != 1) {
        [alertController addAction:cancerAction];
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    //确认是否还需要弹出提示
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@",localVersion]];
    if (!value) {
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)p_VersonUpdate {
    
    NSLog(@"%@",updateApi);
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.f;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager GET:updateApi parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *msg = responseObject[@"msg"];
        NSInteger code = [responseObject[@"code"] integerValue];
        NSDictionary *datadic = responseObject[@"data"];
        NSMutableArray *mary = [NSMutableArray array];
        if (code == 200) {
            NSArray *dataAry = datadic[@"versions"];
            if (dataAry.count > 0) {
                @weakify(self);
                [dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    UpDateModel *model = [[UpDateModel alloc] initWithDictionary:obj error:nil];
                    [mary addObject:model];
                    //IOS
                    if ([model.id isEqualToString:@"3"]) {
                        @strongify(self);
                        [self updateVersion:model];
                        *stop = YES;
                    }
                }];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}


#pragma mark - UpdateModel

@end

