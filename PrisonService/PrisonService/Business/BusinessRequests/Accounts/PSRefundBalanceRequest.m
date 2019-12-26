//
//  PSRefundBalanceRequest.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRefundBalanceRequest.h"
#import "PSRefundBalanceRespense.h"
@implementation PSRefundBalanceRequest
- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"apply";
    }
    return self;
}

-(void)buildPostParameters:(PSMutableParameters *)parameters{
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [parameters addParameter:self.jailId forKey:@"jailId"];
    [super buildPostParameters:parameters];
}

- (NSString *)businessDomain {
    return @"/refund/";
}

- (Class)responseClass {
    return [PSRefundBalanceRespense class];
}
@end
