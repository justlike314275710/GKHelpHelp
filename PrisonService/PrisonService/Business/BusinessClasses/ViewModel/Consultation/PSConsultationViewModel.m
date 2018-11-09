//
//  PSConsultationViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSConsultationViewModel.h"
#import "PSUploadConsultaionResponse.h"
#import "PSUploadConsultaionRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "PSConsultationRequest.h"
#import "PSConsultationResponse.h"
#import "PSLoadingView.h"
#import "PSConsultation.h"
#import "MJExtension.h"
@interface PSConsultationViewModel ()
@property (nonatomic, strong) PSUploadConsultaionRequest*uploadRequest;
@property (nonatomic , strong) PSConsultationRequest *consultationRequest;
@property (nonatomic , strong) NSMutableArray *items;
@property (nonatomic, strong) NSArray<PSConsultation,Optional> *consultationsArray;

@end
@implementation PSConsultationViewModel
{
    AFHTTPSessionManager *manager;
    
}
@synthesize dataStatus = _dataStatus;
- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 10;
    }
    return self;
}

-(void)requestAddConsultationCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    [[PSLoadingView sharedInstance]show];
        NSURL *url = [NSURL URLWithString:@"http://10.10.10.17:8086/customer/legal-advice"];
         NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
         request.HTTPMethod = @"POST";
         // 2.设置请求头
         [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
          NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
          [request addValue:token forHTTPHeaderField:@"Authorization"];
             // 3.设置请求体
        NSDictionary *json =
        [NSDictionary dictionaryWithObjectsAndKeys:
        self.attachments,@"attachments",
         [NSNumber numberWithInt:self.reward],@"reward",
         self.categories,@"categories",
         self.describe,@"description",
         self.lawyerId,@"lawyerId",
         nil];
        NSLog(@"%@",json);
         NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
         request.HTTPBody = data;
         // 4.发送请求
         NSURLSession*session=[NSURLSession sharedSession];
    NSURLSessionDataTask*task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
         self.statusCode=responseStatusCode;
        NSLog(@"%ld",(long)self.statusCode);
        if (error) {
            if (failedCallback) {
                failedCallback(error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [PSTipsView showTips:@"提交咨询失败"];
                [[PSLoadingView sharedInstance]dismiss];
            });
            
        }
        else{
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
             NSLog(@"上传图片返回url：%@",result);
            dispatch_async(dispatch_get_main_queue(), ^{
                [PSTipsView showTips:@"提交咨询成功"];
                [[PSLoadingView sharedInstance]dismiss];
            });
        }
    }];
    [task resume];

}




- (void)checkDataWithCallback:(CheckDataCallback)callback {
    if (self.categories.count == 0) {
        if (callback){
            callback(NO,@"请选择咨询类别");
        }
        return;
    }
    if (self.describe.length == 0) {
        if (callback){
            callback(NO,@"请输入您要描述的问题");
        }
        return;
    }
    if (self.reward<20) {
        if (callback){
            callback(NO,@"请输入金额");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
    

}







#define boundary @"6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm"
- (void)uploadConsultationImagesCompleted:(CheckDataCallback)callback{
     [[PSLoadingView sharedInstance]show];
    //1 创建请求
    NSURL *url = [NSURL URLWithString:@"http://10.10.10.17:8081/files"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";
    request.allHTTPHeaderFields = @{
                                    @"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
                                    };
    request.HTTPBody = [self makeBody:@"file" fileName:@"file" data:UIImageJPEGRepresentation(self.consultaionImage, 0.3)];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [request addValue:token forHTTPHeaderField:@"Authorization"];

    //2 发送异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        self.code=httpResponse.statusCode;
        if (data) {
                if (self.code==201) {
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    self.consultaionId=result[@"id"];
                    if (callback) {
                    callback(YES,self.consultaionId);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                          [[PSLoadingView sharedInstance]dismiss];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[PSLoadingView sharedInstance]dismiss];
                        [PSTipsView showTips:@"上传图片失败"];
                    });
                }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PSLoadingView sharedInstance]dismiss];
                [PSTipsView showTips:@"上传图片失败"];
            });
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
- (NSArray *)myAdviceArray{
    return _items;
}


- (void)refreshMyAdviceCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page = 1;
    self.items = nil;
    self.hasNextPage = NO;
    //self.dataStatus = PSDataInitial;
    [self requestMyAdviceCompleted:completedCallback failed:failedCallback];
    
    
}
- (void)loadMyAdviceCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
      self.page ++;
    [self requestMyAdviceCompleted:completedCallback failed:failedCallback];
}


-(void)requestMyAdviceCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
     manager=[AFHTTPSessionManager manager];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
      NSString *url = @"http://10.10.10.17:8086/customer/legal-advice";
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    NSDictionary*parmeters=@{
                             @"page":[NSString stringWithFormat:@"%ld",(long)self.page],
                             @"size":[NSString stringWithFormat:@"%ld",(long)self.pageSize]
                             };
    [manager GET:url parameters:parmeters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        if (responses.statusCode==200) {
             self.items = [NSMutableArray new];
            self.items=[PSConsultation mj_objectArrayWithKeyValuesArray:responseObject[@"content"]];
            if (self.items.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            if (completedCallback) {
                completedCallback(responseObject);
            }
          
        } else {
            if (self.page > 1) {
                self.page --;
                self.hasNextPage = YES;
            }else{
                self.dataStatus = PSDataError;
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
        if (self.page > 1) {
            self.page --;
            self.hasNextPage = YES;
        }else{
            self.dataStatus = PSDataError;
        }
    }];

    
}

@end
