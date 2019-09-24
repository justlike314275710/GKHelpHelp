//
//  PSArticleDeletePraiseRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleDeletePraiseRequest.h"

@implementation PSArticleDeletePraiseRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"deletePraise";
        
    }
    return self;
}
//POST /api/article/deletePraise
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.articleId forKey:@"articleId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSResponse class];
}
@end
