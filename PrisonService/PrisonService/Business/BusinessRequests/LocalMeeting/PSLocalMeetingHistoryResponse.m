//
//  PSLocalMeetingHistoryResponse.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSLocalMeetingHistoryResponse.h"

@implementation PSLocalMeetingHistoryResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"history":@"data.history"}];
}

@end
