//
//  PSHistoryCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSHistoryCell.h"

@implementation PSHistoryCell


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
    CGFloat sidePadding = 15;
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
    _iconView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"监狱icon"]];
    [contentView addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.top.mas_equalTo(verticalPadding);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(22);
    }];

    //监狱名称
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
        if (IS_iPhone_5) {
            make.width.mas_equalTo(130);
        }
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
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(100);
        }];
    }else{
        [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(contentView.mas_right).offset(-50-sidePadding);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(50);
        }];
    }
     _statusButton.layer.cornerRadius=11;
    [_statusButton setBackgroundColor: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]];
    _statusButton.titleLabel.numberOfLines=0;
    _cancleButton=[UIButton new];
    [contentView addSubview:  _cancleButton];
      _cancleButton.titleLabel.font=FontOfSize(12);
    NSString*cancel_meet=NSLocalizedString(@"cancel_meet",@"取消会见" );
    [_cancleButton setTitle:cancel_meet forState:UIControlStateNormal];
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        [  _cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_statusButton.mas_left).offset(-10);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(100);
        }];
    }else{
        [  _cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_statusButton.mas_left).offset(-10);
            make.top.mas_equalTo(verticalPadding);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(60);
        }];
    }
     _cancleButton.layer.cornerRadius=11;
    [_cancleButton setTitleColor:UIColorFromRGB(153, 153, 153) forState:UIControlStateNormal];
    _cancleButton.contentHorizontalAlignment=UIControlContentVerticalAlignmentCenter;
    [_cancleButton.layer setBorderWidth:1.0];
    _cancleButton.titleLabel.numberOfLines=0;
    _cancleButton.layer.borderColor=UIColorFromRGB(153, 153, 153).CGColor;
    
    
    //服刑人员
    _prisonerTextLab = [UILabel new];
    _prisonerTextLab = [UILabel new];
    _prisonerTextLab.font = FontOfSize(12);
    _prisonerTextLab.textAlignment = NSTextAlignmentLeft;
    _prisonerTextLab.textColor = AppBaseTextColor2;
    _prisonerTextLab.text = @"服刑人员";
    [contentView addSubview:_prisonerTextLab];
    [_prisonerTextLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.top.mas_equalTo(_iconView.mas_bottom).offset(sidePadding+10);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(100);
    }];
    
    _prisonerLab = [UILabel new];
    _prisonerLab.font = FontOfSize(12);
    _prisonerLab.textAlignment = NSTextAlignmentRight;
    _prisonerLab.textColor = AppBaseTextColor2;
    _prisonerLab.text = @"hahahaha";
    [contentView addSubview:_prisonerLab];
    [_prisonerLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-sidePadding);
        make.centerY.mas_equalTo(_prisonerTextLab);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(self.frame.size.width-2*sidePadding-100);
    }];
    
    
    //申请日期
    _dateTextLabel = [UILabel new];
    _dateTextLabel.font = FontOfSize(12);
    _dateTextLabel.textAlignment = NSTextAlignmentLeft;
    _dateTextLabel.textColor = AppBaseTextColor2;
    _dateTextLabel.text = @"会见日期";
    [contentView addSubview:_dateTextLabel];
    [_dateTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.top.mas_equalTo(_prisonerTextLab.mas_bottom).offset(verticalPadding);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(100);
    }];
    
    _dateLabel = [UILabel new];
    _dateLabel.font = FontOfSize(12);
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.textColor = AppBaseTextColor2;
    [contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.centerY.mas_equalTo(_dateTextLabel);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(self.frame.size.width-2*sidePadding-100);
    }];
    
    
    _otherLabel = [UILabel new];
    _otherLabel.font = FontOfSize(12);
    _otherLabel.textAlignment = NSTextAlignmentRight;
    _otherLabel.textColor = AppBaseTextColor2;
    _otherLabel.numberOfLines = 0;
    [contentView addSubview:_otherLabel];
    [_otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_dateTextLabel.mas_bottom).offset(verticalPadding-5);
//        make.bottom.mas_equalTo(-verticalPadding);
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
        make.top.mas_equalTo(_dateTextLabel.mas_bottom).offset(verticalPadding);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(sidePadding);
        make.width.mas_equalTo(50);
    }];
    
    //过期原因
    _overDueTextLab = [UILabel new];
    _overDueTextLab.font = FontOfSize(12);
    _overDueTextLab.textAlignment = NSTextAlignmentLeft;
    _overDueTextLab.textColor = AppBaseTextColor2;
    _overDueTextLab.text = @"过期原因";
    [contentView addSubview:_overDueTextLab];
    [_overDueTextLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_otherTextLabel.mas_bottom).offset(verticalPadding);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(sidePadding);
        make.width.mas_equalTo(50);
    }];
    
    _overDueLab = [UILabel new];
    _overDueLab.font = FontOfSize(12);
    _overDueLab.textAlignment = NSTextAlignmentRight;
    _overDueLab.textColor = AppBaseTextColor2;
    _overDueLab.numberOfLines = 0;
    [contentView addSubview:_overDueLab];
    [_overDueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_overDueTextLab).offset(-5);
        make.height.mas_equalTo(30);
        make.right.mas_equalTo(-sidePadding);
        make.width.mas_equalTo(self.frame.size.width-sidePadding-90);
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
