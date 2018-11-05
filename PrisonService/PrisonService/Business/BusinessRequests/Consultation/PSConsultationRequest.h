//
//  PSConsultationRequest.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

@interface PSConsultationRequest : PSBusinessRequest
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;
@end
