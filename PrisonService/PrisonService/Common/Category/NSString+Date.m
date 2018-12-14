//
//  NSString+Date.m
//  PrisonService
//
//  Created by calvin on 2018/4/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

- (NSDate *)stringToDateWithFormat:(NSString *)format {
    if (format) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:format];
        return [formatter dateFromString:self];
    }
    return nil;
}

- (NSString *)timestampToDateString {
    long long timeInterval = [self longLongValue];
    if (self.length >= 13) {
        timeInterval /= 1000.0;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

- (NSString *)timestampToDateDetailString {
    long long timeInterval = [self longLongValue];
    if (self.length >= 13) {
        timeInterval /= 1000.0;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:date];
}

- (NSDate *)timestampToDate {
    long long timeInterval = [self longLongValue];
    if (self.length >= 13) {
        timeInterval /= 1000.0;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

- (NSString *)timestampToMonthDayString {
    long long timeInterval = [self longLongValue];
    if (self.length >= 13) {
        timeInterval /= 1000.0;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    return [formatter stringFromDate:date];
}

@end
