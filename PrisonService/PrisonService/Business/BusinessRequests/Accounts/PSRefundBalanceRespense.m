//
//  PSRefundBalanceRespense.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRefundBalanceRespense.h"

@implementation PSRefundBalanceRespense
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"data":@"data"}];
}
@end
