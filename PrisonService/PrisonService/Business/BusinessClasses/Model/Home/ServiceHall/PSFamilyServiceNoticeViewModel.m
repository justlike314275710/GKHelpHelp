//
//  PSFamilyServiceNoticeViewModel.m
//  PrisonService
//
//  Created by kky on 2019/5/30.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyServiceNoticeViewModel.h"

#import "PSCache.h"
#import "PSBusinessConstants.h"
#import "PSMeetingHistoryViewModel.h"
#import "PSMeettingHistory.h"
#import "PSMeetHistoryRequest.h"
#import "PSMeetHistoryResponse.h"

#import "PSMeetCancelRequest.h"

@interface PSFamilyServiceNoticeViewModel()

@property (nonatomic , strong) PSMeetHistoryRequest *meetHistoryRequest;
@property (nonatomic , strong) NSMutableArray *items;
@property (nonatomic, strong) PSMeetCancelRequest *cancelMeetingRequest;
@end

@implementation PSFamilyServiceNoticeViewModel
@synthesize dataStatus = _dataStatus;


- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 10;
    }
    return self;
}
-(NSArray*)meeetHistorys{
    return _items;
}


- (void)refreshRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page = 1;
    self.items = nil;
    self.hasNextPage = NO;
    self.dataStatus = PSDataInitial;
    [self requestRefundCompleted:completedCallback failed:failedCallback];
    
    
}

- (void)loadMoreRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page ++;
    [self requestRefundCompleted:completedCallback failed:failedCallback];
}

- (void)requestRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.meetHistoryRequest = [PSMeetHistoryRequest new];
    self.meetHistoryRequest.page = self.page;
    self.meetHistoryRequest.rows = self.pageSize;
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    self.meetHistoryRequest.familyId=self.session.families.id;
    @weakify(self)
    [self.meetHistoryRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        
        if (response.code == 200) {
            PSMeetHistoryResponse *meetHistoryResponse= (PSMeetHistoryResponse *)response;
            if (self.page == 1) {
                self.items = [NSMutableArray new];
            }
            if (meetHistoryResponse.history.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = meetHistoryResponse.history.count >= self.pageSize;
            
            [self.items addObjectsFromArray:meetHistoryResponse.history];
            
        }else{
            if (self.page > 1) {
                self.page --;
                self.hasNextPage = YES;
            }else{
                self.dataStatus = PSDataError;
            }
        }
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        @strongify(self)
        if (self.page > 1) {
            self.page --;
            self.hasNextPage = YES;
        }else{
            self.dataStatus = PSDataError;
        }
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}



- (void)MeetapplyCancelCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    _cancelMeetingRequest=[PSMeetCancelRequest new];
    _cancelMeetingRequest.ID=self.cancelId;
    _cancelMeetingRequest.cause=self.cause;
    [_cancelMeetingRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

@end
