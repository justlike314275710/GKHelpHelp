//
//  PSRemittanceRecodeViewModel.m
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRemittanceRecodeViewModel.h"
#import "PSRemittanceRequest.h"
#import "PSRemitanceResponse.h"
#import "PSSessionManager.h"
#import "PSBusinessConstants.h"

@interface PSRemittanceRecodeViewModel ()
@property (nonatomic , strong) PSRemittanceRequest *remittanceRequest;
@property (nonatomic , strong) NSMutableArray *items;
@end

@implementation PSRemittanceRecodeViewModel
@synthesize dataStatus = _dataStatus;

-(id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 10;
    }
    return self;
}

-(NSArray*)Recodes{
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
    
    self.remittanceRequest = [PSRemittanceRequest new];
    self.remittanceRequest.page = self.page;
    self.remittanceRequest.rows = self.pageSize;
    self.remittanceRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
    
    @weakify(self)
    [self.remittanceRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSRemitanceResponse *RemitanceResponse= (PSRemitanceResponse *)response;
            if (self.page == 1) {
                self.items = [NSMutableArray new];
            }
            if (RemitanceResponse.familyRemits.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage =RemitanceResponse.familyRemits.count >= self.pageSize;
            [self.items addObjectsFromArray:RemitanceResponse.familyRemits];
            
            
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
