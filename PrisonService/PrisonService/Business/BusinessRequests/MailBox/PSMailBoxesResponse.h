//
//  PSMailBoxesResponse.h
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSSuggestion.h"
#import "FeedbackTypeModel.h"

@interface PSMailBoxesResponse : PSResponse

@property (nonatomic, strong) NSArray<FeedbackTypeModel,Optional> *mailBoxes;

@end
