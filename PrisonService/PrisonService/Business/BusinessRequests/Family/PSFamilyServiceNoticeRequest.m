//
//  PSFamilyServiceNoticeRequest.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyServiceNoticeRequest.h"
#import "PSFamilyServiceNoticeResponse.h"

@implementation PSFamilyServiceNoticeRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"serviceNotification";
    }
    return self;
}

- (void)buildParameters:(PSMutableParameters*)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.familyId] forKey:@"familyId"];
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSFamilyServiceNoticeResponse class];
}
@end
