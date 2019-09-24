//
//  PSMyTotalArtcleListViewModel.h
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSMyTotalArtcleListViewModel : PSViewModel
@property (nonatomic, strong, readonly) NSArray *articles_notpublished;
@property (nonatomic, strong, readonly) NSArray *articles_notpass;
@property (nonatomic, strong, readonly) NSArray *articles_published;
@property (nonatomic, strong) NSMutableArray *articles;



@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;

- (void)refreshMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
@end

NS_ASSUME_NONNULL_END
