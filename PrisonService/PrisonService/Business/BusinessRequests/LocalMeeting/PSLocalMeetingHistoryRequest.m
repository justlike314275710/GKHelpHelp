//
//  PSLocalMeetingHistoryRequest.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSLocalMeetingHistoryRequest.h"
#import "PSLocalMeetingHistoryResponse.h"

@implementation PSLocalMeetingHistoryRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"history";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/prisoner_visits/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSLocalMeetingHistoryResponse class];
}
@end
