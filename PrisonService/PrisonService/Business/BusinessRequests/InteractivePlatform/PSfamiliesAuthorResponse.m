//
//  PSfamiliesAuthorResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSfamiliesAuthorResponse.h"

@implementation PSfamiliesAuthorResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"author":@"data.author"}];
}
@end
