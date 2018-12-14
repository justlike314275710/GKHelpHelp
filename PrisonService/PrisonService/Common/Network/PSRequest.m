//
// Created by William Zhao on 13-6-26.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "PSRequest.h"

@interface PSRequest ()

@property (nonatomic, copy) PSRequestCompletedCallback completedCallback;
@property (nonatomic, copy) PSRequestErrorCallback errorCallback;

- (void)requestCompleted:(PSResponse *)response;
- (void)requestError:(NSError *)error;

@end

@implementation PSRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    [self cancel];
}

- (void)cancelRequest {
    _delegate = nil;
    [super cancel];
}

- (void)buildAppendParameters:(PSMutableParameters*)parameters {
    NSDictionary *getParameters = [self parameters].dictionary;
    [getParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [parameters addParameter:obj forKey:key];
    }];
}

- (void)buildParameters:(PSMutableParameters*)parameters {
    [super buildParameters:parameters];
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [super buildPostParameters:parameters];
}

- (void)buildHeaders:(PSMutableParameters *)headers {
    [super buildHeaders:headers];
}

- (void)send:(PSRequestCompletedCallback)completedCallback {
    [self send:completedCallback errorCallback:nil];
}

- (void)send:(PSRequestCompletedCallback)completedCallback errorCallback:(PSRequestErrorCallback)errorCallback {
    self.completedCallback = completedCallback;
    self.errorCallback = errorCallback;
    [self send];
}

- (BOOL)networkStart {
    return YES;
}

- (void)networkCompleted:(NSData *)responseData; {
    
   
    
    NSString *str  = [[NSString alloc] initWithBytes:responseData.bytes length:responseData.length encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",str);
    Class responseClass = [self responseClass];
    if(![responseClass isSubclassOfClass:[PSResponse class]]){
        @throw [NSException exceptionWithName:@"类型错误" reason:@"responseClass必须为PSResponse的子类" userInfo:nil];
    }
    NSError *error = nil;
    //PSLog(@">>>%@:%@",NSStringFromClass(responseClass),[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    PSResponse *response = [[responseClass alloc] initWithString:[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] error:&error];
    NSLog(@"response%@",response);
    if ([NSThread isMainThread]) {
        [self requestCompleted:response];
    }
    else {
        [self performSelectorOnMainThread:@selector(requestCompleted:) withObject:response waitUntilDone:NO];
    }
}

- (void)networkError:(NSError *)error {
    //NSLog(@"--NetworkError:%@",error);
    if ([NSThread isMainThread]) {
        [self requestError:error];
    }
    else {
        [self performSelectorOnMainThread:@selector(requestError:) withObject:error waitUntilDone:NO];
    }
}

- (void)requestCompleted:(PSResponse *)response {
    if (_completedCallback) {
        _completedCallback(self, response);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(requestCompleted:response:)]) {
        [_delegate performSelector:@selector(requestCompleted:response:) withObject:self withObject:response];
    }
}

- (void)requestError:(NSError *)error {
    if (_errorCallback) {
        _errorCallback(self, error);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(requestError:error:)]) {
        [_delegate performSelector:@selector(requestError:error:) withObject:self withObject:error];
    }
}

- (NSString *)buildRequestURLString {
    NSMutableString *serverURL = [NSMutableString stringWithString:[self serverURL]];
    //业务
    if ([self businessDomain]) {
        [serverURL appendString:self.businessDomain];
    }
    //功能
    if ([self serviceName]) {
        [serverURL appendString:self.serviceName];
    }
    return serverURL;
}

- (NSString *)businessDomain {
    return nil;
}

- (Class)responseClass {
    @throw [NSException exceptionWithName:@"方法错误" reason:@"必须实现抽象方法" userInfo:nil];
}

@end
