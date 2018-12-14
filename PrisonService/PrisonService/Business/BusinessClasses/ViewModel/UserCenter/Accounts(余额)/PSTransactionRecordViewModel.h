//
//  PSTransactionRecordViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBaseServiceViewModel.h"
#import "PSTransactionRecord.h"
#import "PSUserSession.h"
@interface PSTransactionRecordViewModel : PSBaseServiceViewModel
@property (nonatomic, strong) NSArray *transactionRecords;
@property (nonatomic, strong) NSArray *transMonths;
@property (nonatomic, strong) PSUserSession *session;

- (void)refreshRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
@end
