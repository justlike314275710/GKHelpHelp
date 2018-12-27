//
//  PSFeedbackDetailResponse.h
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "FeedbackTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSFeedbackDetailResponse : PSResponse

@property (nonatomic,strong) FeedbackTypeModel *detail;

@end

NS_ASSUME_NONNULL_END
