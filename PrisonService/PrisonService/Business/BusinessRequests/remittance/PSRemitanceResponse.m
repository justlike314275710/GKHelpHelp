//
//  PSRemitanceResponse.m
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRemitanceResponse.h"

@implementation PSRemitanceResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"familyRemits":@"data.familyRemits"}];
}

@end
