//
//  PSPrisonConsumptionRequest.h
//  PrisonService
//
//  Created by kky on 2019/3/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

@interface PSPrisonConsumptionRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *prisonerId;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;

@end


