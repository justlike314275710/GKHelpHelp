//
//  PSPrisonConsumptionResponse.m
//  PrisonService
//
//  Created by kky on 2019/3/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPrisonConsumptionResponse.h"
@implementation PSPrisonConsumptionResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"prisonerConsumes":@"data.prisonerConsumes"}];
}
@end
