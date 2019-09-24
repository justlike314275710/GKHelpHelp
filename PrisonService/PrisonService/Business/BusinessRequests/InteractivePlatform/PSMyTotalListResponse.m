//
//  PSMyTotalListResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/16.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSMyTotalListResponse.h"

@implementation PSMyTotalListResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"articles_notpublished":@"data.articles_notpublished",@"articles_notpass":@"data.articles_notpass",@"articles_published":@"data.articles_published"}];
}

@end
