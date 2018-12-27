//
//  PSFeedbackListRequest.m
//  PrisonService
//
//  Created by kky on 2018/12/26.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedbackListRequest.h"
#import "PSFeedbackListResponse.h"

@implementation PSFeedbackListRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"page";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/feedbacks/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.page] forKey:@"page"];
    [parameters addParameter:[NSString stringWithFormat:@"%ld",(long)self.rows] forKey:@"rows"];
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSFeedbackListResponse class];
}

@end
