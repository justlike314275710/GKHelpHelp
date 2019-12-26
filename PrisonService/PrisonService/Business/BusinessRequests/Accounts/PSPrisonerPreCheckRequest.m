//
//  PSPrisonerPreCheckRequest.m
//  PrisonService
//
//  Created by kky on 2019/5/15.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPrisonerPreCheckRequest.h"
#import "PSRrisonerPreCheckResponse.h"

@implementation PSPrisonerPreCheckRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"preCheck";
        self.parameterType=PSPostParameterJson;
    }
    return self;
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [parameters addParameter:self.jailId forKey:@"jailId"];
    [parameters addParameter:self.prisonerId forKey:@"prisonerId"];
    [parameters addParameter:self.applicationDate forKey:@"applicationDate"];
    [super buildParameters:parameters];
}

- (NSString *)businessDomain {
    return @"/api/meetings/";
}

- (Class)responseClass {
    return [PSRrisonerPreCheckResponse class];
}
@end
