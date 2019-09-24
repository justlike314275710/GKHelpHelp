//
//  PSArticleFindPenNameResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleFindPenNameResponse.h"

@implementation PSArticleFindPenNameResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"publicArticleModel":@"data"}];
}
@end
