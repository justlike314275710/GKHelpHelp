//
//  PSCountVisitRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSCountVisitRequest.h"
#import "PSCountVisitResponse.h"

@implementation PSCountVisitRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"countVisit";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/family_logs/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSCountVisitResponse class];
}
@end
