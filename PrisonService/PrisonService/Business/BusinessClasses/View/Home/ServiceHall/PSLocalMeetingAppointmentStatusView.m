//
//  PSLocalMeetingAppointmentStatusView.m
//  PrisonService
//
//  Created by kky on 2018/11/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocalMeetingAppointmentStatusView.h"


@implementation PSLocalMeetingAppointmentStatusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.status = PSLocalMeetingWithoutAppointment;
    }
    return self;
}

- (void)setStatus:(PSLocalMeetingStatus)status {
    _status = status;
    [self renderContents];
}

- (void)renderContents {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentSize = CGSizeMake(SCREEN_WIDTH,700);
    
    NSString*disappointment=NSLocalizedString(@"disappointment", @"您还未预约");
    NSString*Appointment_pending=NSLocalizedString(@"Appointment_pending", @"预约审核中");
    NSString*Appointment_countdowm=NSLocalizedString(@"Appointment_countdowm", @"预约倒计-%ld天");

    switch (self.status) {
            case PSLocalMeetingWithoutAppointment:
        {
            UIImage *bgImage = [UIImage imageNamed:@"noappointment"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-236)/2, 70, 236, 161);
            [self addSubview:bgImageView];
         
            
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200, 24)];
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(17);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            [self addSubview:countdownLabel];
            countdownLabel.text = disappointment;
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-265)/2,countdownLabel.bottom+10,265,100)];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = FontOfSize(10);
            messageLabel.textColor = UIColorFromRGBA(153, 153,153,1);
            messageLabel.numberOfLines = 0;
            messageLabel.text = @"1.服刑人员在服刑期间，除法定节假日外，按照规定均可会 见亲属、监护人，家属可通过“预约”功能，选择预约日期后 进行实地会见申";
            [self addSubview:messageLabel];
           
            for (int i = 0; i<3; i++) {
                UIImageView *imageIcon = [UIImageView new];
                imageIcon.frame = CGRectMake(self.centerX+i*15-25,messageLabel.bottom+5,10, 10);
                if (i==0) {
                    imageIcon.image = [UIImage imageNamed:@"当前页圈"];
                } else {
                    imageIcon.image = [UIImage imageNamed:@"未选中圈"];
                }
                [self addSubview:imageIcon];
            }
            
            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,self.bottom-100,90, 34);
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
            NSString*reservation=NSLocalizedString(@"reservation", @"立即预约");
            [appointButton setTitle:reservation forState:UIControlStateNormal];
            [self addSubview:appointButton];
            @weakify(self);
            [appointButton bk_whenTapped:^{
                @strongify(self);
                if (self.actionBlock) {
                    self.actionBlock(PSLocalMeetingWithoutAppointment);
                }
            }];
        }
            break;
            case PSLocalMeetingPending:
        {
            UIImage *bgImage = [UIImage imageNamed:@"已预约－已完成"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-180)/2,30,175,128);
            [self addSubview:bgImageView];
            
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200, 24)];
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(12);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            [self addSubview:countdownLabel];
            countdownLabel.text = @"您已预约2018-11-20的实地会见";
            
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,countdownLabel.bottom+10, 20, 20)];
            arrow.image = [UIImage imageNamed:@"箭头"];
            [self addSubview:arrow];
            
            UIImageView *bgImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"审核中－当前步骤"]];
            bgImageView1.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView1.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow.bottom+10,180,128);
            [self addSubview:bgImageView1];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView1.bottom+20, 200, 24)];
            message.textAlignment = NSTextAlignmentCenter;
            message.font = FontOfSize(12);
            message.textColor = UIColorFromRGBA(38,76,144, 1);
            message.text = @"预约审核中，请耐心等待审核结果";
            [self addSubview:message];

            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,self.bottom-80,90, 34);
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
            NSString*cancel_meeting=NSLocalizedString(@"cancel_meeting", @"取消预约");
            [appointButton setTitle:cancel_meeting forState:UIControlStateNormal];
            [self addSubview:appointButton];
            @weakify(self);
            [appointButton bk_whenTapped:^{
                @strongify(self);
                if (self.actionBlock) {
                    self.actionBlock(PSLocalMeetingPending);
                }
            }];
        }
            break;
            case PSLocalMeetingCountdown:
            case PSLocalMeetingOntime:
        {
            UIImage *bgImage = [UIImage imageNamed:@"已预约－已完成"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-180)/2,30,175,128);
            [self addSubview:bgImageView];
            
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200, 24)];
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(12);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            [self addSubview:countdownLabel];
            countdownLabel.text = @"您已预约2018-11-20的实地会见";
            
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,countdownLabel.bottom+10, 20, 20)];
            arrow.image = [UIImage imageNamed:@"箭头"];
            [self addSubview:arrow];
            
            UIImageView *bgImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"审核中－当前步骤"]];
            bgImageView1.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView1.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow.bottom+10,180,128);
            [self addSubview:bgImageView1];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView1.bottom+20, 200, 24)];
            message.textAlignment = NSTextAlignmentCenter;
            message.font = FontOfSize(12);
            message.textColor = UIColorFromRGBA(38,76,144, 1);
            message.text = @"预约审核中，请耐心等待审核结果";
            [self addSubview:message];
            
            
            UIImageView *arrow1 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,message.bottom+10, 20, 20)];
            arrow1.image = [UIImage imageNamed:@"箭头"];
            [self addSubview:arrow1];
            
            UIImageView *bgImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"审核中－当前步骤"]];
            bgImageView2.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView2.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow1.bottom+10,180,128);
            [self addSubview:bgImageView2];
            
            UILabel *message1 = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView2.bottom+20, 200, 24)];
            message1.textAlignment = NSTextAlignmentCenter;
            message1.font = FontOfSize(12);
            message1.textColor = UIColorFromRGBA(38,76,144, 1);
            message1.text = @"预约审核中，请耐心等待审核结果";
            [self addSubview:message1];
            
            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,message1.bottom+30,90, 34);
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
            NSString*cancel_meeting=NSLocalizedString(@"cancel_meeting", @"取消预约");
            [appointButton setTitle:cancel_meeting forState:UIControlStateNormal];
            [self addSubview:appointButton];
            @weakify(self);
            [appointButton bk_whenTapped:^{
                @strongify(self);
                if (self.actionBlock) {
                    self.actionBlock(PSLocalMeetingPending);
                }
            }];
        }
            break;
        default:
            break;
    }
}



@end
