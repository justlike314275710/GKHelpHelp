//
//  UpDateModel.m
//  PrisonService
//
//  Created by kky on 2018/11/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "UpDateModel.h"

@implementation UpDateModel

//+(NSDictionary*)mj_replacedKeyFromPropertyName{
//    return@{@"description":@"des"};
//}


+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"description":@"des"}];
}
@end

