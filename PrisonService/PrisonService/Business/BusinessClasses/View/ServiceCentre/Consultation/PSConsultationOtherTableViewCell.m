//
//  PSConsultationOtherTableViewCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSConsultationOtherTableViewCell.h"

@implementation PSConsultationOtherTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.image = [[UIImage imageNamed:@"serviceHallServiceBg"] stretchImage];
        [self addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(0);
        }];
        CGFloat sidePidding=15.0f;
        UIButton*consulationButton=[[UIButton alloc]initWithFrame:CGRectMake(sidePidding, sidePidding, 100, 20)];
        [consulationButton setImage:[UIImage imageNamed:@"咨询费用"]forState:0];
        [consulationButton setTitle:@"咨询费用" forState:0 ];
        consulationButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [consulationButton setTitleColor:[UIColor blackColor] forState:0];
        consulationButton.titleLabel.font=FontOfSize(12);
        [bgImageView addSubview:consulationButton];
        
        UILabel*consulationLable=[[UILabel alloc]initWithFrame:CGRectMake(47, 50, SCREEN_WIDTH-100, 12)];
        consulationLable.textColor=AppBaseTextColor1;
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"咨询费用越多，回复效率与质量越高"];
        NSRange range1=[[str  string]rangeOfString:@"效率"];
        [str  addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(255, 138, 7, 1) range:range1];
        NSRange range2=[[str string]rangeOfString:@"质量"];
        [str  addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(255, 138, 7, 1) range:range2];
        //[str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(255, 138, 7, 1) range:NSMakeRange(10,5)];
        consulationLable.attributedText = str;
        consulationLable.font=FontOfSize(10);
        [bgImageView addSubview:consulationLable];
        bgImageView.userInteractionEnabled=YES;
        
        UILabel*moneyLable=[[UILabel alloc]initWithFrame:CGRectMake(sidePidding, 90, 60, 20)];
        moneyLable.font=FontOfSize(12);
        moneyLable.text=@"输入金额:";
        [bgImageView addSubview:moneyLable];
        
        _moneyTextField=[[UITextField alloc]initWithFrame:CGRectMake(80, 86, SCREEN_WIDTH-130, 35)];
        _moneyTextField.borderStyle= UITextBorderStyleRoundedRect;
        _moneyTextField.layer.borderWidth=1.0f;
        _moneyTextField.layer.borderColor=AppBaseLineColor.CGColor;
        _moneyTextField.layer.cornerRadius=4.0f;
        _moneyTextField.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
        _moneyTextField.placeholder=@"20";
        [bgImageView addSubview:_moneyTextField];
        
        UILabel*tipsLable=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-140, 125, 100, 12)];
        tipsLable.textColor=AppBaseTextColor1;
        NSMutableAttributedString *tipsStr = [[NSMutableAttributedString alloc] initWithString:@"最低金额不低于20元"];
        NSRange range3=[[tipsStr  string]rangeOfString:@"20元"];
        [tipsStr  addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(255, 138, 7, 1) range:range3];
        tipsLable.attributedText = tipsStr;
        tipsLable.font=FontOfSize(10);
        [bgImageView addSubview:tipsLable];
        
    }
    return self;
}


@end
