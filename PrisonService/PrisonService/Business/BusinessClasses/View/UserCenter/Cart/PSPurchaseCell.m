//
//  PSPurchaseCell.m
//  PrisonService
//
//  Created by calvin on 2018/5/8.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPurchaseCell.h"

@implementation PSPurchaseCell
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
    UIView *mainView = [UIView new];
    mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(15);
    }];
    CGFloat horSideSpace = 15;
    UIView *titleView = [UIView new];
    [mainView addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSideSpace);
        make.right.mas_equalTo(-horSideSpace);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    UIImageView *titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userCenterTitleIcon"]];
    [titleView addSubview:titleIconView];
    [titleIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(titleView.mas_centerY);
        make.size.mas_equalTo(titleIconView.frame.size);
    }];
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = FontOfSize(10);
    titleLabel.textColor = AppBaseTextColor1;
    NSString*Phone_CARDS=NSLocalizedString(@"Phone_CARDS", @"亲情电话卡");
    titleLabel.text = Phone_CARDS;
    [titleView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleIconView.mas_right).offset(10);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(100);
    }];
    _orderNOLabel = [UILabel new];
    _orderNOLabel.font = FontOfSize(10);
    _orderNOLabel.textColor = AppBaseTextColor1;
    _orderNOLabel.textAlignment = NSTextAlignmentRight;
    _orderNOLabel.numberOfLines = 0;
    [titleView addSubview:_orderNOLabel];
    [_orderNOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(0);
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    UIView *purchaseView = [UIView new];
    purchaseView.backgroundColor = UIColorFromHexadecimalRGB(0xF3F3F3);
    [mainView addSubview:purchaseView];
    [purchaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSideSpace);
        make.right.mas_equalTo(-horSideSpace);
        make.top.mas_equalTo(titleView.mas_bottom);
        make.height.mas_equalTo(85);
    }];
    CGFloat pHorSideSpace = 10;
    UIImageView *purchaseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userCenterPurchaseIcon"]];
    [purchaseView addSubview:purchaseImageView];
    [purchaseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pHorSideSpace);
        make.centerY.mas_equalTo(purchaseView.mas_centerY);
        make.size.mas_equalTo(purchaseImageView.frame.size);
    }];
    UILabel *purchaseTitleLabel = [UILabel new];
    purchaseTitleLabel.font = FontOfSize(12);
    purchaseTitleLabel.textColor = AppBaseTextColor1;
    purchaseTitleLabel.text = Phone_CARDS;
    [purchaseView addSubview:purchaseTitleLabel];
    [purchaseTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(purchaseImageView.mas_right).offset(15);
        make.top.mas_equalTo(purchaseImageView.mas_top);
        make.right.mas_equalTo(-pHorSideSpace);
        make.height.mas_equalTo(18);
    }];
    _paymentLabel = [UILabel new];
    _paymentLabel.font = FontOfSize(12);
    _paymentLabel.textColor = AppBaseTextColor2;
    [purchaseView addSubview:_paymentLabel];
    [_paymentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(purchaseTitleLabel.mas_left);
        make.top.mas_equalTo(purchaseTitleLabel.mas_bottom);
        make.right.mas_equalTo(-pHorSideSpace);
        make.height.mas_equalTo(18);
    }];
    _quantityLabel = [UILabel new];
    _quantityLabel.font = FontOfSize(10);
    _quantityLabel.textColor = AppBaseTextColor1;
    _quantityLabel.textAlignment = NSTextAlignmentRight;
    [purchaseView addSubview:_quantityLabel];
    [_quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(purchaseImageView.mas_bottom);
        make.right.mas_equalTo(-pHorSideSpace);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(16);
    }];
    _priceLabel = [UILabel new];
    _priceLabel.font = FontOfSize(12);
    _priceLabel.textColor = AppBaseTextColor1;
    [purchaseView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(purchaseTitleLabel.mas_left);
        make.bottom.mas_equalTo(purchaseImageView.mas_bottom);
        make.right.mas_equalTo(_quantityLabel.mas_left).offset(-10);
        make.height.mas_equalTo(16);
    }];
    _infoLabel = [UILabel new];
    _infoLabel.textAlignment = NSTextAlignmentRight;
    [mainView addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(mainView.mas_centerX);
        make.right.mas_equalTo(-horSideSpace);
        make.top.mas_equalTo(purchaseView.mas_bottom);
        make.height.mas_equalTo(30);
    }];
    _timeLabel = [UILabel new];
    _timeLabel.font = FontOfSize(10);
    _timeLabel.textColor = AppBaseTextColor1;
    [mainView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSideSpace);
        make.top.mas_equalTo(_infoLabel.mas_top);
        make.right.mas_equalTo(_infoLabel.mas_left);
        make.bottom.mas_equalTo(_infoLabel.mas_bottom);
    }];
    UIView *line = [UIView new];
    line.backgroundColor = AppBaseLineColor;
    [mainView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSideSpace);
        make.right.mas_equalTo(-horSideSpace);
        make.top.mas_equalTo(_infoLabel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    UIView *footerView = [UIView new];
    [mainView addSubview:footerView];
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSideSpace);
        make.right.mas_equalTo(-horSideSpace);
        make.top.mas_equalTo(line.mas_bottom);
        make.bottom.mas_equalTo(0);
    
    }];

    NSString *buyAgain = NSLocalizedString(@"buy again", @"再次购买");
    
    CGSize bSize = CGSizeMake(54, 22);
    _buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _buyButton.layer.cornerRadius = bSize.height / 2;
    _buyButton.layer.borderWidth = 1.0;
    _buyButton.layer.borderColor = AppBaseTextColor3.CGColor;
    _buyButton.titleLabel.font = FontOfSize(10);
    [_buyButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    [_buyButton setTitle:buyAgain forState:UIControlStateNormal];
    [footerView addSubview:_buyButton];
    [_buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(footerView.mas_centerY);
        make.size.mas_equalTo(bSize);
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
