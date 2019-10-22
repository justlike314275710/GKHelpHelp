//
//  PSAddLocalMeetingRequest.h
//  PrisonService
//
//  Created by calvin on 2018/5/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBaseLocalMeetingRequest.h"
#import "PSAddLocalMeetingResponse.h"

@interface PSAddLocalMeetingRequest : PSBaseLocalMeetingRequest

@property (nonatomic, strong) NSString *familyId;
//@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *uuid; //家属身份证
//@property (nonatomic, strong) NSString *phone;
//@property (nonatomic, strong) NSString *relationship;
@property (nonatomic, strong) NSString *applicationDate;
@property (nonatomic, strong) NSString *prisonerId;
@property (nonatomic, strong) NSString *jailId;

@end
