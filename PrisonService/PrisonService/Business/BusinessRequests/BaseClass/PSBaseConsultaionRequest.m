//
//  PSBaseConsultaionRequest.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBaseConsultaionRequest.h"
#import "PSBusinessConstants.h"
@implementation PSBaseConsultaionRequest


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
