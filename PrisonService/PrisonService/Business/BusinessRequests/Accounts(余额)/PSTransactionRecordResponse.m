//
//  PSTransactionRecordResponse.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSTransactionRecordResponse.h"

@implementation PSTransactionRecordResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"details":@"data.accounts.details",@"total":@"data.total",@"accounts":@"data.accounts",@"data":@"data"}];
}


@end
