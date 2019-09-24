//
//  PSHomeViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSHallFunction.h"
#import "PSPrisonerDetail.h"
#import "PSMeeting.h"
#import "PSMessageCountModel.h"

@interface PSHomeViewModel : PSViewModel

@property (nonatomic, strong, readonly) NSArray *functions;
@property (nonatomic, strong, readonly) NSArray *passedPrisonerDetails;
@property (nonatomic, assign) NSInteger selectedPrisonerIndex;
@property (nonatomic, strong, readonly) NSArray *meetings;
@property (nonatomic, strong, readonly) PSMeeting *latestMeeting;//时间最近的一次已审核过的预约
@property (nonatomic, strong) PSMessageCountModel *messageCountModel;

- (void)requestMeetingsCompleted:(RequestDataTaskCompleted)completedCallback;
- (void)requestHomeDataCompleted:(RequestDataTaskCompleted)completedCallback;
- (void)requestLocalMeetingDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)getRequestCountVisitCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
