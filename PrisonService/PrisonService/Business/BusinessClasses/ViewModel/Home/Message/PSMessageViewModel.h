//
//  PSMessageViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSMessage.h"
#import "PSPrisonerDetail.h"

@interface PSMessageViewModel : PSViewModel

@property (nonatomic, strong, readonly) NSArray *messages;
@property (nonatomic, strong) PSPrisonerDetail *prisonerDetail;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;
@property (nonatomic, strong) NSString *type; //type = 3 实地会见

- (void)refreshMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
