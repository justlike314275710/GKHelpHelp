//
//  PSPrisonConsumptionRequest.m
//  PrisonService
//
//  Created by kky on 2019/3/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPrisonConsumptionRequest.h"
#import "PSPrisonConsumptionResponse.h"

@implementation PSPrisonConsumptionRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"page";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/prisoner_consume/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    
    [parameters addParameter:self.prisonerId forKey:@"prisonerId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSPrisonConsumptionResponse class];
}
@end
