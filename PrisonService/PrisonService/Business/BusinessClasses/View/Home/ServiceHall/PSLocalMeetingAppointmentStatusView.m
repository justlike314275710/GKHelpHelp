//
//  PSLocalMeetingAppointmentStatusView.m
//  PrisonService
//
//  Created by kky on 2018/11/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocalMeetingAppointmentStatusView.h"

@interface PSLocalMeetingAppointmentStatusView()<UIScrollViewDelegate>

@property(nonatomic,strong)NSTimer*countDownTimer;
@property(nonatomic,assign)NSInteger secondsCountDown;
/** 轮播定时器 */
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger page;

@end

@implementation PSLocalMeetingAppointmentStatusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.status = PSLocalMeetingWithoutAppointment;
        self.page = 0;
    }
    return self;
}

- (void)setStatus:(PSLocalMeetingStatus)status {
    _status = status;
    [self renderContents];
}

- (void)setMessageViewModel:(PSLocalMeetingViewModel *)messageViewModel {
    _messageViewModel = messageViewModel;
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
            self.contentSize = CGSizeMake(SCREEN_WIDTH,550);
            UIImage *bgImage = [UIImage R_imageNamed:@"noappointment"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-236)/2, 70, 236, 161);
            [self addSubview:bgImageView];
            
            NSLog(@"%@",_messageViewModel);
            
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200, 24)];
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(17);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            [self addSubview:countdownLabel];
            countdownLabel.text = disappointment;
            
            UIScrollView *labelScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,countdownLabel.bottom+10,SCREEN_WIDTH, 100)];
            labelScrollview.delegate = self;
            labelScrollview.contentSize = CGSizeMake(3*SCREEN_WIDTH, 100);
            labelScrollview.pagingEnabled = YES;
            labelScrollview.showsHorizontalScrollIndicator = NO;
            [self addSubview:labelScrollview];
            [self startTimer];
            labelScrollview.tag = 10086;
            for (int i = 0;i<3; i++) {
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-265)/2+i*SCREEN_WIDTH,0,265,100)];
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = FontOfSize(10);
                messageLabel.textColor = UIColorFromRGBA(153, 153,153,1);
                messageLabel.numberOfLines = 0;
                messageLabel.text = _messageViewModel.introduceTexts[i];
                [labelScrollview addSubview:messageLabel];
            }
            
            for (int i = 0; i<3; i++) {
                UIImageView *imageIcon = [UIImageView new];
                imageIcon.tag = 100+i;
                imageIcon.frame = CGRectMake(self.centerX+i*15-25,labelScrollview.bottom+5,10, 10);
                if (i==0) {
                    imageIcon.image = [UIImage R_imageNamed:@"当前页圈"];
                } else {
                    imageIcon.image = [UIImage R_imageNamed:@"未选中圈"];
                }
                [self addSubview:imageIcon];
                imageIcon.userInteractionEnabled = YES;
                [imageIcon bk_whenTapped:^{
//                    [self pageAction:imageIcon];
                }];
            }
            
            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,self.bottom-100,90, 34);
            if (IS_iPhone_5) {
                appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,self.bottom-50,90, 34);
            }
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage R_imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
            NSString*reservation=NSLocalizedString(@"reservation", @"立即预约");
            [appointButton setTitle:reservation forState:UIControlStateNormal];
            [self addSubview:appointButton];
            [appointButton addTarget:self action:@selector(rightInterView:) forControlEvents:UIControlEventTouchUpInside];
