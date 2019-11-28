//
//  PSMessageCell.m
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMessageCell.h"

#define DefaultLabelHeight 26
#define VerSidePadding 6

@implementation PSMessageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        CGFloat sidePadding = 15;
        CGFloat verPadding = VerSidePadding;
        CGFloat labelHeight = DefaultLabelHeight;
        
//        _iconImageView = [UIImageView new];
//        _iconImageView.image = IMAGE_NAMED(@"探视消息列表icon");
//        [self.contentView addSubview:_iconImageView];
//        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(sidePadding);
//            make.width.height.mas_equalTo(34);
//            make.top.mas_equalTo(10);
//        }];
        
        _dateLabel = [UILabel new];
        _dateLabel.font = FontOfSize(10);
        _dateLabel.textColor = UIColorFromRGB(153, 153, 153);
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_dateLabel];
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-sidePadding);
            make.width.mas_equalTo(200);
            make.top.mas_equalTo(verPadding);
            make.height.mas_equalTo(labelHeight);
        }];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = FontOfSize(14);
        _titleLabel.textColor = UIColorFromRGB(51, 51, 51);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(_iconImageView.mas_right).offset(10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(_dateLabel.mas_left).offset(20);
            make.top.mas_equalTo(_dateLabel.mas_top);
            make.bottom.mas_equalTo(_dateLabel.mas_bottom);
        }];
        
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = FontOfSize(11);
        _contentLabel.textColor = UIColorFromRGB(102, 102, 102);
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(_iconImageView.mas_right).offset(10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-sidePadding);
            make.bottom.mas_equalTo(-verPadding);
            make.top.mas_equalTo(_dateLabel.mas_bottom).offset(verPadding);
        }];
    }
    return self;
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
