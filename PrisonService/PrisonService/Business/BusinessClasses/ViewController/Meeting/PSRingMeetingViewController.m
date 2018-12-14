//
//  PSRingMeetingViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRingMeetingViewController.h"
#import "PSGameMusicPlayer.h"

@interface PSRingMeetingViewController ()

@end

@implementation PSRingMeetingViewController
- (void)startRinging {
    [[PSGameMusicPlayer defaultPlayer] playBackgroundMusicWithFilename:@"ring" fileExtension:@"mp3" numberOfLoops:-1];
}

- (void)stopRinging {
    [[PSGameMusicPlayer defaultPlayer] stopBackgroundMusic];
}

- (void)renderContents {
    PSMeetingViewModel *meetingViewModel = (PSMeetingViewModel *)self.viewModel;
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = AppBaseTextColor1;
    contentLabel.font = FontOfSize(20);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    NSString*speak_you=NSLocalizedString(@"speak_you", @"请求与您通话");
    contentLabel.text = [NSString stringWithFormat:@"%@\n%@",meetingViewModel.jailName,speak_you];
    [contentLabel sizeToFit];
    [self.view addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(contentLabel.frame.size);
    }];
    CGFloat btWidth = 200;//160
    CGFloat btHeight = 120;
    UIButton *refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    @weakify(self)
    [refuseButton bk_whenTapped:^{
        @strongify(self)
        [self stopRinging];
        if (self.userOperation) {
            self.userOperation(PSMeetingRefuse);
        }
    }];
    [refuseButton setTitleEdgeInsets:UIEdgeInsetsMake(65, 0, 0, 58)];
    [refuseButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 35, 0)];
    [refuseButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    refuseButton.titleLabel.font = FontOfSize(20);
    [refuseButton setImage:[UIImage imageNamed:@"meetingRefuseIcon"] forState:UIControlStateNormal];
    NSString*refuse=NSLocalizedString(@"refuse", @"拒绝");
    [refuseButton setTitle:refuse forState:UIControlStateNormal];
    [self.view addSubview:refuseButton];
    [refuseButton addTarget:self action:@selector(refuseAction:) forControlEvents:UIControlEventTouchUpInside];
    [refuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.right.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(btWidth);
        make.height.mas_equalTo(btHeight);
    }];
    
    UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [acceptButton addTarget:self action:@selector(acceptAction:) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton bk_whenTapped:^{
        @strongify(self)
        [self stopRinging];
        if (self.userOperation) {
            self.userOperation(PSMeetingAccept);
        }
    }];
    [acceptButton setTitleEdgeInsets:UIEdgeInsetsMake(65, 0, 0, 58)];
    [acceptButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 35, 0)];
    [acceptButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    acceptButton.titleLabel.font = FontOfSize(20);
    [acceptButton setImage:[UIImage imageNamed:@"meetingAcceptIcon"] forState:UIControlStateNormal];
    NSString*answer=NSLocalizedString(@"answer", @"接听");
    [acceptButton setTitle:answer forState:UIControlStateNormal];
    [self.view addSubview:acceptButton];
    [acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(btWidth);
        make.height.mas_equalTo(btHeight);
    }];
}

#pragma mark - TouchEvent
//埋点不做任何操作
- (void)refuseAction:(UIButton *)sender {
    
}
- (void)acceptAction:(UIButton *)sender {
    
}
- (BOOL)hiddenNavigationBar {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
    [self startRinging];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
