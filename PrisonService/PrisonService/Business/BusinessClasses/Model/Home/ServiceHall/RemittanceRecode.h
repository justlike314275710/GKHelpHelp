//
//  RemittanceRecode.h
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol RemittanceRecode <NSObject>
@end

@interface RemittanceRecode : JSONModel

@property (nonatomic, strong) NSString<Optional> *status;
@property (nonatomic, strong) NSString<Optional> *prisonerNumber;
@property (nonatomic, strong) NSString<Optional> *remitNum;
@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *familyId;
@property (nonatomic, strong) NSString<Optional> *prisonerName;
@property (nonatomic, strong) NSString<Optional> *createdAt;
@property (nonatomic, strong) NSString<Optional> *money;

@end


