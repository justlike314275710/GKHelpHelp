//
//  PSFeedbackListResponse.m
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedbackListResponse.h"

@implementation PSFeedbackListResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"feedbacks":@"data.feedbacks"}];
}

@end
