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
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) PSArticleDetailModel *detailModel;

@end

NS_ASSUME_NONNULL_END
