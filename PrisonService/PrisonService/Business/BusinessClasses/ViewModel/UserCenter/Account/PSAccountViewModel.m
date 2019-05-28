//
//  PSAccountViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAccountViewModel.h"
#import "PSSessionManager.h"
#import "NSString+Date.h"
#import "NSDate+Components.h"
#import "PSCache.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"

@implementation PSAccountViewModel
{
    AFHTTPSessionManager *manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.f;
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
         [manager.requestSerializer setValue:[PSSessionManager sharedInstance].session.token forHTTPHeaderField:@"Authorization"];
//        PSPrisonerDetail *prisonerDetail = nil;
//        NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
//        NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
//        if (index >= 0 && index < details.count) {
//            prisonerDetail = details[index];
//        }
//
//        NSMutableArray *items = [NSMutableArray array];
//
//
//
//        PSAccountInfoItem *phoneItem = [PSAccountInfoItem new];
//        phoneItem.itemName = @"联系电话";
//        phoneItem.itemIconName = @"userCenterAccountPhone";
//        phoneItem.infoText = [PSSessionManager sharedInstance].session.families.phone;
//        [items addObject:phoneItem];
//        /*
//        PSAccountInfoItem *cardItem = [PSAccountInfoItem new];
//        cardItem.itemName = @"身份证号";
//        cardItem.itemIconName = @"userCenterAccountCard";
//        cardItem.infoText = @"4303******2559";
//        [items addObject:cardItem];
//         */
//        PSRegistration *registration = [PSSessionManager sharedInstance].currentRegistration;
//        PSAccountInfoItem *relationItem = [PSAccountInfoItem new];
//        relationItem.itemName = @"家庭地址";
//        relationItem.itemIconName = @"userCenterAccountAddress";
//        relationItem.infoText = @"未填写";
//        [items addObject:relationItem];
//
//
//
//        PSAccountInfoItem *nameItem = [PSAccountInfoItem new];
//        nameItem.itemName = @"邮编";
//        nameItem.itemIconName = @"userCenterAccountEmail";
//        nameItem.infoText = @"未填写";
//        [items addObject:nameItem];
        
//        PSAccountInfoItem *dateItem = [PSAccountInfoItem new];
//        dateItem.itemName = @"服刑人员刑期";
//        dateItem.itemIconName = @"userCenterAccountDate";
//        NSDate *startDate = [prisonerDetail.termStart stringToDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//        NSDate *endDate = [prisonerDetail.termFinish stringToDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//        if (startDate && endDate) {
//            dateItem.infoText = [NSString stringWithFormat:@"%@至%@",startDate.yearMonthDay,endDate.yearMonthDay];
//        }
//        [items addObject:dateItem];
        
        
//        PSAccountInfoItem *sexItem = [PSAccountInfoItem new];
//        sexItem.itemName = @"服刑人员性别";
//        sexItem.itemIconName = @"userCenterAccountSex";
//        sexItem.infoText = registration.gender;
//        [items addObject:sexItem];
//
//        _infoItems = items;
        
        
    }
    return self;
}

- (void)requestAccountBasicinfoCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*url=[NSString stringWithFormat:@"%@/families/basicInfo",ServerUrl];
    NSDictionary*parmeters=@{
                             @"familyId":self.session.families.id
                             };
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [ manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parmeters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *items = [NSMutableArray array];
        
        PSAccountInfoItem *sexItem = [PSAccountInfoItem new];
        NSString*genderSting=NSLocalizedString(@"gender", @"性别");
        sexItem.itemName = genderSting;
        sexItem.itemIconName = @"userCenterAccountSex";
        NSString*man=NSLocalizedString(@"man", @"男");
        NSString*weomen=NSLocalizedString(@"women", @"女");
        NSString*gender=responseObject[@"data"][@"families"][@"gender"];
        if ([gender isEqualToString:@"男"]) {
            sexItem.infoText=man;
        }
        else{
            sexItem.infoText=weomen;
        }
        //sexItem.infoText = gender?gender:@"未填写";
        [items addObject:sexItem];

        
        PSAccountInfoItem *phoneItem = [PSAccountInfoItem new];
        NSString*Contact_phonenumber=NSLocalizedString(@"Contact_phonenumber", @"联系电话");
        phoneItem.itemName =Contact_phonenumber;
        phoneItem.itemIconName = @"userCenterAccountPhone";
        phoneItem.infoText = [PSSessionManager sharedInstance].session.families.phone;
        [items addObject:phoneItem];
        
        PSAccountInfoItem *relationItem = [PSAccountInfoItem new];
        NSString*Home_address=NSLocalizedString(@"Home_address", @"家庭地址");
        relationItem.itemName = Home_address;
        relationItem.itemIconName = @"userCenterAccountAddress";
        NSString*address=responseObject[@"data"][@"families"][@"homeAddress"];
        if (isNull(address)) {
            relationItem.infoText=@"未填写";
        } else {
            relationItem.infoText = address;
        }
        //relationItem.infoText = address?address:@"未填写";
        [items addObject:relationItem];
        
        
        PSAccountInfoItem *nameItem = [PSAccountInfoItem new];
        NSString*Zip_code=NSLocalizedString(@"Zip_code", @"邮编");
        nameItem.itemName = Zip_code;
        nameItem.itemIconName = @"userCenterAccountEmail";
        NSString*email=responseObject[@"data"][@"families"][@"postalCode"];
        if (isNull(email)) {
            nameItem.infoText=@"未填写";
        }
        else{
            nameItem.infoText = email;
        }
        [items addObject:nameItem];
        
        _infoItems = items;
        
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


@end
