//
//  PSTransactionRecordViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSTransactionRecordViewModel.h"
#import "PSSessionManager.h"
#import "PSCache.h"
#import "PSBusinessConstants.h"
#import "PSTransactionRecord.h"
#import "PSTransactionRecordRequest.h"
#import "PSTransactionRecordResponse.h"

@interface PSTransactionRecordViewModel ()

@property (nonatomic, strong) PSTransactionRecordRequest *recordsRequest;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *monthitems;

@end

@implementation PSTransactionRecordViewModel
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
        
        PSTransactionRecord *mo = array[i];
        
        NSMutableArray *tempArray = [@[] mutableCopy];
        
        [tempArray addObject:mo];
        
        for (int j = i+1; j < array.count; j ++) {
            
            PSTransactionRecord *tmpmo = array[j];
            
            if([mo.createdMonth isEqualToString:tmpmo.createdMonth]){
                
                [tempArray addObject:tmpmo];
                
                [array removeObjectAtIndex:j];
                j -= 1;
                
            }
        }
        
        [dateMutablearray addObject:tempArray];
        
    }
    
    return dateMutablearray;
}




- (NSArray *)buildTransactionRecords:(NSArray *)transactionRecords {
    for (PSTransactionRecord *records in transactionRecords) {
        NSString *title = nil;
        NSString *balance = nil;
        CGFloat  money = [records.money floatValue];
        switch (records.type) {
            case PSRefundRecharge:
            {
                //title = @"电话卡充值";
                title =records.reason;
                balance=[NSString stringWithFormat:@"+%.2f",money];
            }
                break;
            case PSRefundMeeting:
            {
                title=NSLocalizedString(@"PSRefundMeeting", @"申请视频会见扣款");
                //title = @"申请视频会见扣款";
                balance=[NSString stringWithFormat:@"-%.2f",money];
            }
                break;
            case PSRefundRefund:
            {
                title = NSLocalizedString(@"PSRefundRefund", @"申请视频会见退款中");
                balance=[NSString stringWithFormat:@"-%.2f",money];
            }
                break;
                
            case PSRefundSuccess:{
                title = NSLocalizedString(@"PSRefundSuccess", @"退款成功");
                balance=[NSString stringWithFormat:@"-%.2f",money];
            }
                break;
                
            case PSRefundFail:{
                title = NSLocalizedString(@"PSRefundFail", @"退款失败");
                //title = @"退款失败";
                balance=[NSString stringWithFormat:@"%.2f",money];
            }
                break;
            case PSRefundCardRecharge:{
                 title = NSLocalizedString(@"Family card recharge", @"远程探视充值");

                balance=[NSString stringWithFormat:@"+%.2f",money];
            }
                break;
            default:
            {
                title=records.reason;
                balance=[NSString stringWithFormat:@"+%.2f",money];
            }
                break;
        }
        records.reason = title;
        records.money=balance;
    }
    return transactionRecords ;
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
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    
    self.recordsRequest = [PSTransactionRecordRequest new];
    self.recordsRequest.page = self.page;
    self.recordsRequest.rows = self.pageSize;
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    self.recordsRequest.familyId=self.session.families.id;
    self.recordsRequest.jailId = self.prisonerDetail.jailId;
    @weakify(self)
    [self.recordsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
           PSTransactionRecordResponse *recordsResponse = (PSTransactionRecordResponse *)response;
            if (self.page == 1) {
                self.items = [NSMutableArray array];
            }
            self.transMonths = [NSMutableArray array];
            if (recordsResponse.details.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = recordsResponse.details.count >= self.pageSize;
           // [self.items addObjectsFromArray:recordsResponse.details];
            NSMutableArray *ary = [NSMutableArray array];
            for (NSDictionary *dic in recordsResponse.accounts) {
                
                PSTransactionSuperRecord *model =  [[PSTransactionSuperRecord alloc] initWithDictionary:dic error:nil];
                NSArray *PSTransactionRecords = model.details;
                for (PSTransactionRecord *recordModel in PSTransactionRecords) {
                    recordModel.rechargeTotal = model.rechargeTotal;
                    recordModel.refundTotal = model.refundTotal;
                    recordModel.createdMonth = model.createdMonth;
                    recordModel.consumeTotal = model.consumeTotal;
                    [ary addObject:recordModel];
                }
                
            }
            
//            [self.items addObjectsFromArray:[self buildTransactionRecords:recordsResponse.details]];
            [self.items addObjectsFromArray:[self buildTransactionRecords:ary]];
//            [self.monthitems addObjectsFromArray:recordsResponse.accounts];
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
