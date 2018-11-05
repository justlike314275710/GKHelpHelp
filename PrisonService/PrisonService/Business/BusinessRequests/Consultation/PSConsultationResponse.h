//
//  PSConsultationResponse.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSConsultation.h"
@interface PSConsultationResponse : PSResponse
@property (nonatomic, strong) NSArray<PSConsultation,Optional> *Consultation;
@end
