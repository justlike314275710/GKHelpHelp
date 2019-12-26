//
//  PSPrisonerAccountsRequest.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonerAccountsRequest.h"
#import "PSPrisonerAcccountsResponse.h"
@implementation PSPrisonerAccountsRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"accounts";
    }
    return self;
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.familyId forKey:@"familyId"];
     [parameters addParameter:self.jailId forKey:@"jailId"];
    [super buildParameters:parameters];
}

- (NSString *)businessDomain {
    return @"/api/families/";
}

- (Class)responseClass {
    return [PSPrisonerAcccountsResponse class];
}
@end
