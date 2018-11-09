//
// Created by William Zhao on 13-6-28.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "PSHttpClient.h"
#import <AFNetworking/AFNetworking.h>
#import "PSNetConstants.h"
#import "PSParameters.h"
#import "PSMacro.h"

@interface PSHttpClient()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end

@implementation PSHttpClient {
    PSMutableParameters *_appendParameters;
    PSMutableParameters *_parameters;
    PSMutableParameters *_postParameters;
    PSMutableParameters *_fileParameters;
    PSMutableParameters *_headers;
}

- (id)init {
    self = [super init];
    if (self) {
        _appendParameters = [[PSMutableParameters alloc] init];
        _parameters = [[PSMutableParameters alloc] init];
        _postParameters = [[PSMutableParameters alloc] init];
        _fileParameters = [[PSMutableParameters alloc] init];
        _headers = [[PSMutableParameters alloc] init];
        _timeOut = 10;
        _taskType = PSTaskData;
        _method = PSHttpMethodPost;
        _httpSessionManager = [AFHTTPSessionManager manager];
        _httpSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
         _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _httpSessionManager.requestSerializer=[AFJSONRequestSerializer serializer];
        [_httpSessionManager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        
//        [_httpSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//        _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream",@"application/x-www-form-urlencoded", @"text/json", nil];
        

        _httpSessionManager.requestSerializer.timeoutInterval = _timeOut;
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _httpSessionManager.securityPolicy = securityPolicy;
       // _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

- (PSParameters *)appendParameters {
    [_appendParameters clearAllParameter];
    [self buildAppendParameters:_appendParameters];
    return _appendParameters;
}

- (PSParameters *)parameters {
    [_parameters clearAllParameter];
    [self buildParameters:_parameters];
    return _parameters;
}

- (PSParameters *)postParameters {
    [_postParameters clearAllParameter];
    [self buildPostParameters:_postParameters];
    return _postParameters;
}

- (PSParameters *)fileParameters {
    [_fileParameters clearAllParameter];
    [self buildFileParameters:_fileParameters];
    return _fileParameters;
}

- (PSParameters *)headers {
    [_headers clearAllParameter];
    [self buildHeaders:_headers];
    return _headers;
}

- (BOOL)send {
    _httpSessionManager.requestSerializer.timeoutInterval = _timeOut;
    PSParameters *headers = [self headers];
    NSDictionary *headersDictionary = [headers dictionary];
    AFHTTPRequestSerializer *requestSerializer = _httpSessionManager.requestSerializer;
    for (NSString *key in headersDictionary.allKeys) {
        [requestSerializer setValue:headersDictionary[key] forHTTPHeaderField:key];
    }
    [self appendParameters];
    NSURL* requestURL = [self buildRequestURL];
    //PSLog(@"url:%@",requestURL.absoluteString);
    __weak PSHttpClient *weakself = self;
    if(_method == PSHttpMethodPost){
        [self postParameters];
        //处理参数
        if (self.parameterType == PSPostParameterFormData) {
            [_httpSessionManager POST:requestURL.absoluteString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [[_postParameters dictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSString class]]) {
                        [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding] name:key];
                    }else if ([obj isKindOfClass:[NSData class]]) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        // 设置时间格式
                        [formatter setDateFormat:@"yyyyMMddHHmmss"];
                        NSString *dateString = [formatter stringFromDate:[NSDate date]];
                        NSString *fileName = [NSString  stringWithFormat:@"%@.jpg", dateString];
                        [formData appendPartWithFileData:obj name:key fileName:fileName mimeType:@"image/jpeg"];
                    }
                }];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself networkCompleted:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakself networkError:error];
            }];
        }else{
            [_httpSessionManager POST:requestURL.absoluteString parameters:[_postParameters dictionary] progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself networkCompleted:responseObject];
    
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakself networkError:error];
            }];
        }
    }else if(_method==PSHttpMethodGet){
        [_httpSessionManager GET:requestURL.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakself networkCompleted:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakself networkError:error];
        }];
    }
    return YES;
}

- (NSString *)serverURL {
    return @"";
}

- (NSString* )methodString {
    switch (self.method) {
        case PSHttpMethodPost:
            return @"POST";
        case PSHttpMethodGet:
            return @"GET";
        default:
            @throw [NSException exceptionWithName:@"参数不正确" reason:@"HTTP方法不能为空" userInfo:nil];
    }
}

- (void)cancel {
    if(_httpSessionManager){
        [_httpSessionManager.operationQueue cancelAllOperations];
    }
}

- (NSString *)description {
    NSURL* requestURL = [self buildRequestURL];
    return [requestURL absoluteString];
}

- (void)resetParameters {
    [_parameters clearAllParameter];
    [self buildParameters:_parameters];
}

- (NSURL*)buildRequestURL {
    NSMutableString *serverURL = [NSMutableString stringWithString:[self buildRequestURLString]];
    NSString *parameters = [[_appendParameters buildParameters] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *suffixStr = [serverURL substringFromIndex:[serverURL length] - 1];
    NSString *formatStr;
    if ([suffixStr isEqualToString:@"?"] || [suffixStr isEqualToString:@"&"])
        formatStr = @"%@%@";
    else
        formatStr = @"%@?%@";
    serverURL = [NSMutableString stringWithFormat:formatStr, serverURL, parameters];
    
    return [NSURL URLWithString:serverURL];
}

- (NSString *)buildRequestURLString {
    return nil;
}

- (void)buildAppendParameters:(PSMutableParameters*)parameters {
    
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    
}

- (void)buildFileParameters:(PSMutableParameters *)parameters {
    
}

- (void)buildHeaders:(PSMutableParameters *)headers {
    
}

- (BOOL)networkStart {
    return NO;
}

- (NSString *)postFileType {
    return @"image/png";
}

- (void)networkCompleted:(NSData *)responseData {
}

- (void)networkError:(NSError *)error {
}

@end
