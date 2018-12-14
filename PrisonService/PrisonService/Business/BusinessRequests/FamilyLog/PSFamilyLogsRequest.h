//
//  PSFamilyLogsRequest.h
//  PrisonService
//
//  Created by calvin on 2018/4/24.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSFamilyLogsResponse.h"

@interface PSFamilyLogsRequest : PSBusinessRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, strong) NSString *prisonerId;
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *type;

@end
