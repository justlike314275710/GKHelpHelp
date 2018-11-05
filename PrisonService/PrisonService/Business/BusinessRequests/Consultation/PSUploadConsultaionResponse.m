//
//  PSUploadConsultaionResponse.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSUploadConsultaionResponse.h"

@implementation PSUploadConsultaionResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"imageId":@"id"}];
}
@end
