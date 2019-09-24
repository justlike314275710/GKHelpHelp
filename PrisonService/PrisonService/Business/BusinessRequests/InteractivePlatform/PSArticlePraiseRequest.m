//
//  PSArticlePraiseRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticlePraiseRequest.h"

@implementation PSArticlePraiseRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"praise";
        
    }
    return self;
}
//POST  /api/article/praise
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
