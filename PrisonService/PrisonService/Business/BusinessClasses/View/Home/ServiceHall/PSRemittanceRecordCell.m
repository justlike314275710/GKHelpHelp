//
//  PSRemittanceRecordCell.m
//  PrisonService
//
//  Created by kky on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRemittanceRecordCell.h"

@implementation PSRemittanceRecordCell

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

- (void)setModel:(RemittanceRecode *)model {
    
    self.amountLab.text = [NSString stringWithFormat:@"¥%@",model.money];
    NSString *stateText = @"";
    if ([model.status isEqualToString:@"0"]) {
        stateText = NSLocalizedString(@"payment_in", @"支付中");
        self.payStateLab.textColor = UIColorFromRGB(0, 43, 113);
    } else if([model.status isEqualToString:@"1"]) {
        stateText = NSLocalizedString(@"payment_success", @"支付成功");
        self.payStateLab.textColor = UIColorFromRGB(42,138,0);
    } else {
        self.payStateLab.textColor = UIColorFromRGB(189,8,8);
        stateText = NSLocalizedString(@"payment_failure", @"支付失败");
    }
    self.payStateLab.text = stateText;
    self.nameLab.text = model.prisonerName;
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[model.createdAt doubleValue]/1000];
    NSString *time =  [formater stringFromDate:date];
    self.timeLab.text = time;
    NSString *k_numberText = NSLocalizedString(@"remittance_number", @"汇款单号");
    self.numbersLab.text = [NSString stringWithFormat:@"%@:%@",k_numberText,model.remitNum];
}

- (void)renderContents {

    [self addSubview:self.amountLab];
    [self.amountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.payStateLab];
    [self.payStateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.amountLab.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.amountLab);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.timeLab];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.nameLab.mas_bottom).offset(1);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.numbersLab];
    [self.numbersLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.timeLab.mas_bottom).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
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

#pragma mark - Setting&Getting
- (UILabel *)amountLab {
    if (!_amountLab) {
        _amountLab = [UILabel new];
        _amountLab.font = FontOfSize(24);
        _amountLab.textColor = UIColorFromRGB(102, 102, 102);
        _amountLab.text = @"¥300";
        _amountLab.textAlignment = NSTextAlignmentLeft;
    }
    return _amountLab;
}

- (UILabel *)payStateLab {
    if (!_payStateLab) {
        _payStateLab = [UILabel new];
        _payStateLab.font = FontOfSize(11);
        _payStateLab.textColor = UIColorFromRGB(0,43,113);
        _payStateLab.textAlignment = NSTextAlignmentLeft;
        _payStateLab.text = @"支付成功";
    }
    return _payStateLab;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [UILabel new];
        _nameLab.font = FontOfSize(14);
        _nameLab.textColor = UIColorFromRGB(51,51,51);
        _nameLab.textAlignment = NSTextAlignmentRight;
        _nameLab.text = @"王二";
    }
    return _nameLab;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [UILabel new];
        _timeLab.font = FontOfSize(11);
        _timeLab.textColor = UIColorFromRGB(153,153,153);
        _timeLab.textAlignment = NSTextAlignmentRight;
        _timeLab.text = @"2018-10-12 16:15";
    }
    return _timeLab;
}

- (UILabel *)numbersLab {
    if (!_numbersLab) {
        _numbersLab = [UILabel new];
        _numbersLab.font = FontOfSize(11);
        _numbersLab.textColor = UIColorFromRGB(153,153,153);
        _numbersLab.textAlignment = NSTextAlignmentRight;
        _numbersLab.numberOfLines = 0;
        _numbersLab.text = @"汇款单号:4589876272356";
    }
    return _numbersLab;
}



@end
