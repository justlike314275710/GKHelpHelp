//
//  PSFamilyServiceNoticeResponse.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSFamilyServiceNoticeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSFamilyServiceNoticeResponse : PSResponse
@property (nonatomic, strong) NSArray<PSFamilyServiceNoticeModel,Optional> *logs;

@end

NS_ASSUME_NONNULL_END
