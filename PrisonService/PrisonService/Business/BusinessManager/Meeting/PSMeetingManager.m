//
//  PSMeetingManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMeetingManager.h"
#import "PSIMMessageManager.h"
#import "PSJailConfigurationsRequest.h"
#import "PSViewModelService.h"
#import "PSRingMeetingViewController.h"
#import "PSContentManager.h"
#import "PSFaceAuthViewController.h"
#import "PSMeetingViewController.h"
#import "PSTipsView.h"
#import "PSAlertView.h"
#import "PSSessionManager.h"
#import "ZQLocalNotification.h"
#import "WXZTipView.h"
#import "PSFamilyFaceViewController.h"
#import "PSFamliesFaceViewController.h"
#import <EBBannerView/EBBannerView.h>
#import "UIViewController+Tool.h"

#import "PSLocateManager.h"
@interface PSMeetingManager ()<PSIMMessageObserver>

@property (nonatomic, strong) PSJailConfigurationsRequest *jailConfigurationsRequest;
@property (nonatomic, strong) NSString *jailId;
@property (nonatomic, strong) NSString *jailName;
@property (nonatomic, strong) NSString *meetingID;
@property (nonatomic ,strong) NSString *familesMeetingID ;
@property (nonatomic, strong) NSString *presenterPassword;
@property (nonatomic, strong) NSString *meetingPassword;
@property (nonatomic, strong) PSJailConfiguration *jailConfiguration;
//@property (nonatomic, strong) PSNavigationController *meetingNavigationController;

@end

@implementation PSMeetingManager
+ (PSMeetingManager *)sharedInstance {
    static PSMeetingManager *manager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        [[PSIMMessageManager sharedInstance] addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[PSIMMessageManager sharedInstance] removeObserver:self];
}

