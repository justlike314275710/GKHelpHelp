//
//  PSMyTotalArtcleListViewModel.m
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSMyTotalArtcleListViewModel.h"
#import "PSMyTotalListArticleRequest.h"
#import "PSSessionManager.h"
#import "PSMyTotalListResponse.h"



@interface PSMyTotalArtcleListViewModel ()

@property (nonatomic, strong) PSMyTotalListArticleRequest *familyLogsRequest;
@property (nonatomic, strong) NSMutableArray *logs;
@property (nonatomic, strong) NSMutableArray *logs1;
@property (nonatomic, strong) NSMutableArray *logs2;

@end

@implementation PSMyTotalArtcleListViewModel
@synthesize dataStatus = _dataStatus;
- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 3;
    }
    return self;
}

- (NSArray *)articles_notpublished {
    return _logs;
}

- (NSArray *)articles_notpass {
    return _logs1;
}

- (NSArray *)articles_published {
    return _logs2;
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
    self.familyLogsRequest = [PSMyTotalListArticleRequest new];
    self.familyLogsRequest.page = self.page;
    self.familyLogsRequest.rows = self.pageSize;
    @weakify(self)
    [self.familyLogsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        
        if (response.code == 200) {
            PSMyTotalListResponse *logsResponse = (PSMyTotalListResponse *)response;
            
            if (self.page == 1) {
                self.logs = [NSMutableArray array];
                self.logs1 = [NSMutableArray array];
                self.logs2 = [NSMutableArray array];
            
            }
            
            if ((logsResponse.articles_notpublished.count == 0)&&logsResponse.articles_notpass.count==0&&logsResponse.articles_published.count==0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = NO;
            [self.logs addObjectsFromArray:logsResponse.articles_notpublished];
            [self.logs1 addObjectsFromArray:logsResponse.articles_notpass];
            [self.logs2 addObjectsFromArray:logsResponse.articles_published];
            self.articles = [NSMutableArray array];
            //已发布
            if (self.logs2.count!=0) {
                [self.articles addObject:self.logs2];
            }
            //未发布
            if (self.logs.count!=0) {
                [self.articles addObject:self.logs];
            }
            //未通过
            if (self.logs1.count!=0) {
                [self.articles addObject:self.logs1];
            }
 
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
