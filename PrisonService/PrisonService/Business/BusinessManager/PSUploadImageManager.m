//
//  PSUploadImageManager.m
//  PrisonService
//
//  Created by kky on 2019/10/29.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSUploadImageManager.h"
#import "UIImage+WLCompress.h"

@implementation PSUploadImageManager

+ (PSUploadImageManager *)uploadImageManager{
    static PSUploadImageManager *uploadManager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken,^{
        if (!uploadManager) {
            uploadManager = [[self alloc] init];
        }
    });
    return uploadManager;
}

#define boundary @"6o2knFse3p53ty9dmcQvWAIx1zInP11uCfbm"
-(void)uploadPublicImages:(UIImage*)images completed:(CheckDataCallback)callback{
  
    //1 创建请求
    NSString*urlSting=[NSString stringWithFormat:@"%@/files?type=PUBLIC",EmallHostUrl];
    NSURL *url = [NSURL URLWithString:urlSting];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";
    request.allHTTPHeaderFields = @{
                                    @"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
                                    };
    NSData *compressData = [images compressWithLengthLimit:500.0f * 500.0f];
    request.HTTPBody = [self makeBody:@"file" fileName:@"file" data:compressData];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [request addValue:token forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        self.code=httpResponse.statusCode;
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (data) {
            if (self.code==201) {
                id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if (callback) {
                    callback(YES,result[@"filename"]);
                }
            } else {
                if (callback) {
                    callback(NO,@"上传图片失败");
                }
            }
        }
        else{
            if (callback) {
                callback(NO,@"上传图片失败");
            }
        }
        
    }];
}

- (NSData *)makeBody:(NSString *)fieldName fileName:(NSString *)fileName data:(NSData *)fileData{
    NSMutableData *data  = [NSMutableData data];
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"--%@\r\n",boundary];
    [str appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",fieldName,fileName];
    [str appendString:@"Content-Type: image/jpeg\r\n\r\n"];
    [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:fileData];
    NSString *tail       = [NSString stringWithFormat:@"\r\n--%@--",boundary];
    [data appendData:[tail dataUsingEncoding:NSUTF8StringEncoding]];
    return [data copy];
}

@end
