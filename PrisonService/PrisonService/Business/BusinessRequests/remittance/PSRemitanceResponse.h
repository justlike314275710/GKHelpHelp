//
//  PSRemitanceResponse.h
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "RemittanceRecode.h"

@interface PSRemitanceResponse : PSResponse

@property (nonatomic, strong) NSArray<RemittanceRecode,Optional> *familyRemits;

@end

