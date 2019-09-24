//
//  PSCollecArtcleListViewModel.m
//  PrisonService
//
//  Created by kky on 2019/9/11.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSCollecArtcleListViewModel.h"
#import "PSCollectListRequest.h"
#import "PSSessionManager.h"
#import "PSCollectArticleListResponse.h"


@interface PSCollecArtcleListViewModel ()

@property (nonatomic, strong) PSCollectListRequest *familyLogsRequest;
@property (nonatomic, strong) NSMutableArray *logs;

@end

@implementation PSCollecArtcleListViewModel
@synthesize dataStatus = _dataStatus;
- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 10;
    }
    return self;
}

- (NSArray *)messages {
    return _logs;
}

- (void)refreshMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page = 1;
    self.logs = nil;
    self.hasNextPage = NO;
    self.dataStatus = PSDataInitial;
    [self requestMessagesCompleted:completedCallback failed:failedCallback];
}

- (void)loadMoreMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page ++;
    [self requestMessagesCompleted:completedCallback failed:failedCallback];
}

- (void)requestMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.familyLogsRequest = [PSCollectListRequest new];
    self.familyLogsRequest.page = self.page;
    self.familyLogsRequest.rows = self.pageSize;
    @weakify(self)
    [self.familyLogsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        
        if (response.code == 200) {
            PSCollectArticleListResponse *logsResponse = (PSCollectArticleListResponse *)response;
            
            if (self.page == 1) {
                self.logs = [NSMutableArray array];
            }
            if (logsResponse.collectList.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = logsResponse.collectList.count >= self.pageSize;
            [self.logs addObjectsFromArray:logsResponse.collectList];
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


@end
