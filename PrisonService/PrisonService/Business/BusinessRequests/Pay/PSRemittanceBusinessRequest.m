//
//  PSRemittanceBusinessRequest.m
//  PrisonService
//
//  Created by kky on 2018/10/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRemittanceBusinessRequest.h"

@implementation PSRemittanceBusinessRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodPost;
        self.serviceName = @"remit";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/family_remit/";
}

- (void)buildPostParameters:(PSMutableParameters *)parameters {
    
    [parameters addParameter:self.jailId forKey:@"jailId"];
    [parameters addParameter:self.familyId forKey:@"familyId"];
    [parameters addParameter:self.prisonerId forKey:@"prisonerId"];
    [parameters addParameter:self.remitType forKey:@"remitType"];
    [parameters addParameter:self.money forKey:@"money"];
    [super buildPostParameters:parameters];
}

- (Class)responseClass {
    //1 微信 0 支付宝
    if ([self.remitType isEqualToString:@"1"]) {
        return [PSRemittanceResponse class];
    } else {
        return [PSAlipayResponse class];
    }
}

@end
