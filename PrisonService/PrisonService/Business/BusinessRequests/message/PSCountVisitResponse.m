//
//  PSCountVisitResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSCountVisitResponse.h"

@implementation PSCountVisitResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"mesageCounts":@"data.logs"}];
}


@end
