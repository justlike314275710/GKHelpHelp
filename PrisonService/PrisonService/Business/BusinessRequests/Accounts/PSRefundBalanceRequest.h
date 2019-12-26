//
//  PSRefundBalanceRequest.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

@interface PSRefundBalanceRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *jailId;
@end
