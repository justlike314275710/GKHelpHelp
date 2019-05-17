//
//  PSPrisonerPreCheckRequest.h
//  PrisonService
//
//  Created by kky on 2019/5/15.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPrisonerPreCheckRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *jailId;
@property (nonatomic, strong) NSString *applicationDate;
@property (nonatomic, strong) NSString *prisonerId;
@end

NS_ASSUME_NONNULL_END
