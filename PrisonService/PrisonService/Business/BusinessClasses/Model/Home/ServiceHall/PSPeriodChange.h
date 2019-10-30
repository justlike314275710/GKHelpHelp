//
//  PSPeriodChange.h
//  PrisonService
//
//  Created by calvin on 2018/4/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

@protocol PSPeriodChange <NSObject>

@end

@interface PSPeriodChange : JSONModel

@property (nonatomic, strong) NSString<Optional > *updatedAt;
@property (nonatomic, strong) NSString<Optional > *changetype;
@property (nonatomic, assign) NSInteger changeyear;
@property (nonatomic, assign) NSInteger changemonth;
@property (nonatomic, assign) NSInteger changeday;
@property (nonatomic, strong) NSString<Optional> *termFinish;

@end
