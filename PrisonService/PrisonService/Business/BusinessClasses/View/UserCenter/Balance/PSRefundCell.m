//
//  PSRefundCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//
#define DefaultLabelHeight 30
#define VerSidePadding 6
#import "PSRefundCell.h"

@implementation PSRefundCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        CGFloat sidePadding = 15;
        CGFloat verPadding = VerSidePadding;
        CGFloat labelHeight = DefaultLabelHeight;
        _contentLabel = [UILabel new];
        _contentLabel.font = AppBaseTextFont3;
        _contentLabel.textColor =  UIColorFromRGB(51, 51, 51);
        _contentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview: _contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-sidePadding);
            make.width.mas_equalTo(80);
            make.top.mas_equalTo(verPadding);
            make.height.mas_equalTo(labelHeight);
        }];
    
        
        _titleLabel = [UILabel new];
        _titleLabel.font = AppBaseTextFont3;
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines=0;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(sidePadding);
            make.right.mas_equalTo(_contentLabel.mas_left).offset(20);
            make.top.mas_equalTo( _contentLabel.mas_top);
           // make.bottom.mas_equalTo( _contentLabel.mas_bottom);
        }];
      
         _dateLabel = [UILabel new];
         _dateLabel.font = FontOfSize(10);
        _dateLabel.textColor = UIColorFromRGB(153, 153, 153);
         _dateLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_dateLabel];
        [ _dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(sidePadding);
            make.right.mas_equalTo(-sidePadding);
            make.bottom.mas_equalTo(-verPadding);
            make.top.mas_equalTo(_contentLabel.mas_bottom).offset(verPadding);
        }];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
