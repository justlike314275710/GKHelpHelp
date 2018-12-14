//
//  PSLocalMeetingAppointmentStatusView.h
//  PrisonService
//
//  Created by kky on 2018/11/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLocalMeetingStatusView.h"
#import "PSClockView.h"
#import "PSLocalMeetingViewModel.h"
//typedef NS_ENUM(NSInteger, PSLocalMeetingStatus) {
//    PSLocalMeetingWithoutAppointment, //未预约
//    PSLocalMeetingPending,//审核中
//    PSLocalMeetingCountdown,//预约倒计时
//    PSLocalMeetingOntime,//预约时间到
//};
typedef void (^ActionBlock) (PSLocalMeetingStatus status);

@interface PSLocalMeetingAppointmentStatusView : UIScrollView

@property (nonatomic, strong, readonly) PSClockView *clock;
@property (nonatomic, assign) PSLocalMeetingStatus status;
@property (nonatomic, copy) ActionBlock actionBlock;
@property (nonatomic, copy) PSLocalMeetingViewModel *messageViewModel;


@end


