//
//  PSUploadConsultaionRequest.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSUploadConsultaionRequest.h"
#import "PSBusinessConstants.h"
#import "PSUploadConsultaionResponse.h"
@implementation PSUploadConsultaionRequest



- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
    }
    return self;
}

-(void)buildPostParameters:(PSMutableParameters *)parameters{
   [parameters addParameter:self.consultaionData forKey:@"file"];
    [super buildPostParameters:parameters];
}


- (NSString *)serverURL {
    return @"http://10.10.10.17:8081";
}

- (NSString *)businessDomain {
    return @"/files";
}

- (Class)responseClass {
    return [PSUploadConsultaionResponse class];
}
@end
