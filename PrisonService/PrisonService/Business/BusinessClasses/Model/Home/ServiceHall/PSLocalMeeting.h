//
//  PSLocalMeeting.h
//  PrisonService
//
//  Created by calvin on 2018/5/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

@interface PSLocalMeeting : JSONModel

@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *applicationDate;
@property (nonatomic, strong) NSString<Optional> *createdAt;
@property (nonatomic, strong) NSString<Optional> *visitAddress;
@property (nonatomic, strong) NSString<Optional> *address;
@property (nonatomic, strong) NSString<Optional> *status;
@property (nonatomic, strong) NSString<Optional> *remarks;
@property (nonatomic, strong) NSString<Optional> *batch;

@end
