//
//  PSCollectListRequest.m
//  PrisonService
//
//  Created by kky on 2019/9/11.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSCollectListRequest.h"
#import "PSCollectArticleListResponse.h"

@implementation PSCollectListRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"collectList";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/article/";
///api/article/collectList
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [parameters addParameter:[NSString stringWithFormat:@"%@",@"1"] forKey:@"type"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSCollectArticleListResponse class];
}

@end