- (void)requestJailConfigurationsCompletion:(RequestDataCompleted)completionCallback failed:(RequestDataFailed)failedCallback {
    self.jailConfigurationsRequest = [PSJailConfigurationsRequest new];
    self.jailConfigurationsRequest.jailId = self.jailId;
    [self.jailConfigurationsRequest send:^(PSRequest *request, PSResponse *response) {
        if (completionCallback) {
            completionCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)fetchJailConfigurations {
    @weakify(self)
    [self requestJailConfigurationsCompletion:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSJailConfigurationsResponse *configurationResponse = (PSJailConfigurationsResponse *)response;
            self.jailConfiguration = configurationResponse.configuration;
            self.jailName = configurationResponse.jailName;
        }else{
            self.jailConfiguration = [[PSJailConfiguration alloc] init];
        }
        [self ringAndShowMeeting];
    } failed:^(NSError *error) {
        @strongify(self)
        self.jailConfiguration = [[PSJailConfiguration alloc] init];
        [self ringAndShowMeeting];
    }];
}

//响铃并显示接听界面
- (void)ringAndShowMeeting {
    //埋点...
    [SDTrackTool logEvent:RECEIVE_REMOTE_CALL];
    
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.jailConfiguration = self.jailConfiguration;
    viewModel.jailName = self.jailName;
    PSRingMeetingViewController *ringViewController = [[PSRingMeetingViewController alloc] initWithViewModel:viewModel];
    @weakify(self)
    [ringViewController setUserOperation:^(PSMeetingOperation operation) {
        @strongify(self)
        if (operation == PSMeetingRefuse) {
            [self refuseOperation];
        }else{
            [self acceptOperation];
        }
    }];
    self.meetingNavigationController = [[PSNavigationController alloc] initWithRootViewController:ringViewController];
    [[PSContentManager sharedInstance].rootViewController presentViewController:self.meetingNavigationController animated:NO completion:nil];
}

- (void)refuseOperation {
    
    PSMeetingMessage *exitMessage = [PSMeetingMessage new];
    exitMessage.code = PSMeetingEnd;
    [[PSIMMessageManager sharedInstance] sendMeetingMessage:exitMessage];
    [self clearMeeting];
    [self.meetingNavigationController dismissViewControllerAnimated:NO completion:nil];
    self.meetingNavigationController = nil;
}

- (void)acceptOperation {
    if ([self.jailConfiguration.face_recognition isEqualToString:@"0"]) {
        //开始视频通话
        [self startMeeting];
    }else{
        //需要人脸识别
        [self checkFaceAuth];
    }
}

//人脸识别验证
- (void)checkFaceAuth {
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.jailConfiguration = self.jailConfiguration;
    viewModel.jailName = self.jailName;
    viewModel.meetingID = self.meetingID;
    viewModel.meetingPassword = self.meetingPassword;
    viewModel.presenterPassword = self.presenterPassword;
    viewModel.familymeetingID=self.familesMeetingID;
    PSFaceAuthViewController *authViewController = [[PSFaceAuthViewController alloc] initWithViewModel:viewModel];
    @weakify(self)
    [authViewController setCompletion:^(BOOL successful) {
        @strongify(self)
        if (successful) {
            //开始视频通话
            [self startMeeting];
        }else{
            [self.meetingNavigationController dismissViewControllerAnimated:NO completion:nil];
            self.meetingNavigationController = nil;
            PSMeetingMessage *exitMessage = [PSMeetingMessage new];
            exitMessage.code = PSMeetingEnd;
            [[PSIMMessageManager sharedInstance] sendMeetingMessage:exitMessage];
        }
    }];
    [self.meetingNavigationController pushViewController:authViewController animated:YES];

}



//视频通话
- (void)startMeeting {
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.jailConfiguration = self.jailConfiguration;
    viewModel.jailName = self.jailName;
    viewModel.meetingID = self.meetingID;
    viewModel.meetingPassword = self.meetingPassword;
    viewModel.presenterPassword = self.presenterPassword;
    viewModel.familymeetingID=self.familesMeetingID;
    viewModel.callDuration=self.callDuration;
    
    
    
   PSMeetingViewController *meetingViewController = [[PSMeetingViewController alloc] initWithViewModel:viewModel];
//    [self.meetingNavigationController pushViewController:meetingViewController animated:YES];
//    [[PSContentManager sharedInstance] resetContent];
    [[PSContentManager sharedInstance].currentNavigationController pushViewController:meetingViewController animated:NO];

    //进入会议，发送进入会议消息
    PSMeetingMessage *enterMessage = [PSMeetingMessage new];
    enterMessage.code = PSMeetingEnter;
    [[PSIMMessageManager sharedInstance] sendMeetingMessage:enterMessage];
    [self.meetingNavigationController dismissViewControllerAnimated:NO completion:nil];
     self.meetingNavigationController = nil;

    
}

-(void)sendFreeLocation{
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.meetingID = self.meetingID;
    viewModel.lat=[PSLocateManager sharedInstance].lat;
    viewModel.lng=[PSLocateManager sharedInstance].lng;
    viewModel.province=[PSLocateManager sharedInstance].province;
    viewModel.city=[PSLocateManager sharedInstance].city;
    [viewModel requestUpdateFreeMeetingCoordinateCompleted:^(PSResponse *response) {
        
    } failed:^(NSError *error) {
        
    }];
    
}

-(void)sendChargeLocation{
    PSMeetingViewModel *viewModel = [PSMeetingViewModel new];
    viewModel.meetingID = self.meetingID;
    viewModel.lat=[PSLocateManager sharedInstance].lat;
    viewModel.lng=[PSLocateManager sharedInstance].lng;
    viewModel.province=[PSLocateManager sharedInstance].province;
    viewModel.city=[PSLocateManager sharedInstance].city;
    [viewModel requestUpdateMeetingCoordinateCompleted:^(PSResponse *response) {
        
    } failed:^(NSError *error) {
        
    }];
}


//会议结束后的清理工作
- (void)clearMeeting {
    self.jailId = nil;
    self.meetingID = nil;
    self.presenterPassword = nil;
    self.meetingPassword = nil;
    self.jailName = nil;
    self.jailConfiguration = nil;
    if ([[PSContentManager sharedInstance].currentNavigationController.topViewController isKindOfClass:[PSMeetingViewController class]]) {
        [[PSContentManager sharedInstance].currentNavigationController popViewControllerAnimated:YES];
    } else {
        [[UIViewController jsd_getCurrentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleMeetingStatusMessage:(PSMeetingMessage *)message {

        NSString *token = [[PSSessionManager sharedInstance].session.token copy];
        [ZQLocalNotification NotificationType:CountdownNotification Identifier:token activityId:1900000 alertBody:message.msg alertTitle:@"狱务通" alertString:@"确定" withTimeDay:0 hour:0 minute:0 second:1];
//        [EBBannerView showWithContent:message.msg];
        EBBannerView *banner = [EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
            make.style = 11;
            make.content = message.msg;
        }];
        [banner show];
 
}

#pragma mark - PSIMMessageObserver
- (void)receivedMeetingMessage:(PSMeetingMessage *)message {
    NSLog(@"_____****_____%@",message.msg);
    switch (message.code) {
            
        case PSChargeMeetingLocation:
        {
            [self sendChargeLocation];
            
        }
        case PSFreeMeetingLocation:
        {
            [self sendFreeLocation];
            
        }
            
        case PSMeetingStart:
        {
            //发起会议
            if (message.msg.length > 0) {
                NSArray *msgComponents = [message.msg componentsSeparatedByString:@"##"];
                if (msgComponents.count == 3) {
                    self.meetingID = msgComponents[0];
                    self.presenterPassword = msgComponents[1];
                    self.meetingPassword = msgComponents[2];
                }
                self.jailId = message.jail;
                self.familesMeetingID=message.meetingId;
                self.callDuration=message.callDuration;
                [self fetchJailConfigurations];
            }else{
                //初始发起会见
                [[PSIMMessageManager sharedInstance] sendMeetingMessage:message];
            }
        }
            break;
        case PSMeetingEnter:
        {
            //进入会议
        }
            break;
        case PSMeetingEnd:
        {
            //挂断会议
            PSMeetingMessage *exitMessage = [PSMeetingMessage new];
            exitMessage.code = PSMeetingEnd;
            [[PSIMMessageManager sharedInstance] sendMeetingMessage:exitMessage];
            NSString*meet_end=NSLocalizedString(@"meet_end", @"监狱终端已挂断");
            [WXZTipView showBottomWithText:meet_end];
            [self clearMeeting];
            //埋点....
            
            [SDTrackTool logEvent:VIDEO_MEETING_COMPLETE];

            
        }
            break;
        case PSMeetingStatus:
        {
            [self handleMeetingStatusMessage:message];
        }
            break;
            
        case PSMeetingCancelAuthorization:
        {
            PSPrisonerDetail *prisonerDetail = nil;
            NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
            NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
            if (index >= 0 && index < details.count) {
                prisonerDetail = details[index];
            }
            if ([prisonerDetail.prisonerId isEqualToString:message.prisonerId]) {
                [ PSAlertView showWithTitle:@"提示" message:@"您的家属认证申请已被撤回!" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex==0) {
                        [[PSSessionManager sharedInstance]doLogout];
                    }
                } buttonTitles:@"确定", nil];
                NSString *token = [[PSSessionManager sharedInstance].session.token copy];
                [ZQLocalNotification NotificationType:CountdownNotification Identifier:token activityId:1900000 alertBody:message.msg alertTitle:@"狱务通" alertString:@"确定" withTimeDay:0 hour:0 minute:0 second:1];
            } else {
                NSString *token = [[PSSessionManager sharedInstance].session.token copy];
                [ZQLocalNotification NotificationType:CountdownNotification Identifier:token activityId:1900000 alertBody:message.msg alertTitle:@"狱务通" alertString:@"确定" withTimeDay:0 hour:0 minute:0 second:1];
            }
          
        }
          break;
        default:
            break;
    }
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    if (completion) {
        completion(YES);
    }
}

@end
