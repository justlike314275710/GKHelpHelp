//
//  PSWorkViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBaseServiceViewModel.h"
#import "PSNews.h"
#import "PSNewsRequest.h"

@interface PSWorkViewModel : PSBaseServiceViewModel

@property (nonatomic, strong, readonly) NSArray *newsData;
@property (nonatomic, strong, readonly) NSArray *advertisements;
@property (nonatomic, strong, readonly) NSArray *advUrls;
@property (nonatomic, assign) PSNewsType newsType;
@property (nonatomic , strong) NSString *jailId;
@property (nonatomic, strong, readonly) NSArray *passedPrisonerDetails;
@property (nonatomic, assign) NSInteger selectedPrisonerIndex;

- (void)refreshNewsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMoreNewsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)refreshAllDataCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
