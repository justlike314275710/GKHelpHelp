//
//  PSFeedbackRequest.h
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSFeedbackResponse.h"

@interface PSFeedbackRequest : PSBusinessRequest

@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *imageUrls;

@end
