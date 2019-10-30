//
//  PSMeetingMessage.h
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

typedef NS_ENUM(NSInteger, PSMeetingCode) {
    PSFreeMeetingLocation        = -4,//免费会见定位
    PSChargeMeetingLocation      = -3,//收费会见定位 //视屏会见倒计时推送
    PSMeetingEnd                 = -2,//结束会议code
    PSMeetingStart               = -1,//发起会议code
    PSMeetingEnter               = 0,//进入会议code
    PSMeetingStatus              = 1,//会见状态变更code
    PSMeetingLocal               = 2,//实地会见
    PSMeetingCancelAuthorization = 3,//注册授权撤销
    PSMessageArticleInteractive  = 4,//互动文章消息
};

@interface PSMeetingMessage : JSONModel

@property (nonatomic, assign) PSMeetingCode code;
@property (nonatomic, strong) NSString<Optional> *meeting_time;
@property (nonatomic, strong) NSString<Optional> *jail;
@property (nonatomic, strong) NSString<Optional> *msg;
@property (nonatomic, strong) NSString<Optional> *recevice_time;
@property (nonatomic, strong) NSString<Optional> *status;
@property (nonatomic ,strong) NSString<Optional> *meetingId;
@property (nonatomic ,strong) NSString<Optional> *prisonerId;
@property (nonatomic ,strong) NSString<Optional> *callDuration;
@property (nonatomic ,strong) NSString<Optional> *channel;
@property (nonatomic ,strong) NSString<Optional> *isEnabled;
@end
