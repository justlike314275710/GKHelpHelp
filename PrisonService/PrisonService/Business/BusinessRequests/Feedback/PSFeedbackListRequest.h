//
//  PSFeedbackListRequest.h
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSFeedbackListRequest : PSBusinessRequest
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, strong) NSString *familyId;

@end

NS_ASSUME_NONNULL_END
