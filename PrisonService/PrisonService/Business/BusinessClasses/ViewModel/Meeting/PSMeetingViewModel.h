//
//  PSMeetingViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSJailConfiguration.h"

@interface PSMeetingViewModel : PSViewModel

@property (nonatomic, strong) PSJailConfiguration *jailConfiguration;
@property (nonatomic, strong) NSString *jailName;
@property (nonatomic, strong) NSString *meetingID;
@property (nonatomic, strong) NSString *presenterPassword;
@property (nonatomic, strong) NSString *meetingPassword;
@property (nonatomic ,strong) NSString *familymeetingID;
@property (nonatomic ,strong) NSString *callDuration;
@property (nonatomic, strong) NSArray *FamilyMembers;

//***更新家属视频会见经纬度参数***//
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
//***end***//

- (void)requestFamilyMembersCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

- (void)requestUpdateMeetingCoordinateCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

- (void)requestUpdateFreeMeetingCoordinateCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
@end
