//
//  PSMailBoxesTypesRequest.m
//  PrisonService
//
//  Created by kky on 2018/12/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMailBoxesTypesRequest.h"
#import "PSFeedBackTypesResponse.h"

@implementation PSMailBoxesTypesRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"types";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/mailboxes/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSFeedBackTypesResponse class];
}

@end
