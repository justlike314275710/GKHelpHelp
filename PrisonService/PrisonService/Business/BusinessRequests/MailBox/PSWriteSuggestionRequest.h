//
//  PSWriteSuggestionRequest.h
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBaseMailBoxRequest.h"
#import "PSWriteSuggestionResponse.h"

@interface PSWriteSuggestionRequest : PSBaseMailBoxRequest

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *contents;
@property (nonatomic, strong) NSString *jailId;
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *imageUrls;
@end
