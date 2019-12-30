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
        _contentLabel.font = FontOfSize(18);
        _contentLabel.textColor =  UIColorFromRGB(51, 51, 51);
        _contentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview: _contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-sidePadding);
            make.width.mas_equalTo(100);
            make.top.mas_equalTo(10);
            make.height.mas_equalTo(15);
        }];
    
        _titleLabel = [UILabel new];
        _titleLabel.font = AppBaseTextFont3;
        _titleLabel.textColor = UIColorFromRGB(51, 51, 51);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines=0;
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(sidePadding);
            make.right.mas_equalTo(_contentLabel.mas_left).offset(0);
            make.top.mas_equalTo(2);
            make.height.mas_equalTo(35);
            make.top.mas_equalTo(0);
        }];
      
        _dateLabel = [UILabel new];
        _dateLabel.font = FontOfSize(10);
        _dateLabel.textColor = UIColorFromRGB(153, 153, 153);
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_dateLabel];
        [ _dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-sidePadding);
            make.height.mas_equalTo(15);
            make.top.mas_equalTo(_titleLabel.mas_bottom).offset(-2);
        }];
        
        _payWayLab = [UILabel new];
        _payWayLab.font = FontOfSize(10);
        _payWayLab.textColor = UIColorFromRGB(153, 153, 153);
        _payWayLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_payWayLab];
        [ _payWayLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-sidePadding);
            make.height.mas_equalTo(15);
            make.top.mas_equalTo(_dateLabel.mas_bottom).offset(2);
        }];
        
        _orderNoLab = [UILabel new];
        _orderNoLab.font = FontOfSize(10);
        _orderNoLab.textColor = UIColorFromRGB(153, 153, 153);
        _orderNoLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_orderNoLab];
        [ _orderNoLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-sidePadding);
            make.height.mas_equalTo(15);
            make.top.mas_equalTo(_payWayLab.mas_bottom).offset(2);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
