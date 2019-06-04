//
//  PSFamilyServiceNoticeResponse.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyServiceNoticeResponse.h"

@implementation PSFamilyServiceNoticeResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"logs":@"data.logs"}];
}
@end
