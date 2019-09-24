//
//  PSPlatMessageRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPlatMessageRequest.h"
#import "PSFamilyLogsResponse.h"

@implementation PSPlatMessageRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"findPage";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/family_logs/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    if (self.type&&self.type.length > 0) {
        [parameters addParameter:[NSString stringWithFormat:@"%@",self.type] forKey:@"type"];
    }
    [parameters addParameter:self.prisonerId forKey:@"prisonerId"];
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSFamilyLogsResponse class];
}
@end
