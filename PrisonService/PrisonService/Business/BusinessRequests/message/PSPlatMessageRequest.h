//
//  PSPlatMessageRequest.h
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPlatMessageRequest : PSBusinessRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, strong) NSString *prisonerId;
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *type;

@end

NS_ASSUME_NONNULL_END
