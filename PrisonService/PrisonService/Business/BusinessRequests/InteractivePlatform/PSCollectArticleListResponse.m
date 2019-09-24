//
//  PSCollectArticleListResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSCollectArticleListResponse.h"

@implementation PSCollectArticleListResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"collectList":@"data.collectList"}];
}

@end
