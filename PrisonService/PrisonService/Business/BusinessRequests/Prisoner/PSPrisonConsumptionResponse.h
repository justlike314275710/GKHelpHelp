//
//  PSPrisonConsumptionResponse.h
//  PrisonService
//
//  Created by kky on 2019/3/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSPrisonConsumptionModel.h"

@interface PSPrisonConsumptionResponse : PSResponse
@property(nonatomic,strong)NSArray<PSPrisonConsumptionModel,Optional> *prisonerConsumes;
@end


