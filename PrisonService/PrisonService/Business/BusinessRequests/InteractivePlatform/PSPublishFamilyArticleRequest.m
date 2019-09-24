//
//  PSPublishFamilyArticleRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPublishFamilyArticleRequest.h"

@implementation PSPublishFamilyArticleRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"publishFamilyArticle";
        
    }
    return self;
}
//POST /api/article/publishFamilyArticle
- (NSString *)businessDomain {
    return @"/api/article/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.id forKey:@"id"];
    [parameters addParameter:self.title forKey:@"title"];
    [parameters addParameter:self.content forKey:@"content"];
    [parameters addParameter:self.articleType forKey:@"articleType"];
    [parameters addParameter:self.penName forKey:@"penName"];
    
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSResponse class];
}
@end