//            @weakify(self);
//            [appointButton bk_whenTapped:^{
//                @strongify(self);
//                if (self.actionBlock) {
//                    self.actionBlock(PSLocalMeetingWithoutAppointment);
//                }
//            }];
        }
            break;
            case PSLocalMeetingPending:
        {
            
            self.contentSize = CGSizeMake(SCREEN_WIDTH,550);
            [self scrollViewToBottom:NO];
            UIImage *bgImage = [UIImage R_imageNamed:@"已预约－已完成"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-180)/2,30,175,128);
            [self addSubview:bgImageView];
            
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200,35)];
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(12);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            [self addSubview:countdownLabel];
            NSString*Historical_record=NSLocalizedString(@"You have made an appointment to meet in the field at%@", @"您已预约%@的实地会见");
            countdownLabel.text = [NSString stringWithFormat:Historical_record,_messageViewModel.localMeeting.applicationDate];
            countdownLabel.numberOfLines = 0;
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,countdownLabel.bottom+10, 20, 20)];
            arrow.image = [UIImage R_imageNamed:@"箭头"];
            [self addSubview:arrow];
            
            UIImageView *bgImageView1 = [[UIImageView alloc] initWithImage:[UIImage R_imageNamed:@"审核中－当前步骤"]];
            bgImageView1.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView1.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow.bottom+10,180,128);
            [self addSubview:bgImageView1];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView1.bottom+20, 200,35)];
            message.textAlignment = NSTextAlignmentCenter;
            message.font = FontOfSize(12);
            message.textColor = UIColorFromRGBA(38,76,144, 1);
            message.numberOfLines = 0;
            NSString*audit=NSLocalizedString(@"Please wait patiently for the audit results during the booking audit", @"预约审核中，请耐心等待审核结果");
            message.text = audit;
            [self addSubview:message];
            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,self.bottom-80,90, 34);
            if (IS_iPhone_5) {
                appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,self.bottom-50,90, 34);
            }
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage R_imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
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
        case PSLocalMeetingPendingFail:
        {
            self.contentSize = CGSizeMake(SCREEN_WIDTH,800);
            [self scrollViewToBottom:NO];
            UIImage *bgImage = [UIImage R_imageNamed:@"已预约－已完成"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-180)/2,30,175,128);
            [self addSubview:bgImageView];
            
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200, 35)];
            countdownLabel.numberOfLines = 0;
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(12);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            [self addSubview:countdownLabel];
            NSString*Historical_record=NSLocalizedString(@"You have made an appointment to meet in the field at%@", @"您已预约%@的实地会见");
            countdownLabel.text = [NSString stringWithFormat:Historical_record,_messageViewModel.localMeeting.applicationDate];
            
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,countdownLabel.bottom+10, 20, 20)];
            arrow.image = [UIImage R_imageNamed:@"箭头"];
            [self addSubview:arrow];
            
            UIImageView *bgImageView1 = [[UIImageView alloc] initWithImage:[UIImage R_imageNamed:@"审核中－已完成"]];
            bgImageView1.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView1.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow.bottom+10,180,128);
            [self addSubview:bgImageView1];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView1.bottom+20, 200, 34)];
            message.textAlignment = NSTextAlignmentCenter;
            message.numberOfLines = 0;
            message.font = FontOfSize(12);
            //            message.textColor = UIColorFromRGBA(38,76,144, 1);
            message.textColor = UIColorFromRGBA(51, 51, 51, 1);
            NSString*audit=NSLocalizedString(@"Please wait patiently for the audit results during the booking audit", @"预约审核中，请耐心等待审核结果");
            message.text = audit;
            [self addSubview:message];
            
            
            UIImageView *arrow1 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,message.bottom+10, 20, 20)];
            arrow1.image = [UIImage R_imageNamed:@"箭头"];
            [self addSubview:arrow1];
            
            UIImageView *bgImageView2 = [[UIImageView alloc] initWithImage:[UIImage R_imageNamed:@"审核未通过－当前步骤"]];
            bgImageView2.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView2.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow1.bottom+10,180,128);
            [self addSubview:bgImageView2];
            
            UILabel *message1 = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, bgImageView2.bottom+20,300,140)];
            message1.textAlignment = NSTextAlignmentCenter;
            message1.font = FontOfSize(12);
            message1.textColor = UIColorFromRGBA(219,60,17, 1);
            message1.numberOfLines = 0;

            NSString*remarks=NSLocalizedString(@"Audit failed", @"审核未通过");
            message1.text = [NSString stringWithFormat:@"%@,%@",remarks,_messageViewModel.localMeeting.remarks];
            [self addSubview:message1];
            
            
            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,message1.bottom+5,90, 34);
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage R_imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
            NSString*cancel_meeting=NSLocalizedString(@"Re appointment", @"重新预约");
            [appointButton setTitle:cancel_meeting forState:UIControlStateNormal];
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
            case PSLocalMeetingCountdown:
            case PSLocalMeetingOntime:
        {
            
            
            self.contentSize = CGSizeMake(SCREEN_WIDTH,920);
            UIImage *bgImage = [UIImage R_imageNamed:@"已预约－已完成"];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView.frame = CGRectMake((SCREEN_WIDTH-180)/2,30,175,128);
            [self addSubview:bgImageView];
            [self scrollViewToBottom:NO];
            UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView.bottom+20, 200, 34)];
            countdownLabel.textAlignment = NSTextAlignmentCenter;
            countdownLabel.font = FontOfSize(12);
            countdownLabel.textColor = UIColorFromRGBA(51, 51, 51, 1);
            countdownLabel.numberOfLines = 0;
            [self addSubview:countdownLabel];
            countdownLabel.text = [NSString stringWithFormat:@"您已预约%@的实地会见",_messageViewModel.localMeeting.applicationDate];

        
            
            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,countdownLabel.bottom+10, 20, 20)];
            arrow.image = [UIImage R_imageNamed:@"箭头"];
            [self addSubview:arrow];
            
            UIImageView *bgImageView1 = [[UIImageView alloc] initWithImage:[UIImage R_imageNamed:@"审核中－已完成"]];
            bgImageView1.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView1.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow.bottom+10,180,128);
            [self addSubview:bgImageView1];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, bgImageView1.bottom+20, 200,35)];
            message.textAlignment = NSTextAlignmentCenter;
            message.font = FontOfSize(12);
