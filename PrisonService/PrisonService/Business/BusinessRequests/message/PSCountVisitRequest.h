//
//  PSCountVisitRequest.h
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCountVisitRequest : PSBusinessRequest
@property (nonatomic, strong)NSString *familyId;

@end

NS_ASSUME_NONNULL_END
