//
//  PSCollectListRequest.h
//  PrisonService
//
//  Created by kky on 2019/9/11.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCollectListRequest : PSBusinessRequest
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;

@end

NS_ASSUME_NONNULL_END