//            message.textColor = UIColorFromRGBA(38,76,144, 1);
            message.textColor = UIColorFromRGBA(51, 51, 51, 1);
            message.numberOfLines = 0;
            NSString*audit=NSLocalizedString(@"Please wait patiently for the audit results during the booking audit", @"预约审核中，请耐心等待审核结果");
            message.text = audit;
            [self addSubview:message];
            
            
            UIImageView *arrow1 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-20)/2,message.bottom+10, 20, 20)];
            arrow1.image = [UIImage R_imageNamed:@"箭头"];
            [self addSubview:arrow1];
            
            UIImageView *bgImageView2 = [[UIImageView alloc] initWithImage:[UIImage R_imageNamed:@"审核通过－当前步骤"]];
            bgImageView2.contentMode = UIViewContentModeScaleAspectFill;
            bgImageView2.frame = CGRectMake((SCREEN_WIDTH-180)/2,arrow1.bottom+10,180,128);
            [self addSubview:bgImageView2];
            
            UILabel *message1 = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, bgImageView2.bottom+20,300, 34)];
            message1.textAlignment = NSTextAlignmentCenter;
            message1.font = FontOfSize(12);
            message1.textColor = UIColorFromRGBA(38,76,144, 1);
            message1.numberOfLines = 0;
            NSString *time = [NSString stringWithFormat:@"%@ %@",_messageViewModel.localMeeting.applicationDate,_messageViewModel.localMeeting.batch];
            NSString*passStrig =NSLocalizedString(@"Audit is approved. Please attend the meeting of%@on time.", @"审核通过,请准时参加%@的会见");
            message1.text = [NSString stringWithFormat:passStrig,time];
            NSRange ragnge = [message1.text rangeOfString:time];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:message1.text];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:ragnge];
            message1.attributedText = attrStr;
            [self addSubview:message1];
            
            UIImageView *timeLogo = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2,message1.bottom+15, 80, 13)];
            timeLogo.image = [UIImage R_imageNamed:@"预约倒计时"];
            [self addSubview:timeLogo];
            
            //计算时间戳---->转化为标准时间
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //指定时间显示样式: HH表示24小时制 hh表示12小时制
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            time = [time substringToIndex:time.length-6];
            time = [NSString stringWithFormat:@"%@:00",time];
            NSDate *lastDate = [formatter dateFromString:time];
            long firstStamp = [lastDate timeIntervalSince1970];
            
            //当前时间戳
            NSDate *second = [NSDate date];
            long secondTimeZone = [second timeIntervalSince1970];
            
            NSLog(@"%@",time);
            
            //倒计时总的秒数
            _secondsCountDown = firstStamp-secondTimeZone;
            //设置定时器
            _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
            //启动倒计时后会每秒钟调用一次方法 countDownAction
            
    
            NSString *H = [NSObject judegeIsVietnamVersion]?@"H":@"时";   //NSLocalizedString(@"H",@"时");
            NSString *M = [NSObject judegeIsVietnamVersion]?@"M":@"分";   //NSLocalizedString(@"M",@"分");
            NSString *S = [NSObject judegeIsVietnamVersion]?@"S":@"秒";   //NSLocalizedString(@"S",@"秒");
            
            //设置倒计时显示的时间
            NSString *str_hour = [NSString stringWithFormat:@"%02ld%@",_secondsCountDown/3600,H];//时
            NSString *str_minute = [NSString stringWithFormat:@"%02ld%@",(_secondsCountDown%3600)/60,M];//分
            NSString *str_second = [NSString stringWithFormat:@"%02ld%@",_secondsCountDown%60,S];//秒
            NSArray *timeStr = @[str_hour,str_minute,str_second];
            
            for (int i = 0; i<3; i++) {
                UIImageView *timeImg = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-44)/2-80+80*i,
                                                                        timeLogo.bottom+20, 44, 46)];
                timeImg.image = [UIImage R_imageNamed:@"倒计时牌"];
                [self addSubview:timeImg];
                
                UILabel *timeLabe = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 44, 20)];
                timeLabe.text = timeStr[i];
                timeLabe.tag = 10+i;
                
                timeLabe.textColor = [UIColor redColor];
                timeLabe.textAlignment = NSTextAlignmentCenter;
                timeLabe.font = FontOfSize(19);
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:timeLabe.text];
                UIFont *font = FontOfSize(10);
                [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(timeLabe.text.length-1, 1)];
                timeLabe.attributedText = attrStr;
                [timeImg addSubview:timeLabe];
            }
            
            UIImageView *LocationView = [[UIImageView alloc] initWithFrame:CGRectMake(8,timeLogo.bottom+86 ,SCREEN_WIDTH-16,220)];
            LocationView.contentMode =  UIViewContentModeScaleToFill;
            LocationView.image = [UIImage R_imageNamed:@"监狱信息底"];
            [self addSubview:LocationView];
            
            UIImageView *localImg = [[UIImageView alloc] initWithFrame:CGRectMake(18,15, 34, 34)];
            localImg.image = [UIImage R_imageNamed:@"定位icon"];
            [LocationView addSubview:localImg];
            
            UILabel *prisonsLab = [[UILabel alloc] initWithFrame:CGRectMake(localImg.right+4,15, 200, 20)];
            prisonsLab.text = _messageViewModel.prisonerDetail.jailName;
            prisonsLab.textColor = UIColorFromRGB(51, 51, 51);
            prisonsLab.font = FontOfSize(10);
            [LocationView addSubview:prisonsLab];
            
            float locationH = [NSObject judegeIsVietnamVersion]?30:20;
            UILabel *prisonsLocation = [[UILabel alloc] initWithFrame:CGRectMake(localImg.right+4,prisonsLab.bottom-4, 250, locationH)];
            prisonsLocation.text = _messageViewModel.localMeeting.address;
            prisonsLocation.textColor = UIColorFromRGB(51, 51, 51);
            prisonsLocation.font = FontOfSize(10);
            prisonsLocation.numberOfLines = 0;
            [LocationView addSubview:prisonsLocation];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(18,prisonsLocation.bottom+8,LocationView.width-36 ,1 )];
            [self addBorderToLayer:line];
            [LocationView addSubview:line];
            
            YYLabel *lxlab = [[YYLabel alloc] initWithFrame:CGRectMake(localImg.left, line.bottom+5, 200, 20)];
