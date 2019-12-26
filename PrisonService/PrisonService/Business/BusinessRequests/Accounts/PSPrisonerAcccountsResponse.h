//
//  PSPrisonerAcccountsResponse.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "Accounts.h"
@interface PSPrisonerAcccountsResponse : PSResponse
@property (nonatomic, strong) NSArray<Accounts,Optional> *accounts;
@end
