//
//  PSLocalMeetingDetailResponse.m
//  PrisonService
//
//  Created by calvin on 2018/5/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocalMeetingDetailResponse.h"

@implementation PSLocalMeetingDetailResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"visits":@"data.visits"}];
}

@end
