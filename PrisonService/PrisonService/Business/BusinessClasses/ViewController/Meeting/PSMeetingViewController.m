//
//  PSMeetingViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMeetingViewController.h"
#import "PSBusinessConstants.h"
#import "ZJVideoManager.h"
#import "PSBusinessConstants.h"
#import "PSMeetingManager.h"
#import "PSCountdownManager.h"
#import "PSAlertView.h"
#import "PSMeetingMessage.h"

typedef NS_ENUM(NSInteger, PSMeettingType) {
    PSMeettingTypeFree=0,                   // don't show any accessory view
    PSMeettingTypePay=1,    // the same with system DisclosureIndicator
    //  swithch
};

@interface PSMeetingViewController ()<PSCountdownObserver>

@property (nonatomic, strong) ZJVideoManager *videoManager;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, assign) NSInteger upSeconds;
@property (nonatomic , strong) UILabel*timeDownLable;
@property (nonatomic,assign) PSMeettingType Type;
@end

@implementation PSMeetingViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [self.videoManager outOfCurrentMeeting];
    [[PSCountdownManager sharedInstance] removeObserver:self];
}

- (BOOL)hiddenNavigationBar {
    return YES;
}


- (BOOL)fd_interactivePopDisabled {
    return YES;
}

- (void)showInternetError {
    // [PSTipsView showTips:@"无法连接到服务器，请检查网络"];
    NSString*Tips=NSLocalizedString(@"Tips", @"提示");
    NSString*InternetError=NSLocalizedString(@"InternetError", @"无法连接到服务器，请检查网络");
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    [PSAlertView showWithTitle:Tips message:InternetError messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        
    } buttonTitles:determine, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInternetError) name:NotificationNoNetwork object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [self changeOrientation:UIInterfaceOrientationLandscapeRight];
    PSMeetingViewModel *meetingViewModel = (PSMeetingViewModel *)self.viewModel;
    if (meetingViewModel.meetingID.length > 0 && meetingViewModel.meetingPassword.length > 0) {
#if !TARGET_IPHONE_SIMULATOR
        self.videoManager = [ZJVideoManager sharedManager];
        struct ZJVideoSize minSize = {640,480};
        struct ZJVideoSize expectedSize = {640,480};
        [self.videoManager connectTarget:meetingViewModel.meetingID name:meetingViewModel.jailName password:meetingViewModel.meetingPassword apiServer:ZIJING_DOMAIN bandwidthIn:576 bandwidthOut:576 showFunctionItem:NO isAutoPrepresentVC:NO videoSize:minSize expectedSize:expectedSize];
        [self.view addSubview:self.videoManager.conferenceView];
        [self.videoManager.conferenceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        _timeDownLable=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 40)];
        _timeDownLable.textAlignment=NSTextAlignmentLeft;
        if ([meetingViewModel.callDuration isEqualToString:@"-1"]) {
            //self.upSeconds=1;
            self.Type=PSMeettingTypeFree;//免费会见
            self.seconds=1;
        }
        else{
            self.seconds=[meetingViewModel.callDuration integerValue];
            self.Type=PSMeettingTypePay;
        }
        _timeDownLable.text=[NSString stringWithFormat:@"剩余通话时间:%@",[self getMMSSFromSS:self.seconds]];
        _timeDownLable.textColor=[UIColor whiteColor];
        [_timeDownLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [self.view addSubview:_timeDownLable];

        
        UIButton*hangButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_HEIGHT-100, 20, 100,100)];
        [self.view addSubview:hangButton];
        [hangButton setBackgroundColor:[UIColor clearColor]];
#endif
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notciceCountDown:) name:KNOtificationMeetingCountdown object:nil];
}

#pragma mark -- 传入 秒 得到 xx分钟xx秒
-(NSString *)getMMSSFromSS:(NSInteger)totalTime{
    NSString*H=NSLocalizedString(@"H", @"时");
    NSString*M=NSLocalizedString(@"M", @"分");
    NSString*S=NSLocalizedString(@"S", @"秒");
    
    NSInteger seconds = totalTime ;
    NSString *format_time=nil;
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSLog(@"%@",str_hour);
    if (totalTime>3600) {
        
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
        NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
        format_time = [NSString stringWithFormat:@"%@%@%@%@%@%@",str_hour,H,str_minute,M,str_second,S];
    } else {
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",seconds/60];
        NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
        format_time = [NSString stringWithFormat:@"%@%@%@%@",str_minute,M,str_second,S];
    }
    return format_time;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notciceCountDown:(NSNotification *)notice{
    
    PSMeetingMessage *message = [notice object];;
    if (message.code==-3) {
        self.seconds = [message.callDuration integerValue];
        self.Type = PSMeettingTypePay;
    }

}

- (void)countdown {
   NSString*Call=NSLocalizedString(@"Call", @"已通话");
   NSString*call_expired=
    NSLocalizedString(@"call_expired", @"本次通话已超时");
   NSString*Remaining_time=
    NSLocalizedString(@"Remaining_time", @"剩余通话时间");

    switch (self.Type) {
        case PSMeettingTypeFree:
            if (_seconds > 0) {
                _timeDownLable.text=[NSString stringWithFormat:@"%@:%@", Call,[self getMMSSFromSS:self.seconds]];
                _seconds ++;
            }
            break;
        case PSMeettingTypePay:
            _timeDownLable.text = _seconds == 0?call_expired:@"";
            if (_seconds > 0) {
                _timeDownLable.text=[NSString stringWithFormat:@"%@:%@",Remaining_time,[self getMMSSFromSS:self.seconds]];
                _seconds --;
                
            }
//            else{
//               _timeDownLable.text =@"本次通话已超时";
//            }
//            break;
            
        default:
            break;
    }
    
    
    
    
}



@end
