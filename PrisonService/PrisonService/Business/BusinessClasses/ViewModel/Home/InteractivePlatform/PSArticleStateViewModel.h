//
//  PSArticleStateViewModel.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSArticleStateViewModel : PSViewModel
@property (nonatomic, strong, readonly) NSArray *messages;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, copy)   NSString *status;

- (void)refreshMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end

NS_ASSUME_NONNULL_END
