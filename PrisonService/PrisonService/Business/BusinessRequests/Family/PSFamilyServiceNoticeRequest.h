//
//  PSFamilyServiceNoticeRequest.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSFamilyServiceNoticeRequest : PSFamilyBaseRequest
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) NSInteger familyId;
@end

NS_ASSUME_NONNULL_END
