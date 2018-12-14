//
//  NSDate+Components.h
//  PrisonService
//
//  Created by calvin on 2018/4/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Components)

- (NSInteger)year;
- (NSInteger)month;
- (NSString *)yearMonthDay;
- (NSString *)yearMonthDayChinese;
- (NSString *)yearMonth;
- (NSString *)yearString;
- (NSString *)monthDayHourMinute;
- (NSString *)dateStringWithFormat:(NSString *)format;
- (NSInteger)dayIntervalSinceDate:(NSDate *)date;
- (BOOL)equalToDate:(NSDate *)otherDate;
+ (NSString *)getNowTimeTimestamp;

@end
