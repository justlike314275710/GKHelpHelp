//
//  PSPinmoneyViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPinmoneyViewModel.h"
#import "PSPinmoneyRequest.h"
#import "PSPinmoneyResponse.h"
#import "PSSessionManager.h"
#import "PSBusinessConstants.h"
#import "PSPrisonerDetail.h"
@interface PSPinmoneyViewModel()
@property (nonatomic , strong) PSPinmoneyRequest *pinmoneyRequest;
@property (nonatomic , strong) NSMutableArray *items;
@end



@implementation PSPinmoneyViewModel
@synthesize dataStatus = _dataStatus;



- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 10;
    }
    return self;
}
-(NSArray*)Pinmoneys{
    return _items;
}
- (void)refreshPinmoneyCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page = 1;
    self.items = nil;
    self.hasNextPage = NO;
    self.dataStatus = PSDataInitial;
    [self requestPinmoneyCompleted:completedCallback failed:failedCallback];
    
}

- (void)loadMorePinmoneyCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page ++;
    [self requestPinmoneyCompleted:completedCallback failed:failedCallback];
}

- (void)requestPinmoneyCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    
    self.pinmoneyRequest = [PSPinmoneyRequest new];
    self.pinmoneyRequest.page = self.page;
    self.pinmoneyRequest.rows = self.pageSize;
    self.pinmoneyRequest.prisonerId=prisonerDetail.prisonerId;

    @weakify(self)
    [self.pinmoneyRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSPinmoneyResponse *PinmoneyResponse= (PSPinmoneyResponse *)response;
            if (self.page == 1) {
                self.items = [NSMutableArray new];
            }
            if (PinmoneyResponse.pocketMoney.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage =PinmoneyResponse.pocketMoney.count >= self.pageSize;
            [self.items addObjectsFromArray:PinmoneyResponse.pocketMoney];

            
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
