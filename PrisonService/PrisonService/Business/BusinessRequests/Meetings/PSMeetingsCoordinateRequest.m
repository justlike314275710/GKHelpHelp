//
//  PSMeetingsCoordinate.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSMeetingsCoordinateRequest.h"

@implementation PSMeetingsCoordinateRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"updateMeetingCoordinate";
        self.parameterType=PSPostParameterFormData;
    }
    return self;
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.meetingId forKey:@"meetingId"];
    [parameters addParameter:self.lat forKey:@"lat"];
    [parameters addParameter:self.lng forKey:@"lng"];
    [parameters addParameter:self.province forKey:@"province"];
    [parameters addParameter:self.city forKey:@"city"];
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSMeetingsCoordinateResponse class];
}
@end
