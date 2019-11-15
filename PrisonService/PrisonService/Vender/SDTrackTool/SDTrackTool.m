//
//  SDTrackTool.m
//  sdtrack
//
//  Created by lisd on 2017/4/26.
//  Copyright © 2017年 kingnet. All rights reserved.
//
#define UMENG_KEY @"5c0dc572b465f5a1210001d6"

#import "SDTrackTool.h"
#import <UMMobClick/MobClick.h>
#import "PSSessionManager.h"


@implementation SDTrackTool

+ (void)configure {
    
    UMConfigInstance.appKey = UMENG_KEY;
    UMConfigInstance.eSType = E_UM_NORMAL;
//    UMConfigInstance.ePolicy = 0;
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:currentVersion];
    [MobClick startWithConfigure:UMConfigInstance];
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
    [MobClick setCrashReportEnabled:YES];
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if (cls && [cls respondsToSelector: deviceIDSelector]) {
        deviceID = [cls performSelector: deviceIDSelector];
    }
    NSData * jsonData =[NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
                                                       options: NSJSONWritingPrettyPrinted
                                                        error: nil];
    NSLog(@"%@", [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding]);
#endif
    
}
+(void)beginLogPageID:(NSString *)pageID {
    [MobClick beginLogPageView:pageID];
}
+(void)endLogPageID:(NSString *)pageID {
    [MobClick endLogPageView:pageID];
}
+(void)logEvent:(NSString*)eventId {
    [MobClick event:eventId];
}
+(void)logEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSMutableDictionary *mdic = [attributes mutableCopy];
    [mdic setObject:[self getConfigOfJaiName] forKey:JAIL_NAME];
    [MobClick event:eventId attributes:mdic];
}
+(NSString *)getConfigOfJaiName {
    NSString *jailName = @"";
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *Prisoners = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < Prisoners.count){
        prisonerDetail = Prisoners[index];
        jailName = prisonerDetail.jailName;
    }
    return jailName;
}

@end