//            lxlab.attributedText = _messageViewModel.routeString;
            [self updateRouteString:_messageViewModel.routeString lab:lxlab];
            [LocationView addSubview:lxlab];
            
    
            UIButton* appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appointButton.frame = CGRectMake((SCREEN_WIDTH-90)/2,message1.bottom+230,90, 34);
            appointButton.titleLabel.font = FontOfSize(12);
            [appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [appointButton setBackgroundImage:[[UIImage R_imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
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

-(void)rightInterView:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(PSLocalMeetingWithoutAppointment);
    }
}

- (void)addBorderToLayer:(UIView *)view
{
    CAShapeLayer *border = [CAShapeLayer layer];
    //  线条颜色
    border.strokeColor = [UIColor lightGrayColor].CGColor;
    
    border.fillColor = nil;
    
    
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 0)];
    if (CGRectGetWidth(view.frame) > CGRectGetHeight(view.frame)) {
        [pat addLineToPoint:CGPointMake(view.bounds.size.width, 0)];
    }else{
        [pat addLineToPoint:CGPointMake(0, view.bounds.size.height)];
    }
    border.path = pat.CGPath;
    
    border.frame = view.bounds;
    
    // 不要设太大 不然看不出效果
    border.lineWidth = 0.5;
    border.lineCap = @"butt";
    
    //  第一个是 线条长度   第二个是间距    nil时为实线
    border.lineDashPattern = @[@6, @10];
    
    [view.layer addSublayer:border];
}

