//
//  PSFeedBackTypesResponse.m
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedBackTypesResponse.h"

@implementation PSFeedBackTypesResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"types":@"data.types"}];
}

@end
