//
//  PSLocalMeetCancelRequest.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSLocalMeetCancelRequest.h"
#import "PSMeetCancelResponse.h"
@implementation PSLocalMeetCancelRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"applyCancel";
        
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/prisoner_visits/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.ID forKey:@"ID"];
    [parameters addParameter:self.cause forKey:@"cause"];
    [super buildParameters:parameters];
}


- (Class)responseClass {
    return [PSMeetCancelResponse class];
}
@end
