//
//  PSArtcleFindDetailRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArtcleFindDetailRequest.h"
#import "PSArtcleFindDetailResponse.h"

@implementation PSArtcleFindDetailRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"findDetail";
    }
    return self;
}
//GET /api/article/findDetail
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.id] forKey:@"id"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSArtcleFindDetailResponse class];
}
@end
