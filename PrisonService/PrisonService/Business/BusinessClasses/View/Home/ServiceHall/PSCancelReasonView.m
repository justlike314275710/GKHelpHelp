//
//  PSCancelReasonView.m
//  PrisonService
//
//  Created by calvin on 2018/5/23.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSCancelReasonView.h"

@interface PSCancelReasonView()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIControl *backgroundView;
@property (nonatomic, strong) UITableView *reasonTableView;
@property (nonatomic, strong) NSArray *reasons;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation PSCancelReasonView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSString*application_examined=NSLocalizedString(@"application_examined", @"会见申请迟迟未审核");
        NSString*agenda_conflict=NSLocalizedString(@"agenda_conflict", @"日程冲突");
        NSString*plan_change=NSLocalizedString(@"plan_change", @"计划有变");
        NSString*other_reason=NSLocalizedString(@"other_reason", @"其他个人原因");
        self.reasons = @[application_examined,agenda_conflict,plan_change,other_reason];
        [self renderContents];
    }
    return self;
}

- (void)okAction {
    [self dismiss];
    if (self.didCancel) {
        self.didCancel(self.reasons[self.selectedIndex]);
    }
}

- (void)cancelAction {
    [self dismiss];
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
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(240);
    }];
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textColor = AppBaseTextColor1;
    NSString*cancel_meeting=NSLocalizedString(@"cancel_meeting", @"取消预约");
    titleLabel.text = cancel_meeting;
    [_contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(45);
    }];
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    NSString*cancel=NSLocalizedString(@"cancel", @"取消");
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [okButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
        [okButton addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    okButton.titleLabel.font = FontOfSize(12);
    [okButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    [okButton setTitle:determine forState:UIControlStateNormal];
    okButton.tag=2;
    [bottomView addSubview:okButton];
    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bottomView.mas_centerX);
        make.top.bottom.right.mas_equalTo(0);
    }];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
       [cancelButton addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = FontOfSize(13);
    [cancelButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    [cancelButton setTitle:cancel forState:UIControlStateNormal];
    cancelButton.tag=1;
    [bottomView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(bottomView.mas_centerX);
        make.top.bottom.left.mas_equalTo(0);
    }];
    self.reasonTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.reasonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.reasonTableView.rowHeight = 35;
    self.reasonTableView.dataSource = self;
    self.reasonTableView.delegate = self;
    [self.reasonTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    [_contentView addSubview:self.reasonTableView];
    [self.reasonTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.bottom.mas_equalTo(bottomView.mas_top);
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
    if ([NSThread isMainThread]) {
        [self dismissAnimated:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissAnimated:YES];
        });
    }
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

#pragma mark - UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reasons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = indexPath.row == self.selectedIndex ? [UIImage imageNamed:@"cartProductSelected"] : [UIImage imageNamed:@"cartProductNormal"];
    cell.textLabel.font = FontOfSize(12);
    cell.textLabel.textColor = AppBaseTextColor2;
    cell.textLabel.text = self.reasons[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.selectedIndex) {
        self.selectedIndex = indexPath.row;
        [self.reasonTableView reloadData];
    }
}




#pragma mark - alertView按钮点击回调
- (void)buttonEvent:(UIButton *)sender
{
    if (sender.tag == 2) {
        [self dismiss];
        if (self.didCancel) {
            self.didCancel(self.reasons[self.selectedIndex]);
        }
        if (self.clickIndex) {
            self.clickIndex(sender.tag);
        }
    }
    else{
        [self dismiss];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
