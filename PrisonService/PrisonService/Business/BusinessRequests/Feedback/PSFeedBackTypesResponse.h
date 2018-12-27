//
//  PSFeedBackTypesResponse.h
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "FeedbackTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSFeedBackTypesResponse : PSResponse
@property (nonatomic, strong) NSArray<FeedbackTypeModel,Optional> *types;

@end

NS_ASSUME_NONNULL_END
