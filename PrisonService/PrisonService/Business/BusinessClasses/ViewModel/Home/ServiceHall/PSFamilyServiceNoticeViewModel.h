//
//  PSFamilyServiceNoticeViewModel.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBasePrisonerViewModel.h"
#import "PSUserSession.h"
NS_ASSUME_NONNULL_BEGIN

@interface PSFamilyServiceNoticeViewModel : PSBasePrisonerViewModel

@property (nonatomic, strong,readonly) NSArray *meeetHistorys;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;

- (void)refreshRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreRefundCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end

NS_ASSUME_NONNULL_END
