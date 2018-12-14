//
//  PSUserSession.h
//  PrisonService
//
//  Created by calvin on 2018/4/19.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"
#import "PSRegistration.h"
#import "PSFamily.h"

@interface PSUserSession :JSONModel

@property (nonatomic, strong) NSArray<PSRegistration,Optional> *registrations;
@property (nonatomic, strong) PSFamily<Optional> *families;
@property (nonatomic, strong) NSString<Optional> *token;
@property (nonatomic ,strong) NSString <Optional> *status;
@property (nonatomic ,strong) NSString <Optional> *account;

@end
