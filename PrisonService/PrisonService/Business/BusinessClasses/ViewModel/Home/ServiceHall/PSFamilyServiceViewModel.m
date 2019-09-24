//
//  PSFamilyServiceViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFamilyServiceViewModel.h"
#import "NSString+Date.h"
#import "NSDate+Components.h"
#import "PSSessionManager.h"
#import "PSGetPrisonersRequest.h"
#import "PSCache.h"
#import "PSBusinessConstants.h"
#import "PSUserSession.h"
#import <AFNetworking/AFNetworking.h>
#import "MeetJails.h"
#import "MJExtension.h"
@interface PSFamilyServiceViewModel(){
        AFHTTPSessionManager *manager;
}

@property (nonatomic,strong) PSGetPrisonersRequest *getPrisonersRequest;
@property (nonatomic,strong) PSGetPrisonerResponse *getPrisonerResponse;

@end

@implementation PSFamilyServiceViewModel
- (id)init {
    self = [super init];
    if (self) {
        
        _array = [NSMutableArray array];
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.f;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"" password:@""];
        NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        
        
        NSMutableArray *items = [NSMutableArray array];
        NSString*prisonName=@"服刑监狱";
        PSFamilyServiceItem *prison = [PSFamilyServiceItem new];
        prison.itemIconName = @"服刑监狱icon";
        prison.itemName = prisonName;
        prison.content = self.prisonerDetail.jailName;
        [items addObject:prison];
        
        
        NSString*sentence=NSLocalizedString(@"sentence", @"原判刑期");
        PSFamilyServiceItem *periodItem = [PSFamilyServiceItem new];
        periodItem.itemIconName = @"serviceHallPeriodIcon";
        periodItem.itemName = sentence;
        periodItem.content = self.prisonerDetail.originalSentence;
        [items addObject:periodItem];
        

        NSString*sentence_start=NSLocalizedString(@"sentence_start", @"原判刑期起日");
        PSFamilyServiceItem *startItem = [PSFamilyServiceItem new];
        startItem.itemIconName = @"serviceHallStartIcon";
        startItem.itemName =sentence_start;
        startItem.content = [self.prisonerDetail.startedAt timestampToDateString];
        [items addObject:startItem];
        
        NSString*sentence_end=NSLocalizedString(@"sentence_end", @"原判刑期止日");
        PSFamilyServiceItem *endItem = [PSFamilyServiceItem new];
        endItem.itemIconName = @"serviceHallEndIcon";
        endItem.itemName = sentence_end;
        endItem.content = [self.prisonerDetail.endedAt timestampToDateString];
        [items addObject:endItem];
        

        NSString*Reduced_number=NSLocalizedString(@"Reduced_number", @"累计减刑次数");
        PSFamilyServiceItem *reduceItem = [PSFamilyServiceItem new];
        reduceItem.itemIconName = @"serviceHallReduceIcon";
        reduceItem.itemName = Reduced_number;
        NSString*one=NSLocalizedString(@"one", @"次");
        reduceItem.content = [NSString stringWithFormat:@"%ld%@",(long)self.prisonerDetail.times,one];
        [items addObject:reduceItem];
        
        NSString*Current_term=NSLocalizedString(@"Current_term", @"现刑期止日");
        PSFamilyServiceItem *lastReduceItem = [PSFamilyServiceItem new];
        lastReduceItem.itemIconName = @"serviceHallLastReduceIcon";
        lastReduceItem.itemName = Current_term;
        NSString * ALLtermFinishString= self.prisonerDetail.termFinish;
        NSString *termFinishString;
        if (ALLtermFinishString.length!=0) {
              termFinishString = [self.prisonerDetail.termFinish substringToIndex:10];
        } else {
             termFinishString=[self.prisonerDetail.endedAt timestampToDateString];;
        }
       
        lastReduceItem.content=termFinishString;
        [items addObject:lastReduceItem];
        _familyServiceItems = items;
        
        NSString*Pocket_money=NSLocalizedString(@"Pocket_money", @"零花钱情况");
        NSMutableArray *otherItems = [NSMutableArray array];
        PSFamilyServiceItem *changeItem = [PSFamilyServiceItem new];
        changeItem.itemIconName = @"serviceHallPinmoneyIcon";
        changeItem.itemName = Pocket_money;
        [otherItems addObject:changeItem];
        
        NSString*Consumption_prison=NSLocalizedString(@"Consumption_prison", @"狱内消费情况");
        PSFamilyServiceItem *honorItem = [PSFamilyServiceItem new];
        honorItem.itemIconName = @"serviceHallConsumptionIcon";
        honorItem.itemName = Consumption_prison;
        [otherItems addObject:honorItem];
    
        
        _otherServiceItems = otherItems;
    }
    return self;
}

