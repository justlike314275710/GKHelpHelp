//
//  PSPeriodChange.m
//  PrisonService
//
//  Created by calvin on 2018/4/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPeriodChange.h"

@implementation PSPeriodChange

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if([propertyName isEqualToString:@"changeyear"]) return YES;
    if([propertyName isEqualToString:@"changemonth"]) return YES;
    if([propertyName isEqualToString:@"changeday"]) return YES;
    return NO;
}

@end
