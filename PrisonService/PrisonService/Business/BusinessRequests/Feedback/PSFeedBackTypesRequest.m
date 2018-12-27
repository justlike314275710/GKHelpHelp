//
//  PSFeedBackTypesRequest.m
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedBackTypesRequest.h"
#import "PSFeedBackTypesResponse.h"

@implementation PSFeedBackTypesRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"types";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/feedbacks/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSFeedBackTypesResponse class];
}

@end
