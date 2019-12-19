//
//  PSPrisonerFamliesViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/9/14.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonerFamliesViewModel.h"
#import "PSPrisonerFamiliesResponse.h"
#import "PSPrisonerFamiliesRequest.h"
#import "PSPrisonerFamily.h"
#import "PSSessionManager.h"
#import "PSHomeViewModel.h"

@interface PSPrisonerFamliesViewModel ()


@property (nonatomic, strong) PSPrisonerFamiliesRequest *prisonerFamiliesRequest;
@property (nonatomic, strong) NSMutableArray *logs;
@end

@implementation PSPrisonerFamliesViewModel
@synthesize dataStatus = _dataStatus;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSelectFamily = NO;
    }
    return self;
}

- (NSArray *)prisonerFamlies{
    return _logs;
}

- (void)requestOfPrisonerFamliesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    self.prisonerFamiliesRequest=[PSPrisonerFamiliesRequest new];
    self.prisonerFamiliesRequest.prisonerId=self.prisonerDetail.prisonerId;
    [self.prisonerFamiliesRequest send:^(PSRequest *request, PSResponse *response) {

        if (response.code==200) {
            self.logs=[NSMutableArray array];
            PSPrisonerFamiliesResponse*familiesResponse=(PSPrisonerFamiliesResponse*)response;
            if (familiesResponse.prisonerFamilies.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
  
            [self.logs addObjectsFromArray:familiesResponse.prisonerFamilies];
            for (int i=0; i<self.logs.count; i++) {
                PSPrisonerFamily*familesModel=self.logs[i];
                if ([familesModel.familyName isEqualToString:[PSSessionManager sharedInstance].session.families.name]) {
                    [self.logs exchangeObjectAtIndex:0 withObjectAtIndex:i];
                }
            }
           
            
        }
        else{
            self.dataStatus = PSDataError;
        }
        if (completedCallback) {
            completedCallback(response);
        }
        
    } errorCallback:^(PSRequest *request, NSError *error) {
        self.dataStatus = PSDataError;
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}





@end
