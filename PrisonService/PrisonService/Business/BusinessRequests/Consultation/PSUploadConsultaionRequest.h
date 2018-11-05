//
//  PSUploadConsultaionRequest.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

@interface PSUploadConsultaionRequest : PSBusinessRequest
@property (nonatomic, strong) NSData *consultaionData;
@end
