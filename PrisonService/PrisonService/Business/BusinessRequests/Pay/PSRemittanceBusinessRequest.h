//
//  PSRemittanceBusinessRequest.h
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSRemittanceResponse.h"
#import "PSAlipayResponse.h"


@interface PSRemittanceBusinessRequest : PSBusinessRequest

@property (nonatomic, strong) NSString *jailId;
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *prisonerId;
@property (nonatomic, assign) NSString *remitType;
@property (nonatomic, assign) NSString *money;





@end


