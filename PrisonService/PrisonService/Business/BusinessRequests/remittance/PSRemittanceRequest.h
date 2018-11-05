//
//  PSRemittanceRequest.h
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRequest.h"
#import "PSBusinessRequest.h"

@interface PSRemittanceRequest : PSBusinessRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, strong) NSString *familyId;

@end


