//
//  PSMeetingsCoordinate.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSMeetingsBaseRequest.h"
#import "PSMeetingsCoordinateResponse.h"
@interface PSMeetingsCoordinateRequest : PSMeetingsBaseRequest
@property (nonatomic, strong) NSString *meetingId;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@end
