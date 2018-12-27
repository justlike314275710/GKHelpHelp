//
//  PSBusinessRequest.m
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSBusinessConstants.h"
#import "PSSessionManager.h"

@implementation PSBusinessRequest

- (NSString *)serverURL {
    return ServerUrl;
}

- (void)buildHeaders:(PSMutableParameters *)headers {
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString* language = langArr.firstObject;
    if ([LXFileManager readUserDataForKey:@"access_token"]) {
        if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
             [headers addParameter:@"vietnam" forKey:@"Language"];
        }
        [headers addParameter:token forKey:@"Authorization"];
        [super buildHeaders:headers];
    } else {
         [super buildHeaders:headers];
    }
}

@end
