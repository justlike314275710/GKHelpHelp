//
//  PSAccountViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAccountViewModel.h"
#import "PSSessionManager.h"
#import "NSString+Date.h"
#import "NSDate+Components.h"
#import "PSCache.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"
#import "UIImage+WLCompress.h"

@implementation PSAccountViewModel
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
        [manager.requestSerializer setValue:[PSSessionManager sharedInstance].session.token forHTTPHeaderField:@"Authorization"];

        
        
    }
    return self;
}

- (void)requestAccountBasicinfoCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*url=[NSString stringWithFormat:@"%@/families/basicInfo",ServerUrl];
    NSDictionary*parmeters=@{
                             @"familyId":self.session.families.id
                             };
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [ manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parmeters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *items = [NSMutableArray array];
        
        PSAccountInfoItem *sexItem = [PSAccountInfoItem new];
        NSString*genderSting=NSLocalizedString(@"gender", @"性别");
        sexItem.itemName = genderSting;
        sexItem.itemIconName = @"userCenterAccountSex";
        NSString*man=NSLocalizedString(@"man", @"男");
        NSString*weomen=NSLocalizedString(@"women", @"女");
        NSString*gender=responseObject[@"data"][@"families"][@"gender"];
        if ([gender isEqualToString:@"男"]) {
            sexItem.infoText=man;
        }
        else{
            sexItem.infoText=weomen;
        }
        //sexItem.infoText = gender?gender:@"未填写";
        [items addObject:sexItem];

        
        PSAccountInfoItem *phoneItem = [PSAccountInfoItem new];
        NSString*Contact_phonenumber=NSLocalizedString(@"Contact_phonenumber", @"联系电话");
        phoneItem.itemName =Contact_phonenumber;
        phoneItem.itemIconName = @"userCenterAccountPhone";
        phoneItem.infoText = [PSSessionManager sharedInstance].session.families.phone;
        [items addObject:phoneItem];
        
        PSAccountInfoItem *relationItem = [PSAccountInfoItem new];
        NSString*Home_address=NSLocalizedString(@"Home_address", @"家庭地址");
        relationItem.itemName = Home_address;
        relationItem.itemIconName = @"userCenterAccountAddress";
        NSString*address=responseObject[@"data"][@"families"][@"homeAddress"];
        if (isNull(address)) {
            relationItem.infoText=@"未填写";
        } else {
            relationItem.infoText = address;
        }
        //relationItem.infoText = address?address:@"未填写";
        [items addObject:relationItem];
        
        
        PSAccountInfoItem *nameItem = [PSAccountInfoItem new];
        NSString*Zip_code=NSLocalizedString(@"Zip_code", @"邮编");
        nameItem.itemName = Zip_code;
        nameItem.itemIconName = @"userCenterAccountEmail";
        NSString*email=responseObject[@"data"][@"families"][@"postalCode"];
        if (isNull(email)) {
            nameItem.infoText=@"未填写";
        }
        else{
            nameItem.infoText = email;
        }
        [items addObject:nameItem];
        
        _infoItems = items;
        
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            if (data) {
                id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *msg = body[@"message"];
            }
            if (failedCallback) {
                failedCallback(error);
            }
            failedCallback(error);
            
        }
    }];
}

//上传头像
#pragma mark - UploadImage
#define boundary @"6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm"
- (void)uploadUserAvatarImageCompleted:(CheckDataCallback)callback {

    //1 创建请求
    UIImage *image = self.avatarImage;
    NSString*urlSting=[NSString stringWithFormat:@"%@%@",EmallHostUrl,URL_upload_avatar];
    NSURL *url = [NSURL URLWithString:urlSting];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"put";
    request.allHTTPHeaderFields = @{
                                    @"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
                                    };
    NSData *compressData = [image compressWithLengthLimit:500.0f * 1024.0f];
    request.HTTPBody = [self makeBody:@"file" fileName:@"fileName" data:compressData];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [request addValue:token forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSInteger code =httpResponse.statusCode;
        NSLog(@"平台%ld",code);
//        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (data) {
            if (code==201||code==204) {
                if (callback) callback(YES,@"头像修改成功");
            } else {
                if (callback) callback(NO,@"头像修改失败");
            }
        }
        else{
            if (callback) callback(NO,@"头像修改失败");
        }
    }];
}

//获取自己头像
-(void)getUserAvatarImageCompleted:(SucessImageBlock)completedCallback
                            failed:(RequestDataFailed)failedCallback{
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/png",@"image/jpeg",nil];
    NSString*urlSting=[NSString stringWithFormat:@"%@%@",EmallHostUrl,URL_get_userAvatar];
    
    [manager GET:urlSting parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *imageData = [responseObject mutableCopy];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image&&completedCallback) {
            completedCallback(image);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (data) {
            id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",body);
        }
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (NSData *)makeBody:(NSString *)fieldName fileName:(NSString *)fileName data:(NSData *)fileData{
    NSMutableData *data = [NSMutableData data];
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"--%@\r\n",boundary];
    [str appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",fieldName,fileName];
    [str appendString:@"Content-Type: image/jpeg\r\n\r\n"];
    [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:fileData];
    NSString *tail = [NSString stringWithFormat:@"\r\n--%@--",boundary];
    [data appendData:[tail dataUsingEncoding:NSUTF8StringEncoding]];
    return [data copy];
}

//获取用户头像
-(void)getAvatarImageUserName:(NSString *)username Completed:(SucessImageBlock)completedCallback
                       failed:(RequestDataFailed)failedCallback {
    
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/png",@"image/jpeg",nil];
    NSString*urlSting=[NSString stringWithFormat:@"%@%@%@",EmallHostUrl,URL_get_Avatar,username];
    urlSting = [urlSting stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager GET:urlSting parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *imageData = [responseObject mutableCopy];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image&&completedCallback) {
            completedCallback(image);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (data) {
            id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",body);
        }
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


@end
