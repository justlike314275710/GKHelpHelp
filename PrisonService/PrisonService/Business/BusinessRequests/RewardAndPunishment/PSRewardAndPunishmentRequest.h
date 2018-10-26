//
//  PSRewardAndPunishmentRequest.h
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSRewardAndPunishmentResponse.h"

@interface PSRewardAndPunishmentRequest : PSBusinessRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, strong) NSString *prisonerId;
@property (nonatomic, strong) NSString *jailId;

@end
