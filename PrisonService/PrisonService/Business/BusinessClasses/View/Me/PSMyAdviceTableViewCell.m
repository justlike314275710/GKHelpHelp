//
//  PSMyAdviceTableViewCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/11/1.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMyAdviceTableViewCell.h"

@implementation PSMyAdviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
    CGFloat sidePidding=16.0f;
    UIView *bgview = [[UIView alloc] init];
    bgview.frame = CGRectMake(20,0,SCREEN_WIDTH-40,123);
    bgview.layer.masksToBounds = YES;
    bgview.backgroundColor = [UIColor whiteColor];
    bgview.layer.shadowColor = [UIColor colorWithRed:14/255.0 green:39/255.0 blue:85/255.0 alpha:0.28].CGColor;
    bgview.layer.shadowOffset = CGSizeMake(0,1);
    bgview.layer.shadowOpacity = 1;
    bgview.layer.shadowRadius = 3;
    bgview.layer.cornerRadius = 5;
    [self addSubview:bgview];
    
     _headImg = [UIImageView new];
    [bgview addSubview:self.headImg];
    [self.headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePidding);
        make.top.mas_equalTo(sidePidding);
        make.width.height.mas_equalTo(42);
    }];
     _headImg.image = [UIImage imageNamed:@"头像"];
    
    _nameLab=[UILabel new];
    [bgview addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImg.mas_right).offset(10);
        make.top.mas_equalTo(sidePidding);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    self.nameLab.text=@"李凤";
    _nameLab.font=FontOfSize(12);
    
    
    _statusButton=[UIButton new];
    [bgview addSubview:_statusButton];
    [_statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-sidePidding);
        make.top.mas_equalTo(sidePidding);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
    }];
    _statusButton.titleLabel.font=FontOfSize(12);
    [_statusButton setTitleColor:AppBaseTextColor3 forState:0];
    
    _moneyLab=[UILabel new];
    [bgview addSubview:self.moneyLab];
    [self.moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImg.mas_right).offset(10);
        make.top.mas_equalTo(self.nameLab.mas_bottom);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    _moneyLab.text=@"¥34.00";
    _moneyLab.textColor=UIColorFromRGB(243, 72, 0);
    _moneyLab.font=FontOfSize(10);
    
    _timeLab=[UILabel new];
    [bgview addSubview:self.timeLab];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-sidePidding);
        make.top.mas_equalTo(self.nameLab.mas_bottom);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(20);
    }];
    _timeLab.text=@"20018-08-03 12:13";
    _timeLab.textColor=AppBaseTextColor1;
    _timeLab.font=FontOfSize(10);
    _timeLab.textAlignment=NSTextAlignmentRight;
    
    UIView*line_view=[UIView new];
    [bgview addSubview:line_view];
    [line_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_headImg.mas_bottom).mas_equalTo(5);
        make.right.mas_equalTo(-sidePidding);
        make.left.mas_equalTo(sidePidding);
        make.height.mas_equalTo(1);
    }];
    line_view.backgroundColor=AppBaseLineColor;
    
    _contentLab=[UILabel new];
    [bgview addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line_view.mas_bottom).mas_equalTo(5);
        make.right.mas_equalTo(-sidePidding);
        make.left.mas_equalTo(sidePidding);
        make.height.mas_equalTo(40);
    }];
    _contentLab.numberOfLines=0;
   // _contentLab.text=@"我想咨询个人隐私问题，我对象通过他在派出所的朋友关 系私自调出我的微信消费记录聊天记录，侵犯我的权利...";
    _contentLab.font=FontOfSize(12);
    
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
