//
//  PSPublishArtileRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPublishListArtileRequest.h"
#import "PSArtcleDetailResponse.h"

@implementation PSPublishListArtileRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"getPublishArticle";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSArtcleDetailResponse class];
}
@end
