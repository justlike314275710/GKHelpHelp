//
//  PSRegisterPrisonView.m
//  PrisonService
//
//  Created by calvin on 2018/4/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRegisterPrisonView.h"

@implementation PSRegisterPrisonView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    
    UIFont *textFont =  [NSObject judegeIsVietnamVersion]?FontOfSize(12):AppBaseTextFont2;
    UIColor *titleColor = AppBaseTextColor3;
    UIColor *commonColor = AppBaseTextColor2;
    UIColor *borderColor = AppBaseLineColor;
    CGFloat horSideSpace = 20;
    CGFloat verticalSpace = RELATIVE_HEIGHT_VALUE(25);
    CGFloat buttonHeight = 44;
    CGFloat buttonCornerRadius = buttonHeight / 2;
    CGFloat buttonBorderWidth = 1.0;
    CGFloat titleHeight = 15;
    CGFloat textLeftMargin = 15;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = textFont;
    titleLabel.textColor = titleColor;
    NSString*prison_select_jails=NSLocalizedString(@"prison_select_jails", @"■ 服刑人员所属监狱");
    titleLabel.text = prison_select_jails;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSideSpace);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(titleHeight);
        make.right.mas_equalTo(-horSideSpace);
    }];
    _proviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _proviceButton.layer.cornerRadius = buttonCornerRadius;
    _proviceButton.layer.borderWidth = buttonBorderWidth;
    _proviceButton.layer.borderColor = borderColor.CGColor;
    [_proviceButton setImage:[UIImage imageNamed:@"sessionSpreadIcon"] forState:UIControlStateNormal];
    _proviceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _proviceButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [self addSubview:_proviceButton];
    [_proviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(15);
        make.right.mas_equalTo(self.mas_centerX).offset(-5);
        make.height.mas_equalTo(buttonHeight);
    }];
    _proviceLabel = [UILabel new];
    _proviceLabel.textAlignment = NSTextAlignmentLeft;
    _proviceLabel.backgroundColor = [UIColor clearColor];
    _proviceLabel.font = textFont;
    _proviceLabel.textColor = commonColor;
    _prisonLabel.numberOfLines = 0;
    NSString*Select_province=NSLocalizedString(@"Select_province", @"请选择省");
    _proviceLabel.text = Select_province;
    [self addSubview:_proviceLabel];
    [_proviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_proviceButton.mas_left).offset(textLeftMargin);
        make.top.mas_equalTo(_proviceButton.mas_top);
        make.bottom.mas_equalTo(_proviceButton.mas_bottom);
        make.right.mas_equalTo(_proviceButton.mas_right).offset(-45);
    }];
    
    _cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cityButton.layer.cornerRadius = buttonCornerRadius;
    _cityButton.layer.borderWidth = buttonBorderWidth;
    _cityButton.layer.borderColor = borderColor.CGColor;
    [_cityButton setImage:[UIImage imageNamed:@"sessionSpreadIcon"] forState:UIControlStateNormal];
    _cityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _cityButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [self addSubview:_cityButton];
    [_cityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_centerX).offset(5);
        make.top.mas_equalTo(_proviceButton.mas_top);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(buttonHeight);
    }];
    _cityLabel = [UILabel new];
    _cityLabel.textAlignment = NSTextAlignmentLeft;
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.font = textFont;
    _cityLabel.textColor = commonColor;
    NSString*Select_city=NSLocalizedString(@"Select_city", @"请选择市");
    _cityLabel.text = Select_city;
    _cityLabel.numberOfLines = 0;
    [self addSubview:_cityLabel];
    [_cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_cityButton.mas_left).offset(textLeftMargin);
        make.top.mas_equalTo(_cityButton.mas_top);
        make.bottom.mas_equalTo(_cityButton.mas_bottom);
        make.right.mas_equalTo(_cityButton.mas_right).offset(-45);
    }];
    _prisonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _prisonButton.layer.cornerRadius = buttonCornerRadius;
    _prisonButton.layer.borderWidth = buttonBorderWidth;
    _prisonButton.layer.borderColor = borderColor.CGColor;
    [_prisonButton setImage:[UIImage imageNamed:@"sessionSpreadIcon"] forState:UIControlStateNormal];
    _prisonButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _prisonButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [self addSubview:_prisonButton];
    [_prisonButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_proviceButton.mas_left);
        make.top.mas_equalTo(_proviceButton.mas_bottom).offset(verticalSpace);
        make.right.mas_equalTo(_cityButton.mas_right);
        make.height.mas_equalTo(buttonHeight);
    }];
    _prisonLabel = [UILabel new];
    _prisonLabel.textAlignment = NSTextAlignmentLeft;
    _prisonLabel.backgroundColor = [UIColor clearColor];
    _prisonLabel.font = textFont;
    _prisonLabel.textColor = commonColor;
    NSString*Select_jails=NSLocalizedString(@"Select_jails", @"请选择监狱");
    _prisonLabel.text = Select_jails;
    [self addSubview:_prisonLabel];
    [_prisonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_prisonButton.mas_left).offset(textLeftMargin);
        make.top.mas_equalTo(_prisonButton.mas_top);
        make.bottom.mas_equalTo(_prisonButton.mas_bottom);
        make.right.mas_equalTo(_prisonButton.mas_right).offset(-45);
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
