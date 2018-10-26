//
//  PSMailBoxesResponse.m
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMailBoxesResponse.h"

@implementation PSMailBoxesResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"mailBoxes":@"data.mailBoxes"}];
}

@end
