//
//  PSLocalMeetingViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/5/15.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocalMeetingViewModel.h"
#import "PSTipsConstants.h"
#import "PSLocalMeetingDetailRequest.h"
#import "PSSessionManager.h"
#import "PSAddLocalMeetingRequest.h"
#import "NSDate+Components.h"
#import "PSCancelLocalMeetingRequest.h"
#import "PSBusinessConstants.h"
@interface PSLocalMeetingViewModel()

@property (nonatomic, strong) PSLocalMeetingDetailRequest *meetingDetailRequest;
@property (nonatomic, strong) PSAddLocalMeetingRequest *addMeetingRequest;
@property (nonatomic, strong) PSCancelLocalMeetingRequest *cancelMeetingRequest;

@end

@implementation PSLocalMeetingViewModel
- (id)init {
    self = [super init];
    if (self) {
        _introduceTexts = @[LocalMeetingIntroduceOne,LocalMeetingIntroduceTwo,LocalMeetingIntroduceThree];
    }
    return self;
}

- (void)setLocalMeeting:(PSLocalMeeting *)localMeeting {
    _localMeeting = localMeeting;
    UIFont *font = FontOfSize(10);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    UIImage *addressIcon = [UIImage imageNamed:@"localMeetingAddressIcon"];
    NSMutableAttributedString *addressString = [NSMutableAttributedString yy_attachmentStringWithContent:addressIcon contentMode:UIViewContentModeCenter attachmentSize:addressIcon.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [addressString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",localMeeting.visitAddress] attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}]];
    _routeString = addressString;
}

- (void)requestLocalMeetingDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.meetingDetailRequest = [PSLocalMeetingDetailRequest new];
    self.meetingDetailRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
    self.meetingDetailRequest.prisonerId = self.prisonerDetail.prisonerId;
    @weakify(self)
    [self.meetingDetailRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSLocalMeetingDetailResponse *detailResponse = (PSLocalMeetingDetailResponse *)response;
            self.localMeeting = detailResponse.visits;
        }
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


- (void)requestPreLocalMeetingDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
}


- (void)addLocalMeetingDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.addMeetingRequest = [PSAddLocalMeetingRequest new];
    self.addMeetingRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
    self.addMeetingRequest.prisonerId = self.prisonerDetail.prisonerId;
    self.addMeetingRequest.jailId = self.prisonerDetail.jailId;
    self.addMeetingRequest.applicationDate = [self.appointDate dateStringWithFormat:@"yyyy-MM-dd"];
    [self.addMeetingRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)cancelLocalMeetingDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.cancelMeetingRequest = [PSCancelLocalMeetingRequest new];
    self.cancelMeetingRequest.meetingID = self.localMeeting.id;
    self.cancelMeetingRequest.cause = self.cancelReason;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDotChange object:nil];
    [self.cancelMeetingRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
