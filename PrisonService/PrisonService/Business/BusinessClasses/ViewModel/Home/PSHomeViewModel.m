//
//  PSHomeViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSHomeViewModel.h"
#import "PSSessionManager.h"
#import "PSMeetingsPageRequest.h"
#import "NSDate+Components.h"
#import "PSSessionManager.h"
#import "PSCountVisitRequest.h"
#import "PSMessageCountModel.h"
#import "PSCountVisitResponse.h"

#import "PSLocalMeetingDetailRequest.h"
@interface PSHomeViewModel ()

@property (nonatomic, strong) PSMeetingsPageRequest *meetingsRequest;
@property (nonatomic, strong) PSLocalMeetingDetailRequest *meetingDetailRequest;
@property (nonatomic, strong) PSCountVisitRequest *countVisitRequest;
@end

@implementation PSHomeViewModel
- (id)init {
    self = [super init];
    if (self) {
        NSMutableArray *items = [NSMutableArray array];
  
        
        PSHallFunction *introduceFunction = [[PSHallFunction alloc] init];
        NSString*prison_introduction=NSLocalizedString(@"prison_introduction", @"监狱简介");
        introduceFunction.itemName = prison_introduction;
        introduceFunction.itemIconName = @"homeIntroduceIcon";
        [items addObject:introduceFunction];
        
        PSHallFunction *publicFunction = [[PSHallFunction alloc] init];
        NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
        publicFunction.itemName =prison_opening;
        publicFunction.itemIconName = @"homePublicIcon";
        [items addObject:publicFunction];
        
        PSHallFunction *workFunction = [[PSHallFunction alloc] init];
        NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
        workFunction.itemName = work_dynamic;
        workFunction.itemIconName = @"homeWorkIcon";
        [items addObject:workFunction];
        
        
        
        PSHallFunction *lawFunction = [[PSHallFunction alloc] init];
        NSString*laws_regulations=NSLocalizedString(@"laws_regulations", @"法律法规");
        lawFunction.itemName = laws_regulations;
        lawFunction.itemIconName = @"homeLawIcon";
        [items addObject:lawFunction];
        
        PSHallFunction *serviceFunction = [[PSHallFunction alloc] init];
        NSString*family_server=NSLocalizedString(@"family_server", @"家属服务");
        serviceFunction.itemName = family_server;
        serviceFunction.itemIconName = @"homeServiceIcon";
        [items addObject:serviceFunction];
        
        PSHallFunction *meetingFunction = [[PSHallFunction alloc] init];
        NSString*local_meetting=NSLocalizedString(@"local_meetting", @"实地会见");
        meetingFunction.itemName = local_meetting;
        meetingFunction.itemIconName = @"homeMeetingIcon";
        [items addObject:meetingFunction];
        
        PSHallFunction *commerceFunction = [[PSHallFunction alloc] init];
        NSString*e_mall=NSLocalizedString(@"e_mall", @"电子商务");
        commerceFunction.itemName = e_mall;
        commerceFunction.itemIconName = @"homeCommerceIcon";
        [items addObject:commerceFunction];
        
        
        PSHallFunction *feedbackFunction = [[PSHallFunction alloc] init];
        NSString*complain_advice=NSLocalizedString(@"complain_advice", @"投诉建议");
        feedbackFunction.itemName = complain_advice;
        feedbackFunction.itemIconName = @"homeFeedbackIcon";
        [items addObject:feedbackFunction];
        
        PSHallFunction *moreFunction = [[PSHallFunction alloc] init];
        NSString*more_server=NSLocalizedString(@"more_server", @"更多服务");
        moreFunction.itemName = more_server;
        moreFunction.itemIconName = @"homeMoreIcon";
        [items addObject:moreFunction];
        
        _functions = items;
    }
    return self;
}

- (NSArray *)passedPrisonerDetails {
    return [PSSessionManager sharedInstance].passedPrisonerDetails;
}

- (NSInteger)selectedPrisonerIndex {
    return [PSSessionManager sharedInstance].selectedPrisonerIndex;

}

- (void)setSelectedPrisonerIndex:(NSInteger)selectedPrisonerIndex {
    [PSSessionManager sharedInstance].selectedPrisonerIndex = selectedPrisonerIndex;
}

- (void)setMeetings:(NSArray *)meetings {
    NSMutableArray *passedMeetings = [NSMutableArray array];
    for (PSMeeting *meeting in meetings) {
        if ([meeting.status isEqualToString:@"PASSED"]) {
            [passedMeetings addObject:meeting];
        }
    }
    [passedMeetings sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [((PSMeeting *)obj1).meetingDate compare:((PSMeeting *)obj2).meetingDate];
    }];
    _meetings = passedMeetings;
}

- (PSMeeting *)latestMeeting {
    PSMeeting *meeting = nil;
    for (PSMeeting *mt in self.meetings) {
        if ([mt.status isEqualToString:@"PASSED"]) {
            if (meeting) {
                if ([mt.meetingDate compare:meeting.meetingDate] == NSOrderedAscending) {
                    meeting = mt;
                }
            }else{
                meeting = mt;
            }
        }
    }
    return meeting;
}

- (void)requestMeetingsCompleted:(RequestDataTaskCompleted)completedCallback {
    PSUserSession *session = [PSSessionManager sharedInstance].session;
    self.meetingsRequest = [PSMeetingsPageRequest new];
    self.meetingsRequest.page = 1;
    self.meetingsRequest.rows = 100;
    self.meetingsRequest.name = session.families.name;
    self.meetingsRequest.uuid = session.families.uuid;
    self.meetingsRequest.ymd = [[NSDate date] yearMonthDay];
    @weakify(self)
    [self.meetingsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        PSMeetingsPageResponse *meetingsResponse = (PSMeetingsPageResponse *)response;
        if (meetingsResponse.code == 200) {
            self.meetings = meetingsResponse.meetings;
        }
        if (completedCallback) {
            completedCallback(nil);
        }

    } errorCallback:^(PSRequest *request, NSError *error) {
        if (completedCallback) {
            completedCallback(nil);
        }
    }];
}

- (void)requestHomeDataCompleted:(RequestDataTaskCompleted)completedCallback {
    self.selectedPrisonerIndex = 0;
    @weakify(self)
    [[PSSessionManager sharedInstance] synchronizePrisonerDetailsCompletion:^() {
        @strongify(self)
        [self requestMeetingsCompleted:^(id data) {
            if (completedCallback) {
                completedCallback(nil);
            }
        }];
    }];
    
}



- (void)requestLocalMeetingDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.meetingDetailRequest = [PSLocalMeetingDetailRequest new];
    self.meetingDetailRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
     NSInteger index = self.selectedPrisonerIndex;
     PSPrisonerDetail *prisonersDetail = nil;
    if (index >= 0 && index < self.passedPrisonerDetails.count) {
        prisonersDetail=self.passedPrisonerDetails[index];
    }
    self.meetingDetailRequest.prisonerId =prisonersDetail.prisonerId; 
    [self.meetingDetailRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }

    }];
}
//消息统计
- (void)getRequestCountVisitCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    self.countVisitRequest = [PSCountVisitRequest new];
    self.countVisitRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
    [self.countVisitRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            PSCountVisitResponse *responseData = (PSCountVisitResponse *)response;
            PSMessageCountModel *model = [responseData.mesageCounts objectAtIndex:0];
            self.messageCountModel = model;
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
    
}


@end
