//
//  PSUniversalLawCell.m
//  PrisonService
//
//  Created by kky on 2019/4/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSUniversalLawCell.h"
@interface PSUniversalLawCell ()
@property(nonatomic,strong) UIImageView *headIcon;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *e_titleLabel;
@property(nonatomic,strong) UIView *bgView;



@end

@implementation PSUniversalLawCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {

    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(140);
    }];
    
    [_bgView addSubview:self.headIcon];
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(_bgView).mas_equalTo(20);
        make.size.mas_equalTo(104);
    }];
    
    [_bgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headIcon).offset(-18);
        make.right.mas_equalTo(_bgView).offset(-30);
        make.height.mas_equalTo(21);
        make.width.mas_equalTo(64);
    }];
    
    UILabel *label = [UILabel new];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = UIColorFromRGB(51, 51, 51);
    label.text = @"—";
    label.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headIcon);
        make.right.mas_equalTo(_bgView).offset(-30);
        make.height.mas_equalTo(21);
        make.width.mas_equalTo(64);
    }];
    
    [self addSubview:self.e_titleLabel];
    [self.e_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headIcon).offset(18);
        make.right.mas_equalTo(_bgView).offset(-30);
        make.height.mas_equalTo(21);
        make.width.mas_equalTo(160);
    }];

}
- (void)setData:(NSDictionary *)data {
    _data = data;
    self.headIcon.image = IMAGE_NAMED(data[@"icon"]);
    self.titleLabel.text = data[@"titleChina"];
    self.e_titleLabel.text = data[@"titleEnglish"];
}

#pragma mark - Setting&Getting
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:33/255.0 blue:52/255.0 alpha:0.08].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0,0);
        _bgView.layer.shadowOpacity = 1;
        _bgView.layer.shadowRadius = 4;
    }
    return _bgView;
}

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [UIImageView new];
    }
    return _headIcon;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel.textColor = UIColorFromRGB(51, 51, 51);
        _titleLabel.numberOfLines = 3;
        _titleLabel.text = @"法律服务";
    }
    return _titleLabel;
}

- (UILabel *)e_titleLabel {
    if (!_e_titleLabel) {
        _e_titleLabel = [UILabel new];
        _e_titleLabel.font = FontOfSize(15);
        _e_titleLabel.textAlignment = NSTextAlignmentRight;
        _e_titleLabel.textColor = UIColorFromRGB(51, 51, 51);
        _e_titleLabel.numberOfLines = 3;
        _e_titleLabel.text = @"Legal service";
    }
    return _e_titleLabel;
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
