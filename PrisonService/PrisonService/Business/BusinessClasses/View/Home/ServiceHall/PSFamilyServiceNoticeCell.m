//
//  PSFamilyServiceNoticeCell.m
//  PrisonService
//
//  Created by kky on 2019/5/30.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyServiceNoticeCell.h"

@implementation PSFamilyServiceNoticeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    UIImageView *bgImageView = [UIImageView new];
    bgImageView.image = [[UIImage imageNamed:@"userCenterHistoryIconBg"] stretchImage];
    [self addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    CGFloat sidePadding = 10;
    CGFloat verticalPadding = 10;
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgImageView.mas_top);
        make.left.mas_equalTo(bgImageView.mas_left);
        make.right.mas_equalTo(bgImageView.mas_right);
        make.bottom.mas_equalTo(bgImageView.mas_bottom);
    }];
    _iconView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"添加家属icon"]];
    [contentView addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.top.mas_equalTo(verticalPadding);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(22);
    }];
    
    _iconLable=[UILabel new];
    [contentView addSubview:_iconLable];
    _iconLable.font=AppBaseTextFont3;
    _iconLable.textColor=AppBaseTextColor1;
    _iconLable.text=@"王二(41000)";
    _iconLable.numberOfLines = 0;
    [_iconLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconView.mas_right).offset(sidePadding);
        make.centerY.mas_equalTo(_iconView);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(150);
        if (IS_iPhone_5) make.width.mas_equalTo(130);
        
    }];
    
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString*language = langArr.firstObject;
    _statusButton=[UIButton new];
    [contentView addSubview:_statusButton];
    _statusButton.titleLabel.font=FontOfSize(12);
    [_statusButton setTitle:@"审核中" forState:UIControlStateNormal];
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(contentView.mas_right).offset(-100-sidePadding);
            make.centerY.mas_equalTo(_iconView);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(100);
        }];
    }else{
        [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(contentView.mas_right).offset(-50-sidePadding);
            make.centerY.mas_equalTo(_iconView);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(50);
        }];
    }
    _statusButton.layer.cornerRadius=11;
    [_statusButton setBackgroundColor: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]];
    _statusButton.titleLabel.numberOfLines=0;

    //监狱名称
    _prisonNameLab = [UILabel new];
    _prisonNameLab.font = FontOfSize(12);
    _prisonNameLab.textAlignment = NSTextAlignmentLeft;
    _prisonNameLab.textColor = AppBaseTextColor2;
    _prisonNameLab.text = @"监狱名称";
    [contentView addSubview:_prisonNameLab];
    [_prisonNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.top.mas_equalTo(_iconView.mas_bottom).offset(sidePadding+15);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(100);
    }];
    
    _prisonNameTextLab = [UILabel new];
    _prisonNameTextLab.font = FontOfSize(12);
    _prisonNameTextLab.textAlignment = NSTextAlignmentRight;
    _prisonNameTextLab.textColor = AppBaseTextColor2;
    [contentView addSubview:_prisonNameTextLab];
    [_prisonNameTextLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_prisonNameLab);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(self.frame.size.width-sidePadding-90);
    }];
    
    //囚号or家属姓名
    _prisonNumberLab = [UILabel new];
    _prisonNumberLab.font = FontOfSize(12);
    _prisonNumberLab.textAlignment = NSTextAlignmentLeft;
    _prisonNumberLab.textColor = AppBaseTextColor2;
    _prisonNumberLab.text = @"囚号";
    [contentView addSubview:_prisonNumberLab];
    [_prisonNumberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_prisonNameLab.mas_bottom).offset(sidePadding);
        make.left.mas_equalTo(sidePadding);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(50);
    }];

    _prisonNumberTextLab = [UILabel new];
    _prisonNumberTextLab.font = FontOfSize(12);
    _prisonNumberTextLab.textAlignment = NSTextAlignmentRight;
    _prisonNumberTextLab.textColor = AppBaseTextColor2;
    [contentView addSubview:_prisonNumberTextLab];
    [_prisonNumberTextLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_prisonNumberLab);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(self.frame.size.width-sidePadding-90);
    }];
    
    //申请日期
    _dateTextLabel = [UILabel new];
    _dateTextLabel.font = FontOfSize(12);
    _dateTextLabel.textAlignment = NSTextAlignmentLeft;
    _dateTextLabel.textColor = AppBaseTextColor2;
    _dateTextLabel.text = @"会见日期";
    [contentView addSubview:_dateTextLabel];
    [_dateTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_prisonNumberLab.mas_bottom).offset(sidePadding);
        make.left.mas_equalTo(sidePadding);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(50);
    }];
    
    _dateLabel = [UILabel new];
    _dateLabel.font = FontOfSize(12);
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.textColor = AppBaseTextColor2;
    [contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_dateTextLabel);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(self.frame.size.width-sidePadding-90);
    }];
    
    //拒绝原因
    _otherLabel = [UILabel new];
    _otherLabel.font = FontOfSize(12);
    _otherLabel.textAlignment = NSTextAlignmentRight;
    _otherLabel.textColor = AppBaseTextColor2;
    _otherLabel.numberOfLines = 0;
    [contentView addSubview:_otherLabel];
    [_otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_dateLabel.mas_bottom).offset(sidePadding);
        make.height.mas_equalTo(30);
        make.right.mas_equalTo(-sidePadding);
        make.width.mas_equalTo(self.frame.size.width-sidePadding-90);
    }];
    
    _otherTextLabel = [PSLabel new];
    _otherTextLabel.font = FontOfSize(12);
    _otherTextLabel.textAlignment = NSTextAlignmentLeft;
    _otherTextLabel.textColor = AppBaseTextColor2;
    _otherTextLabel.text = @"拒绝原因";
    [contentView addSubview:_otherTextLabel];
    [_otherTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_otherLabel.mas_top);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(sidePadding);
        make.width.mas_equalTo(50);
    }];
    _otherTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
    _otherTextLabel.numberOfLines=0;
}

