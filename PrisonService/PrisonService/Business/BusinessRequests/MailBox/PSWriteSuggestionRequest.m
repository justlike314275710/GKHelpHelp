//
//  PSWriteSuggestionRequest.m
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWriteSuggestionRequest.h"

@implementation PSWriteSuggestionRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"add";
    }
    return self;
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:self.title forKey:@"title"];
    [parameters addParameter:self.contents forKey:@"contents"];
    [parameters addParameter:self.jailId forKey:@"jailId"];
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [parameters addParameter:self.type forKey:@"type"];
    [parameters addParameter:self.imageUrls forKey:@"imageUrls"];
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    return [PSWriteSuggestionResponse class];
}

@end
