//
//  PSFreeMeetingCoordinateRequest.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/29.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSFreeMeetingCoordinateResponse.h"
@interface PSFreeMeetingCoordinateRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *meetingId;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@end