- (void)countDownAction {
    
    NSString *H = [NSObject judegeIsVietnamVersion]?@"H":@"时";   //NSLocalizedString(@"H",@"时");
    NSString *M = [NSObject judegeIsVietnamVersion]?@"M":@"分";//NSLocalizedString(@"M",@"分");
    NSString *S = [NSObject judegeIsVietnamVersion]?@"S":@"秒";//NSLocalizedString(@"S",@"秒");
    
    //倒计时-1
    _secondsCountDown--;
    //重新计算 时/分/秒
    NSString *str_hour = [NSString stringWithFormat:@"%02ld%@",_secondsCountDown/3600,H];
    
    NSString *str_minute = [NSString stringWithFormat:@"%02ld%@",(_secondsCountDown%3600)/60,M];
    
    NSString *str_second = [NSString stringWithFormat:@"%02ld%@",_secondsCountDown%60,S];
    
    
    //修改倒计时标签及显示内容
    NSArray *timeAry = @[str_hour,str_minute,str_second];
    for (int i = 0;i<3;i++ ) {
        UILabel *timeLabe = (UILabel *)[self viewWithTag:i+10];
        timeLabe.text = timeAry[i];
        UIFont *font = FontOfSize(10);
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:timeLabe.text];
        [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(timeLabe.text.length-1, 1)];
        timeLabe.attributedText = attrStr;
    }

    //当倒计时到0时做需要的操作，比如验证码过期不能提交
    if(_secondsCountDown==0){
        
        [_countDownTimer invalidate];
    }
}

- (void)pageAction:(UIImageView *)img {
    [self allImg];
    img.image = [UIImage R_imageNamed:@"当前页圈"];
    NSInteger index = img.tag - 100;
    
}

- (void)allImg {
    for (int i = 0; i<3; i++) {
        UIImageView *img = (UIImageView *)[self viewWithTag:100+i];
        img.image = [UIImage R_imageNamed:@"未选中圈"];
    }
}

#pragma mark scrollView的代理方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index=scrollView.contentOffset.x/scrollView.bounds.size.width;
    [self allImg];
    UIImageView *img = (UIImageView *)[self viewWithTag:index+100];
    img.image = [UIImage R_imageNamed:@"当前页圈"];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index=scrollView.contentOffset.x/scrollView.bounds.size.width;
    [self allImg];
    UIImageView *img = (UIImageView *)[self viewWithTag:index+100];
    img.image = [UIImage R_imageNamed:@"当前页圈"];
}

- (void)scrollViewToBottom:(BOOL)animated

{
    if(self.contentSize.height>self.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.contentSize.height -self.frame.size.height);
        [self setContentOffset:offset animated:animated];
    }
    
}

- (void)updateRouteString:(NSAttributedString *)routeString lab:(YYLabel *)routeLabel {
    int HorSidePadding = 15;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(SCREEN_WIDTH - 4 * HorSidePadding, MAXFLOAT) insets:UIEdgeInsetsZero];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:routeString];
    routeLabel.attributedText = routeString;
    routeLabel.textLayout = textLayout;
}


#pragma mark - 轮播定时器

/**
 开始定时器
 */
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    
    // 设置timer在运行循环中模式为
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 结束定时器
 */
- (void)endTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

/**
 下一页
 */
- (void)nextPage
{
    _page++;
    NSInteger index = 2-self.page%3;
    UIScrollView *scrollView = (UIScrollView *)[self viewWithTag:10086];
    scrollView.bouncesZoom = NO;
    [scrollView setContentOffset:CGPointMake(index * scrollView.frame.size.width, 0) animated:YES];

}











@end
