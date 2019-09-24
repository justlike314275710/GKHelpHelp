//
//  PSArtcleDetailResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArtcleDetailResponse.h"

@implementation PSArtcleDetailResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"articles":@"data.articles"}];
}

@end
