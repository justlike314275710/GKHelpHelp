//
//  PSAddLocalMeetingRequest.m
//  PrisonService
//
//  Created by calvin on 2018/5/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAddLocalMeetingRequest.h"

@implementation PSAddLocalMeetingRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"add";
    }
    return self;
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.familyId forKey:@"familyId"];
//    [parameters addParameter:self.name forKey:@"name"];
//    [parameters addParameter:self.uuid forKey:@"uuid"];
//    [parameters addParameter:self.phone forKey:@"phone"];
//    [parameters addParameter:self.relationship forKey:@"relationship"];
    [parameters addParameter:self.applicationDate forKey:@"applicationDate"];
    [parameters addParameter:self.prisonerId forKey:@"prisonerId"];
    [parameters addParameter:self.jailId forKey:@"jailId"];
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSAddLocalMeetingResponse class];
}

@end
