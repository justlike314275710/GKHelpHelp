//
//  PSAppointmentInfoCell.m
//  PrisonService
//
//  Created by calvin on 2018/4/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAppointmentDetailCell.h"
#import "NSArray+MASAdditions.h"
#import "AccountsViewModel.h"
#import "PSSessionManager.h"
@implementation PSAppointmentDetailCell
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
    NSString*family_appointment=NSLocalizedString(@"family_appointment", @"亲情预约");
    titleLabel.text = family_appointment;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_right).offset(10);
        make.top.mas_equalTo(headerView.mas_top);
        make.bottom.mas_equalTo(headerView.mas_bottom);
        make.right.mas_equalTo(-horSpace);
    }];
    _buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buyButton setImage:[UIImage imageNamed:@"appointmentBuyIcon"] forState:UIControlStateNormal];
    [self addSubview:_buyButton];
    [_buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.width.mas_equalTo(60);
    }];
    UIView *infoView = [UIView new];
    infoView.backgroundColor = [UIColor clearColor];
    [self addSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_left);
        make.right.mas_equalTo(_buyButton.mas_left);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(21);
        make.bottom.mas_equalTo(-verSpace);
    }];
    UIFont *textFont1 = FontOfSize(14);
    UIColor *textColor1 = UIColorFromHexadecimalRGB(0x333333);
    UIFont *textFont2 = FontOfSize(12);
    UIColor *textColor2 = AppBaseTextColor2;
    _balanceLabel = [UILabel new];
    _balanceLabel.font = textFont1;
    _balanceLabel.textAlignment = NSTextAlignmentCenter;
    _balanceLabel.textColor = textColor1;
    _balanceLabel.text = @"¥0";
    
    [infoView addSubview:_balanceLabel];
    [_balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(15);
    }];
    _timesLabel = [UILabel new];
    _timesLabel.font = textFont1;
    _timesLabel.textAlignment = NSTextAlignmentCenter;
    _timesLabel.textColor = textColor1;
    NSMutableAttributedString *timesString = [NSMutableAttributedString new];
    [timesString appendAttributedString:[[NSAttributedString alloc] initWithString:@"0" attributes:@{NSFontAttributeName:textFont1,NSForegroundColorAttributeName:textColor1}]];
    NSString*one=NSLocalizedString(@"one", @"次");
    [timesString appendAttributedString:[[NSAttributedString alloc] initWithString:one attributes:@{NSFontAttributeName:FontOfSize(10),NSForegroundColorAttributeName:textColor2}]];
    _timesLabel.attributedText = timesString;
    [infoView addSubview:_timesLabel];
    [_timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_balanceLabel.mas_top);
        make.height.mas_equalTo(_balanceLabel.mas_height);
    }];
    [@[_balanceLabel,_timesLabel] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    UILabel *balanceTxtLabel = [UILabel new];
    balanceTxtLabel.textAlignment = NSTextAlignmentCenter;
    balanceTxtLabel.font = textFont2;
    balanceTxtLabel.textColor = textColor2;
    balanceTxtLabel.numberOfLines=0;
    NSString*Phone_card_balance=NSLocalizedString(@"Phone_card_balance", @"%@电话卡余额");
//    balanceTxtLabel.text =[NSString stringWithFormat:Phone_card_balance,prisonerDetail.name];
    balanceTxtLabel.text = @"监狱余额";
    [infoView addSubview:balanceTxtLabel];
    [balanceTxtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_balanceLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(30);
    }];
    UILabel *timesTextLabel = [UILabel new];
    timesTextLabel.textAlignment = NSTextAlignmentCenter;
    timesTextLabel.font = textFont2;
    timesTextLabel.textColor = textColor2;
    timesTextLabel.numberOfLines=0;
    NSString*month_Times=NSLocalizedString(@"month_Times", @"本月待会见");
    timesTextLabel.text = month_Times;
    [infoView addSubview:timesTextLabel];
    [timesTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(balanceTxtLabel.mas_top);
        make.height.mas_equalTo(balanceTxtLabel.mas_height);
        //make.height.mas_equalTo(30);
    }];
    [@[balanceTxtLabel,timesTextLabel] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
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
