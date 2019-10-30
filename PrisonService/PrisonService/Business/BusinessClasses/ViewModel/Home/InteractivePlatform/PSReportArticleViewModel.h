//
//  PSReportArticleViewModel.h
//  PrisonService
//
//  Created by kky on 2019/10/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSArticleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSReportArticleViewModel : PSViewModel
@property (nonatomic, copy  ) NSString             *id;
@property (nonatomic, strong) PSArticleDetailModel *detailModel;
@property (nonatomic, copy  ) NSString             *reportReason;
- (void)requestReportArticleCompleted:(RequestDataTaskCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end

NS_ASSUME_NONNULL_END
