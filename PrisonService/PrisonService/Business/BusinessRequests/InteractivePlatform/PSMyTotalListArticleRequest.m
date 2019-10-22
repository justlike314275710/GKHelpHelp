//
//  PSMyTotalListArticleRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSMyTotalListArticleRequest.h"
#import "PSMyTotalListResponse.h"

@implementation PSMyTotalListArticleRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"getMyTotalArticle";
    }
    return self;
}
//GET /api/article/getMyTotalArticle
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [parameters addParameter:[NSString stringWithFormat:@"%@",@"1"] forKey:@"type"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSMyTotalListResponse class];
}
@end
