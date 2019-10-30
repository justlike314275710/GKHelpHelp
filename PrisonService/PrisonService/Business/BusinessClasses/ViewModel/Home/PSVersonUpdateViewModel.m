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

#define updateApi  [NSString stringWithFormat:@"%@/api/versions/page",ServerUrl]
#define errorMsg   @"软件维护中,暂停使用"
@interface PSVersonUpdateViewModel(){
    NSString *_localVerson;      //本地版本
    NSString *_appStoreVerson;   //appStore版本
}
@end

@implementation PSVersonUpdateViewModel

-(void)jundgeVersonUpdate{
    
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

-(void)receiveData:(id)sender {
    
    //获取APP自身版本号CFBundleShortVersionString
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    _appStoreVerson = sender[@"version"];
    //是否需要版本更新
    BOOL needUpdate = [self updataVerson1:localVersion verson2:_appStoreVerson];
    if (needUpdate) { //更新
        [self p_versonUpdate:YES];
    } else {          //不需要更新
        [self p_versonUpdate:NO];
    }
}

#pragma mark - 版本号比较
/**
 verson1>verson2 return NO;
 verson1<verson2 return YES;
//服务器 -->2.1.9     本地->2.2.0
 */
-(BOOL)updataVerson1:(NSString *)verson1
       verson2:(NSString *)verson2 {
    
    NSArray *verson1Array =  [verson1 componentsSeparatedByString:@"."];
    NSArray *version2Array = [verson2 componentsSeparatedByString:@"."];
    BOOL needUpdate = NO;
    NSInteger minArrayLength = MIN(verson1Array.count, version2Array.count);
    for (int i = 0; i<minArrayLength; i++) {      //每一个位置比较
        NSString *localElement = verson1Array[i];
        NSString *appElement = version2Array[i];
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
    return needUpdate;
}

#pragma mark - 更新提示
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
    if ([model.isForce integerValue]==1) {
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    } else {
        //确认是否还需要弹出提示
        NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@",localVersion]];
        if (!value) {
            [window.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - 异常提示OR不提示
-(void)showErrorMsg:(UpDateModel *)model {
    //(当后台版本>应用市场版本)&&强制更新 ->提示        软件维护中,暂停使用
    NSString *backVerson = model.versionCode;
    BOOL isShowError = [self updataVerson1:_appStoreVerson verson2:backVerson];
    BOOL isForce = [model.isForce boolValue];
    if (isShowError&&isForce) {  //提示错误
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //退出app
//            [self exitApplication];
        }];
        [alertController addAction:otherAction];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)exitApplication{
//    -Wundeclared-selector"      //运行一个不存在的方法,退出界面更加圆滑
    [self performSelector:@selector(notExistCall)];
    abort();
#pragma clang diagnostic pop
    
}
    
    

- (void)p_versonUpdate:(BOOL)update {
    
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
                    if (model) [mary addObject:model];
                    //IOS-->更新
                    if ([model.id isEqualToString:@"3"]&&update) {
                        @strongify(self);
                        [self updateVersion:model];
                        *stop = YES;
                    }
                    //不更新---->异常提示
                    if ([model.id isEqualToString:@"3"]&&!update) {
                        @strongify(self);
                        [self showErrorMsg:model];
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

