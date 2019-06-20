//
//  PSMeetingHistoryViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSUserSession.h"
#import "PSBaseServiceViewModel.h"

@interface PSMeetingHistoryViewModel : PSViewModel
@property (nonatomic, strong,readonly) NSArray *meeetHistorys;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;

@property (nonatomic, strong) NSString *cancelId;
@property (nonatomic, strong) NSString *cause;
- (void)MeetapplyCancelCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)refreshRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