- (void)setModel:(PSFamilyServiceNoticeModel *)model {
    _model = model;
    //添加会见家属成员
    if ([model.businessType isEqualToString:@"3"]) {
        _iconLable.text = @"添加家属";
        _iconView.image = [UIImage imageNamed:@"添加家属icon"];
        //囚号or家属姓名
        _prisonNumberLab.text = @"家属姓名";
        _prisonNumberTextLab.text = model.familyName; //家属姓名
        
    } else if ([model.businessType isEqualToString:@"2"]) { //添加绑定服刑人员
        _iconLable.text = @"添加服刑人员";
        _iconView.image = [UIImage imageNamed:@"添加服刑人员icon"];
        //囚号or家属姓名
        _prisonNumberLab.text = @"囚号";
        _prisonNumberTextLab.text = model.prisonerNumber; //囚号
    }
    
    if ([model.status isEqualToString:@"PENDING"]) { //审核中
        [_statusButton setBackgroundColor: UIColorFromRGB(255, 138, 7)];
        [_statusButton setTitle:@"审核中" forState:UIControlStateNormal];
        _otherTextLabel.hidden = YES;
    } else if ([model.status isEqualToString:@"DENIED"]) { //已拒绝
        [_statusButton setBackgroundColor: UIColorFromRGB(198, 8,8)];
        [_statusButton setTitle:@"已拒绝" forState:UIControlStateNormal];
        _otherTextLabel.hidden = NO;
    } else if ([model.status isEqualToString:@"PASSED"]) { //已通过
        [_statusButton setBackgroundColor: UIColorFromRGB(0,142,60)];
        [_statusButton setTitle:@"已通过" forState:UIControlStateNormal];
        _otherTextLabel.hidden = YES;
    }
    _prisonNameTextLab.text = model.jailName;
    _dateLabel.text = model.applicationDate;
    _otherLabel.text = model.remarks;
}




- (void)awakeFromNib {
    [super awakeFromNib];
}


@end
