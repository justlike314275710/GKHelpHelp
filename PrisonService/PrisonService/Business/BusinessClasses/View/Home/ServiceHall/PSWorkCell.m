//
//  PSWorkCell.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWorkCell.h"

@implementation PSWorkCell
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
    bgImageView.image = [[UIImage imageNamed:@"serviceHallWorkBg"] stretchImage];
    [self addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(0);
    }];
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bgImageView.mas_left).offset(10);
        make.top.mas_equalTo(bgImageView.mas_top);
        make.bottom.mas_equalTo(bgImageView.mas_bottom).offset(-5);
        make.right.mas_equalTo(bgImageView.mas_right).offset(-15);
    }];
    _prisonLabel = [UILabel new];
    _prisonLabel.textAlignment = NSTextAlignmentLeft;
    _prisonLabel.font = AppBaseTextFont2;
    _prisonLabel.textColor = AppBaseTextColor3;
    [contentView addSubview:_prisonLabel];
    [_prisonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(120);
        make.bottom.mas_equalTo(contentView.mas_centerY).offset(-5);
        make.height.mas_equalTo(15);
    }];
    _dateLabel = [UILabel new];
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    _dateLabel.font = FontOfSize(10);
    _dateLabel.textColor = AppBaseTextColor2;
    [contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_prisonLabel.mas_left);
        make.right.mas_equalTo(_prisonLabel.mas_right);
        make.top.mas_equalTo(contentView.mas_centerY).offset(5);
        make.height.mas_equalTo(15);
    }];
    _titleLabel = [UILabel new];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = FontOfSize(12);
    _titleLabel.textColor = AppBaseTextColor1;
    [contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_prisonLabel.mas_right).offset(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(13);
    }];
    _detailLabel = [UILabel new];
    _dateLabel.numberOfLines = 0;
    _detailLabel.textAlignment = NSTextAlignmentLeft;
    _detailLabel.font = FontOfSize(10);
    _detailLabel.textColor = AppBaseTextColor2;
    [contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLabel.mas_left);
        make.right.mas_equalTo(_titleLabel.mas_right);
        make.bottom.mas_equalTo(-10);
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(14);
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
