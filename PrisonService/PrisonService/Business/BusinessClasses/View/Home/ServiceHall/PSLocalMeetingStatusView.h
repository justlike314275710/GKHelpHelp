//
//  PSLocalMeetingStatusView.h
//  PrisonService
//
//  Created by calvin on 2018/5/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSClockView.h"

typedef NS_ENUM(NSInteger, PSLocalMeetingStatus) {
    PSLocalMeetingWithoutAppointment, //未预约
    PSLocalMeetingPending,//审核中
    PSLocalMeetingPendingFail,//审核未通过
    PSLocalMeetingCountdown,//预约倒计时
    PSLocalMeetingOntime,//预约时间到
};

@interface PSLocalMeetingStatusView : UIView

@property (nonatomic, strong, readonly) PSClockView *clock;
@property (nonatomic, assign) PSLocalMeetingStatus status;

@end
