//
//  PSPrisonerAccountsRequest.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

@interface PSPrisonerAccountsRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *jailId;
@end
