//
//  NSDate+Components.m
//  PrisonService
//
//  Created by calvin on 2018/4/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "NSDate+Components.h"

@implementation NSDate (Components)

- (NSInteger)year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return components.year;
}

- (NSInteger)month {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return components.month;
}

- (NSString *)yearMonthDay {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:self];
}

- (NSString *)yearMonthDayChinese {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    return [formatter stringFromDate:self];
}

- (NSString *)yearMonth {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    return [formatter stringFromDate:self];
}

- (NSString *)yearString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:self];
}

- (NSString *)monthDayHourMinute {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日 HH:mm"];
    return [formatter stringFromDate:self];
}

- (NSString *)dateStringWithFormat:(NSString *)format {
    if (format) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:format];
        return [formatter stringFromDate:self];
    }
    return nil;
}

- (NSInteger)dayIntervalSinceDate:(NSDate *)date {
    NSInteger days = 0;
    if (date) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *ownDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
        ownDateComponents.hour = 0;
        ownDateComponents.second = 0;
        NSDate *newOwnDate = [calendar dateFromComponents:ownDateComponents];
        NSDateComponents *sinceDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        sinceDateComponents.hour = 0;
        sinceDateComponents.second = 0;
        NSDate *newSinceDate = [calendar dateFromComponents:sinceDateComponents];
        NSTimeInterval timeInterval = [newOwnDate timeIntervalSinceDate:newSinceDate];
        days = ceil(timeInterval / (24*60*60));
    }
    return days;
}

- (BOOL)equalToDate:(NSDate *)otherDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *myDateString = [formatter stringFromDate:self];
    NSString *otherDateString = [formatter stringFromDate:otherDate];
    return [myDateString isEqualToString:otherDateString];
}

+(NSString *)getNowTimeTimestamp{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%.0f", a];//转为字符型
    ;
    return timeString;
    
}


@end
