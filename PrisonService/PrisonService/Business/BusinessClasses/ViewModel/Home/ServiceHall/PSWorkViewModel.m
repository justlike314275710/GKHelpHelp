//
//  PSWorkViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWorkViewModel.h"
#import "PSAdvertisementRequest.h"
#import "PSBusinessConstants.h"
#import "PSLocateManager.h"
#import "PSSessionManager.h"

@interface PSWorkViewModel ()

@property (nonatomic, strong) PSNewsRequest *newsRequest;
@property (nonatomic, strong) PSAdvertisementRequest *advRequest;
@property (nonatomic, strong) NSMutableArray *newsArray;

@end

@implementation PSWorkViewModel
@synthesize dataStatus = _dataStatus;
- (NSArray *)newsData {
    return _newsArray;
}

- (void)setAdvertisements:(NSArray *)advertisements {
    _advertisements = advertisements;
    NSMutableArray *urls = [NSMutableArray array];
    for (PSAdvertisement *adv in advertisements) {
        [urls addObject:PICURL(adv.imageUrl)];
    }
    _advUrls = urls;
}

- (void)refreshNewsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page = 1;
    self.newsArray = nil;
    self.hasNextPage = NO;
    self.dataStatus = PSDataInitial;
    [self requestNewsCompleted:completedCallback failed:failedCallback];
}

- (void)loadMoreNewsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page ++;
    [self requestNewsCompleted:completedCallback failed:failedCallback];
}

- (void)requestNewsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.newsRequest = [PSNewsRequest new];
    self.newsRequest.page = self.page;
    self.newsRequest.rows = self.pageSize;
    self.newsRequest.type = self.newsType;
    
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    PSPrisonerDetail *prisonerDetail = nil;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    self.newsRequest.jailId = self.jailId?self.jailId:prisonerDetail.jailId?prisonerDetail.jailId:@"";
    @weakify(self)
    [self.newsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSNewsResponse *newsResponse = (PSNewsResponse *)response;
            if (self.page == 1) {
                self.newsArray = [NSMutableArray array];
            }
            if (newsResponse.news.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = newsResponse.news.count >= self.pageSize;
            [self.newsArray addObjectsFromArray:newsResponse.news];
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

- (void)requestAdvsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.advRequest = [PSAdvertisementRequest new];
    self.advRequest.type = PSAdvApp;
    self.advRequest.province = [PSLocateManager sharedInstance].province;
    @weakify(self)
    [self.advRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSAdvertisementResponse *advertisementResponse = (PSAdvertisementResponse *)response;
            self.advertisements = advertisementResponse.advertisements;
        }
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)refreshAllDataCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    @weakify(self)
    [self requestAdvsCompleted:^(PSResponse *response) {
        @strongify(self)
        [self refreshNewsCompleted:^(PSResponse *response) {
            if (completedCallback) {
                completedCallback(nil);
            }
        } failed:^(NSError *error) {
            if (failedCallback) {
                failedCallback(nil);
            }
        }];
    } failed:^(NSError *error) {
        @strongify(self)
        [self refreshNewsCompleted:^(PSResponse *response) {
            if (completedCallback) {
                completedCallback(nil);
            }
        } failed:^(NSError *error) {
            if (failedCallback) {
                failedCallback(nil);
            }
        }];
    }];
}

- (NSArray *)passedPrisonerDetails {
    return [PSSessionManager sharedInstance].passedPrisonerDetails;
}

- (NSInteger)selectedPrisonerIndex {
    return [PSSessionManager sharedInstance].selectedPrisonerIndex;
    
}

@end
