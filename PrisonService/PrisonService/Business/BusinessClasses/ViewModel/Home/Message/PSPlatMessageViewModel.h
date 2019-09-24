//
//  PSPlatMessageViewModel.h
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSMessage.h"
#import "PSPrisonerDetail.h"

@interface PSPlatMessageViewModel : PSViewModel

@property (nonatomic, strong, readonly) NSArray *messages;
@property (nonatomic, strong) PSPrisonerDetail *prisonerDetail;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, strong) NSString *type; //type = 4 互动文章

- (void)refreshMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end

