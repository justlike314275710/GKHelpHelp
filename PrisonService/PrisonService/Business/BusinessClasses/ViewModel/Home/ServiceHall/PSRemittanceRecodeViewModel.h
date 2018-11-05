//
//  PSRemittanceRecodeViewModel.h
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSUserSession.h"
@interface PSRemittanceRecodeViewModel : PSViewModel

@property (nonatomic, strong,readonly) NSArray *Recodes;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;

- (void)refreshPinmoneyCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMorePinmoneyCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end


