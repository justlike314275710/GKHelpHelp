//
//  PSPrisonConsumptionViewModel.h
//  PrisonService
//
//  Created by kky on 2019/3/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBaseServiceViewModel.h"

@interface PSPrisonConsumptionViewModel : PSBaseServiceViewModel
@property (nonatomic, strong) NSArray *transactionRecords;
@property (nonatomic, strong) NSArray *transMonths;

- (void)refreshRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end


