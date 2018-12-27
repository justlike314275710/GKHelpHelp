//
//  PSFeedbackRequest.m
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedbackRequest.h"

@implementation PSFeedbackRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"add";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/feedbacks/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.content forKey:@"content"];
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [parameters addParameter:self.imageUrls forKey:@"imageUrls"];
    [parameters addParameter:self.type forKey:@"type"];
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSFeedbackResponse class];
}

@end
