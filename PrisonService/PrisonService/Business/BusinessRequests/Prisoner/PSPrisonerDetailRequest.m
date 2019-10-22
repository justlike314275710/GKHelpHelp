//
//  PSPrisonerDetailRequest.m
//  PrisonService
//
//  Created by calvin on 2018/4/20.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonerDetailRequest.h"

@implementation PSPrisonerDetailRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"details";
    }
    return self;
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.prisonerId forKey:@"prisonerId"];
    [super buildParameters:parameters];
}

- (NSString *)businessDomain {
    return @"/api/prisoners/";
}
///api/prisoners/details
- (Class)responseClass {
    return [PSPrisonerDetailResponse class];
}


@end
