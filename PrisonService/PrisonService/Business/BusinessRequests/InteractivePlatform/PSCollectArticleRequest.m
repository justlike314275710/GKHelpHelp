//
//  PSCollectArticleRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSCollectArticleRequest.h"

@implementation PSCollectArticleRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"collectArticle";
        
    }
    return self;
}
//POST /api/article/collectArticle
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.articleId forKey:@"articleId"];
    [parameters addParameter:@"1" forKey:@"type"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSResponse class];
}
@end