- (void)requestCommentsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
{
    NSString*url=[NSString stringWithFormat:@"%@/prisoners/getPrisoners",ServerUrl];
    
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    
    NSString*jailId=prisonerDetail.jailId;
    PSUserSession*session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString*familiesId= session.families.id;
    NSDictionary*parmeters=@{
                             @"familyId":familiesId,
                             @"jailId":jailId
                             };
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parmeters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray*jailsArray=[MeetJails mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"prisoners"]];
        for (int i=0; i<jailsArray.count; i++) {
            MeetJails*model=jailsArray[i];
            [_array addObject:model];
        }
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (NSArray *)newfamilyServiceItems {
    
    
    NSMutableArray *items = [NSMutableArray array];
    NSString*prisonName=@"服刑监狱";
    PSFamilyServiceItem *prison = [PSFamilyServiceItem new];
    prison.itemIconName = @"服刑监狱icon";
    prison.itemName = prisonName;
    prison.content = self.prisonerDetail.jailName;
    [items addObject:prison];
    
    NSLog(@"%@",self.prisonerDetail);
    

    NSString*sentence=NSLocalizedString(@"sentence", @"原判刑期");
    PSFamilyServiceItem *periodItem = [PSFamilyServiceItem new];
    periodItem.itemIconName = @"serviceHallPeriodIcon";
    periodItem.itemName = sentence;
    periodItem.content = self.prisonerDetail.originalSentence;
    [items addObject:periodItem];
    
    NSString*sentence_start=NSLocalizedString(@"sentence_start", @"原判刑期起日");
    PSFamilyServiceItem *startItem = [PSFamilyServiceItem new];
    startItem.itemIconName = @"serviceHallStartIcon";
    startItem.itemName =sentence_start;
    startItem.content = [self.prisonerDetail.startedAt timestampToDateString];
    [items addObject:startItem];
    
    NSString*sentence_end=NSLocalizedString(@"sentence_end", @"原判刑期止日");
    PSFamilyServiceItem *endItem = [PSFamilyServiceItem new];
    endItem.itemIconName = @"serviceHallEndIcon";
    endItem.itemName = sentence_end;
    endItem.content = [self.prisonerDetail.endedAt timestampToDateString];
    [items addObject:endItem];
    
    //5
    NSString*Reduced_number=NSLocalizedString(@"Reduced_number", @"累计减刑次数");
    PSFamilyServiceItem *reduceItem = [PSFamilyServiceItem new];
    reduceItem.itemIconName = @"serviceHallReduceIcon";
    reduceItem.itemName = Reduced_number;
    NSString*one=NSLocalizedString(@"one", @"次");
    reduceItem.content = [NSString stringWithFormat:@"%ld%@",(long)self.prisonerDetail.times,one];
    [items addObject:reduceItem];
    
    //6
    PSFamilyServiceItem *lastReduceItem = [PSFamilyServiceItem new];
    NSString*Current_term=NSLocalizedString(@"Current_term", @"现刑期止日");
    lastReduceItem.itemIconName = @"serviceHallLastReduceIcon";
    lastReduceItem.itemName = Current_term;
    NSString * ALLtermFinishString= self.prisonerDetail.termFinish;
    NSString *termFinishString;
    if (ALLtermFinishString.length!=0) {
        termFinishString = [self.prisonerDetail.termFinish substringToIndex:10];
    } else {
        termFinishString=[self.prisonerDetail.endedAt timestampToDateString];;
    }
    
    // lastReduceItem.content =[[self.prisonerDetail.termFinish stringToDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] dateStringWithFormat:@"yyyy-MM-dd"];x
    lastReduceItem.content=termFinishString;
    [items addObject:lastReduceItem];
    
//    _familyServiceItems = items;
    return items;
}






@end
