//
//  PSArticleFindPenNameRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleFindPenNameRequest.h"
#import "PSArticleFindPenNameResponse.h"

@implementation PSArticleFindPenNameRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"findPenName";
    }
    return self;
}
//GET /api/article/findPenName
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
//    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.id] forKey:@"id"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSArticleFindPenNameResponse class];
}
@end
