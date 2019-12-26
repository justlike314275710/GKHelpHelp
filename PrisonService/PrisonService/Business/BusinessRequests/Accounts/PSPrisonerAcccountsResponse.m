//
//  PSPrisonerAcccountsResponse.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonerAcccountsResponse.h"

@implementation PSPrisonerAcccountsResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"accounts":@"data.accounts"}];
}
@end
