//
//  PSTransactionRecordResponse.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSTransactionRecord.h"

@interface PSTransactionRecordResponse : PSResponse
@property(nonatomic,strong)  NSArray<PSTransactionRecord,Optional> *details;
@property(nonatomic,strong)  NSString<Optional> *total;
@end
