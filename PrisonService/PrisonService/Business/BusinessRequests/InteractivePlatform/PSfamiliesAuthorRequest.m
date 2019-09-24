//
//  PSfamiliesAuthorRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSfamiliesAuthorRequest.h"
#import "PSfamiliesAuthorResponse.h"

@implementation PSfamiliesAuthorRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"enabled";
        
    }
    return self;
}
// POST /families/author/enabled
- (NSString *)businessDomain {
    return @"/families/author/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.userName forKey:@"userName"];
    [parameters addParameter:self.type forKey:@"type"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSfamiliesAuthorResponse class];
}
@end
