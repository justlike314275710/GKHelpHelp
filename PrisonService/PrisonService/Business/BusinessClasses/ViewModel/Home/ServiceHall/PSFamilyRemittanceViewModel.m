//
//  PSFamilyRemittanceViewModel.m
//  PrisonService
//
//  Created by kky on 2018/10/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFamilyRemittanceViewModel.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"
#import "PSSessionManager.h"

@implementation PSFamilyRemittanceViewModel

-(id)init{
    self=[super init];
    if (self) {
    }
    return self;
}

- (NSArray *)criminals {
    return [PSSessionManager sharedInstance].passedPrisonerDetails;
}

- (void)checkDataWithCallback:(CheckDataCallback)callback {
    
    if (![self validaMoney:self.money]) {
        if (callback) {
            NSString*please_enter_phone_number=NSLocalizedString(@"please_input_the_correct_amount", @"请输入正确的金额");
            callback(NO,please_enter_phone_number);
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (BOOL)validaMoney:(NSString *)money {
    BOOL flag;
    if (money.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *phoneRegex = @"^[0-9]+(\\.[0-9]{1,2})?$";
    NSPredicate *regex2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [regex2 evaluateWithObject:money];
}



@end
