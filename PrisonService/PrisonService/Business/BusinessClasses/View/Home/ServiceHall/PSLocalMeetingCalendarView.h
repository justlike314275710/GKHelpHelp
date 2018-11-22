//
//  PSLocalMeetingCalendarView.h
//  PrisonService
//
//  Created by calvin on 2018/5/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AppointDate)(NSDate *date);

@interface PSLocalMeetingCalendarView : UIView

@property (nonatomic, copy) AppointDate appoint;

- (void)show;
- (void)show1;
- (void)dismissAnimated:(BOOL)animated;

@end
