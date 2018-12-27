//
//  PSFeedbackDetailResponse.m
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedbackDetailResponse.h"

@implementation PSFeedbackDetailResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"detail":@"data.detail"}];
}

@end
