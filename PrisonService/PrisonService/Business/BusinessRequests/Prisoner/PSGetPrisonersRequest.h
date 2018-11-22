//
//  PSGetPrisonersRequest.h
//  PrisonService
//
//  Created by kky on 2018/11/22.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSGetPrisonerResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSGetPrisonersRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *jailId;

@end

NS_ASSUME_NONNULL_END
