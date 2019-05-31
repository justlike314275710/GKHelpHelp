//
//  PSAppointmentProcessView.m
//  PrisonService
//
//  Created by kky on 2019/5/27.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSAppointmentProcessView.h"

@implementation PSAppointmentProcessView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    CGFloat horSpace = 15;
    CGFloat verSpace = 20;
    UIView *headerView = [UIView new];
    headerView.backgroundColor = UIColorFromHexadecimalRGB(0x264c90);
    [self addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSpace);
        make.top.mas_equalTo(verSpace);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(14);
    }];
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = FontOfSize(14);
    titleLabel.textColor = UIColorFromHexadecimalRGB(0x3333333);
    NSString *family_appointment = @"远程探视流程";
    titleLabel.text = family_appointment;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_right).offset(10);
        make.top.mas_equalTo(headerView.mas_top);
        make.bottom.mas_equalTo(headerView.mas_bottom);
        make.right.mas_equalTo(-horSpace);
    }];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSpace);
        make.right.mas_equalTo(-horSpace);
        make.height.mas_equalTo(300);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(16);
    }];
    ViewBorderRadius(bgView, 0, 1, UIColorFromRGB(234, 235, 238));
    //step1
    UIColor *dotColor = UIColorFromRGB(38, 76, 144);
    NSInteger spaceX = 14;
    NSInteger titleSpaceX = 7;
    UIView *oneStepDot = [UIView new];
    [bgView addSubview:oneStepDot];
    [oneStepDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spaceX);
        make.height.width.mas_equalTo(4);
        make.top.mas_equalTo(40);
    }];
    ViewBorderRadius(oneStepDot, 2, 1, dotColor);
    
    UILabel *oneTitleLab = [UILabel new];
    oneTitleLab.textColor = AppBaseTextColor1;
    oneTitleLab.text = @"第一步\n选择远程探视时间";
    oneTitleLab.numberOfLines = 2;
    oneTitleLab.font = FontOfSize(12);
    oneTitleLab.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:oneTitleLab];
    [oneTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(oneStepDot.mas_right).offset(titleSpaceX);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(140);
        make.top.mas_equalTo(oneStepDot.mas_top).offset(-4);
    }];
    
    UIImageView *oneStepImg = [UIImageView new];
    oneStepImg.image = IMAGE_NAMED(@"oneStepIcon");
    [bgView addSubview:oneStepImg];
    [oneStepImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(78);
        make.width.mas_equalTo(107);
        make.top.mas_equalTo(11);
        make.right.mas_equalTo(-spaceX);
    }];
    
    UIView *oneLine = [UIView new];
    oneLine.backgroundColor = UIColorFromRGB(234, 235, 238);
    [bgView addSubview:oneLine];
    [oneLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spaceX);
        make.right.mas_equalTo(-spaceX);
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(1);
    }];
    
    //step2
    UIView *twoStepDot = [UIView new];
    [bgView addSubview:twoStepDot];
    [twoStepDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-spaceX);
        make.height.width.mas_equalTo(4);
        make.top.mas_equalTo(40+100);
    }];
    ViewBorderRadius(twoStepDot, 2, 1, dotColor);
    
    UIImageView *twoStepImg = [UIImageView new];
    twoStepImg.image = IMAGE_NAMED(@"twoStepIcon");
    [bgView addSubview:twoStepImg];
    [twoStepImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(78);
        make.width.mas_equalTo(107);
        make.top.mas_equalTo(11+100);
        make.left.mas_equalTo(spaceX);
    }];
    
    UILabel *twoTitleLab = [UILabel new];
    twoTitleLab.textColor = AppBaseTextColor1;
    twoTitleLab.text = @"第二步\n提交远程探视申请-等待审核";
    twoTitleLab.numberOfLines = 3;
    twoTitleLab.font = FontOfSize(12);
    twoTitleLab.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:twoTitleLab];
    [twoTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(twoStepDot.mas_left).offset(-titleSpaceX);
        make.height.mas_equalTo(45);
        make.left.mas_equalTo(twoStepImg.mas_right).offset(10);
        make.top.mas_equalTo(twoStepDot.mas_top).offset(-4);
    }];
    
    
    UIView *twoLine = [UIView new];
    twoLine.backgroundColor = UIColorFromRGB(234, 235, 238);
    [bgView addSubview:twoLine];
    [twoLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spaceX);
        make.right.mas_equalTo(-spaceX);
        make.top.mas_equalTo(200);
        make.height.mas_equalTo(1);
    }];
    //Step3
    UIView *threeStepDot = [UIView new];
    [bgView addSubview:threeStepDot];
    [threeStepDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spaceX);
        make.height.width.mas_equalTo(4);
        make.top.mas_equalTo(40+200);
    }];
    ViewBorderRadius(threeStepDot, 2, 1, dotColor);
    
    UIImageView *threeStepImg = [UIImageView new];
    threeStepImg.image = IMAGE_NAMED(@"threeStepIcon");
    [bgView addSubview:threeStepImg];
    [threeStepImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(78);
        make.width.mas_equalTo(107);
        make.top.mas_equalTo(11+200);
        make.right.mas_equalTo(-spaceX);
    }];

    
    UILabel *threeTitleLab = [UILabel new];
    threeTitleLab.textColor = AppBaseTextColor1;
    threeTitleLab.text = @"第三步\n审核通过,远程探视当日保持手机网络畅通,等待监狱发起远程探视视频邀请";
    threeTitleLab.numberOfLines = 0;
    threeTitleLab.font = FontOfSize(12);
    threeTitleLab.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:threeTitleLab];
    [threeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(oneStepDot.mas_right).offset(titleSpaceX);
        make.height.mas_equalTo(80);
        make.right.mas_equalTo(threeStepImg.mas_left).offset(-10);
        make.centerY.mas_equalTo(threeStepDot);
    }];
    
   

    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
