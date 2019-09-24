//
//  PSCountVisitResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSMessageCountModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCountVisitResponse : PSResponse
@property (nonatomic, strong) NSArray<PSMessageCountModel,Optional> *mesageCounts;





@end

NS_ASSUME_NONNULL_END
