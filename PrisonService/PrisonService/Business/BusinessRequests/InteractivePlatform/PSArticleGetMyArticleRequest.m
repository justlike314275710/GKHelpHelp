//
//  PSArticleGetMyArticleRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleGetMyArticleRequest.h"
#import "PSArticleGetMyArticleResponse.h"

@implementation PSArticleGetMyArticleRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"getMyArticle";
    }
    return self;
}
//GET /api/article/getMyArticle
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [parameters addParameter:self.status forKey:@"status"];
    [parameters addParameter:@"1" forKey:@"type"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSArticleGetMyArticleResponse class];
}
@end
