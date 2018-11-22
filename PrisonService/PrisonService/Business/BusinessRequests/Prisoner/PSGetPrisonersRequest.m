//
//  PSGetPrisonersRequest.m
//  PrisonService
//
//  Created by kky on 2018/11/22.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSGetPrisonersRequest.h"

@implementation PSGetPrisonersRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"prisoners";
    }
    return self;
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [parameters addParameter:self.jailId forKey:@"jailId"];
    [super buildParameters:parameters];
}

- (NSString *)businessDomain {
    return @"/getPrisoners/";
}

- (Class)responseClass {
    return [PSGetPrisonerResponse class];
}


@end
