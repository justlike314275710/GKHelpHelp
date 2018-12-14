//
//  PSFamily.h
//  PrisonService
//
//  Created by calvin on 2018/4/20.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

@interface PSFamily :JSONModel

@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *phone;
@property (nonatomic, strong) NSString<Optional> *uuid;
@property (nonatomic, strong) NSString<Optional> *openId;
@property (nonatomic, strong) NSString<Optional> *avatarUrl;
@property (nonatomic, strong) NSString<Optional> *idCardFront;
@property (nonatomic, strong) NSString<Optional> *idCardBack;
@property (nonatomic, assign) CGFloat balance;
@property (nonatomic, strong) NSString<Optional> *isNoticed;
@property (nonatomic ,strong) NSString *createdAt;
@end
