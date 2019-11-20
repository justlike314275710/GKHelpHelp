//
//  PSLocalMeetingCalendarView.m
//  PrisonService
//
//  Created by calvin on 2018/5/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocalMeetingCalendarView.h"
#import "FSCalendar.h"
#import "NSDate+Components.h"

@interface PSLocalMeetingCalendarView()<FSCalendarDataSource,FSCalendarDelegate>

@property (nonatomic, strong) FSCalendar *calendar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIControl *backgroundView;
@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *yearLabel;
@property (strong, nonatomic) NSCalendar *gregorian;

@end

@implementation PSLocalMeetingCalendarView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [self renderContents];
    }
    return self;
}

- (void)prePage {
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

- (void)nextPage {
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (void)appointAction {
    [SDTrackTool logEvent:APPLY_SURE_MEETING];
    if (self.appoint) {
        self.appoint(self.calendar.selectedDate);
    }
    [self dismiss];
}

- (void)updateTitle {
    NSDate *date = self.calendar.currentPage;
    _monthLabel.text = [date dateStringWithFormat:@"MMMM"];
    _yearLabel.text = [date dateStringWithFormat:@"yyyy"];
}

- (void)renderContents {
    _backgroundView = [UIControl new];
    [_backgroundView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self addSubview:_backgroundView];
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    _contentView = [UIView new];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 4.0;
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(self);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(326);
    }];
    
    UIColor *topColor = UIColorFromHexadecimalRGB(0x264c90);
    UIView *topView = [UIView new];
    topView.backgroundColor = topColor;
    [_contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(46);
    }];
    _monthLabel = [UILabel new];
    _monthLabel.textAlignment = NSTextAlignmentCenter;
    _monthLabel.font = FontOfSize(12);
    _monthLabel.textColor = [UIColor whiteColor];
    [topView addSubview:_monthLabel];
    [_monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.centerX.mas_equalTo(topView);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(13);
    }];
    _yearLabel = [UILabel new];
    _yearLabel.textAlignment = NSTextAlignmentCenter;
    _yearLabel.font = FontOfSize(10);
    _yearLabel.textColor = [UIColor whiteColor];
    [topView addSubview:_yearLabel];
    [_yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.centerX.mas_equalTo(topView);
        make.width.mas_equalTo(self.monthLabel);
        make.bottom.mas_equalTo(0);
    }];
    
    CGFloat bWidth = 40;
    UIButton *preButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [preButton addTarget:self action:@selector(prePage) forControlEvents:UIControlEventTouchUpInside];
    [preButton setImage:[UIImage imageNamed:@"localMeetingLeftArrow"] forState:UIControlStateNormal];
    preButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [topView addSubview:preButton];
    [preButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.monthLabel.mas_left);
        make.top.mas_equalTo(self.monthLabel.mas_top).offset(3);
        make.bottom.mas_equalTo(self.yearLabel.mas_bottom);
        make.width.mas_equalTo(bWidth);
    }];
    UIButton *nexButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nexButton addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [nexButton setImage:[UIImage imageNamed:@"localMeetingRightArrow"] forState:UIControlStateNormal];
    nexButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [topView addSubview:nexButton];
    [nexButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.monthLabel.mas_right);
        make.top.mas_equalTo(self.monthLabel.mas_top).offset(3);
        make.bottom.mas_equalTo(self.yearLabel.mas_bottom);
        make.width.mas_equalTo(bWidth);
    }];
    
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
    CGSize aSize = CGSizeMake(80, 27);
    UIButton *appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [appointButton addTarget:self action:@selector(appointAction) forControlEvents:UIControlEventTouchUpInside];
    appointButton.titleLabel.font = FontOfSize(10);
    [appointButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    NSString*Confirm_appointment=NSLocalizedString(@"Confirm_appointment", @"确定预约");
    [appointButton setTitle:Confirm_appointment forState:UIControlStateNormal];
    appointButton.layer.cornerRadius = aSize.height/2;
    appointButton.layer.borderWidth = 1.0;
    appointButton.layer.borderColor = UIColorFromHexadecimalRGB(0x264C90).CGColor;
    [bottomView addSubview:appointButton];
    [appointButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bottomView);
        make.size.mas_equalTo(aSize);
    }];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectZero];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *language = langArr.firstObject;
    self.calendar.locale = [NSLocale localeWithLocaleIdentifier:language];
    self.calendar.headerHeight = 0;
    self.calendar.weekdayHeight = 30;
    self.calendar.appearance.weekdayTextColor = [UIColor whiteColor];
    self.calendar.appearance.weekdayFont = FontOfSize(6);
    self.calendar.appearance.titleFont = FontOfSize(8);
    self.calendar.appearance.titleTodayColor = [UIColor whiteColor];
    self.calendar.appearance.titlePlaceholderColor = AppBaseTextColor2;
    self.calendar.appearance.todayColor = topColor;
    self.calendar.appearance.selectionColor = AppBaseTextColor1;
    self.calendar.calendarWeekdayView.backgroundColor = topColor;
    NSDate *dateNow = self.calendar.today;
    NSDate *nextDay = [dateNow dateByAddingTimeInterval:24*60*60];
    [self.calendar selectDate:nextDay];
    [_contentView insertSubview:self.calendar atIndex:0];
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(appointButton.mas_top).offset(1);
        make.top.mas_equalTo(topView.mas_bottom).offset(-1);
    }];
    [self updateTitle];
}

- (void)show1 {
    self.frame = CGRectMake(self.mj_origin.x, self.mj_origin.y+326, self.mj_w, self.mj_h);
    [UIView animateWithDuration:.35 animations:^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = window.bounds;
        [window addSubview:self];
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(self.mj_origin.x, self.mj_origin.y, self.mj_w, self.mj_h);
    }];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.8],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.contentView.layer addAnimation:animation forKey:@"popup"];
}



- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    self.contentView.alpha = 0.f;
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.backgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else {
        [self removeFromSuperview];
    }
}

#pragma mark - FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    if (![[self.calendar.currentPage yearMonth] isEqualToString:[date yearMonth]]) {
        [self.calendar selectDate:date scrollToDate:YES];
    }
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    if (![self.calendar.selectedDate.yearMonth isEqualToString:self.calendar.currentPage.yearMonth]) {
        if ([self.calendar.currentPage.yearMonth isEqualToString:self.calendar.today.yearMonth]) {
            if (![self.calendar.selectedDate.yearMonthDay isEqualToString:self.calendar.today.yearMonthDay]) {
                NSDate *todayNext = [self.calendar.today dateByAddingTimeInterval:24 * 60 * 60];
                [self.calendar selectDate:todayNext];
            }
        }else{
            [self.calendar selectDate:self.calendar.currentPage];
        }
    }
    [self updateTitle];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    BOOL shouldSelect = NO;
    if (([date compare:self.calendar.today] == NSOrderedDescending)) {
        shouldSelect = YES;
    }
    return shouldSelect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
