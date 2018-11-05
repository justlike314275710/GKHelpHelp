//
//  PSRemittanceResponse.h
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSWechatInfo.h"

@interface PSRemittanceResponse : PSResponse

@property (nonatomic, strong) PSWechatInfo<Optional> *data;

@end


