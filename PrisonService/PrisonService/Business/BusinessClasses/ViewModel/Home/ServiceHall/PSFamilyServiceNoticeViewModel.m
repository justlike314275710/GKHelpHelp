//
//  PSFamilyServiceNoticeViewModel.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyServiceNoticeViewModel.h"
#import "PSFamilyServiceNoticeResponse.h"
#import "PSFamilyServiceNoticeRequest.h"
#import "PSCache.h"
#import "PSBusinessConstants.h"

@interface PSFamilyServiceNoticeViewModel()

@property (nonatomic , strong) PSFamilyServiceNoticeRequest *familyServiceNoticeRequest;
@property (nonatomic , strong) NSMutableArray *items;

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
    self.familyServiceNoticeRequest = [PSFamilyServiceNoticeRequest new];
    self.familyServiceNoticeRequest.page = self.page;
    self.familyServiceNoticeRequest.rows = self.pageSize;
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    self.familyServiceNoticeRequest.familyId=[self.session.families.id integerValue];
    @weakify(self)
    [self.familyServiceNoticeRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        
        if (response.code == 200) {
            PSFamilyServiceNoticeResponse *familyServiceNoticeResponse= (PSFamilyServiceNoticeResponse *)response;
//            PSFamilyServiceNoticeResponse *meetHistoryResponse= (PSFamilyServiceNoticeResponse *)response;
            if (self.page == 1) {
                self.items = [NSMutableArray new];
            }
            if (familyServiceNoticeResponse.logs.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = familyServiceNoticeResponse.logs.count >= self.pageSize;
            
            [self.items addObjectsFromArray:familyServiceNoticeResponse.logs];
            
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
