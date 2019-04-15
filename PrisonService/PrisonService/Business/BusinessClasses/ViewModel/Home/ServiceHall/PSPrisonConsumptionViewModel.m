//
//  PSPrisonConsumptionViewModel.m
//  PrisonService
//
//  Created by kky on 2019/3/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPrisonConsumptionViewModel.h"
#import "PSPrisonConsumptionRequest.h"
#import "PSPrisonConsumptionResponse.h"
#import "PSSessionManager.h"
@interface PSPrisonConsumptionViewModel ()
@property (nonatomic, strong) PSPrisonConsumptionRequest *recordsRequest;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *monthitems;

@end
@implementation PSPrisonConsumptionViewModel
@synthesize dataStatus = _dataStatus;

- (NSArray *)transactionRecords {
    return _items;
}

-(NSArray *)transMonths {
    NSMutableArray *ary = [self distinguishArrayWithArray:self.items];
    return ary;
}

-(NSMutableArray *)distinguishArrayWithArray:(NSArray *)dataSource
{
    //初始化一个空数组 用于return
    NSMutableArray *array = [NSMutableArray arrayWithArray:dataSource];
    
    NSMutableArray *dateMutablearray = [@[] mutableCopy];
    for (int i = 0; i < array.count; i ++) {
        
        PSPrisonConsumptionModel *mo = array[i];
        
        NSMutableArray *tempArray = [@[] mutableCopy];
        
        [tempArray addObject:mo];
        
        for (int j = i+1; j < array.count; j ++) {
            
            PSPrisonConsumptionModel *tmpmo = array[j];
            
            if([mo.month isEqualToString:tmpmo.month]){
                
                [tempArray addObject:tmpmo];
                
                [array removeObjectAtIndex:j];
                j -= 1;
                
            }
        }
        
        [dateMutablearray addObject:tempArray];
        
    }
    
    return dateMutablearray;
}


- (void)refreshRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
    self.page = 1;
    self.items = nil;
    self.monthitems = nil;
    self.hasNextPage = NO;
    self.dataStatus = PSDataInitial;
    [self requestRefundCompleted:completedCallback failed:failedCallback];
    
}

- (void)loadMoreRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page ++;
    [self requestRefundCompleted:completedCallback failed:failedCallback];
}

- (void)requestRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
    PSPrisonerDetail *prisonerDetail = nil;
    self.recordsRequest = [PSPrisonConsumptionRequest new];
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
          self.recordsRequest.prisonerId = prisonerDetail.prisonerId;
    }
    self.recordsRequest.page = self.page;
    self.recordsRequest.rows = self.pageSize;

    @weakify(self)
    [self.recordsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSPrisonConsumptionResponse *recordsResponse = (PSPrisonConsumptionResponse *)response;
            if (self.page == 1) {
                self.items = [NSMutableArray array];
            }
            if (recordsResponse.prisonerConsumes.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = recordsResponse.prisonerConsumes.count >= self.pageSize;
            [self.items addObjectsFromArray:recordsResponse.prisonerConsumes];
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
