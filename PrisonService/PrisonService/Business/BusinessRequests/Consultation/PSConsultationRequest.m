//
//  PSConsultationRequest.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSConsultationRequest.h"
#import "PSBusinessConstants.h"
#import "PSConsultationResponse.h"
@implementation PSConsultationRequest
- (NSString *)serverURL {
    return ConsultationHostUrl;
}

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"legal-advice";
        self.parameterType=PSPostParameterJson;
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/customer/";
}


- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.size] forKey:@"size"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSConsultationResponse class];
}

@end
