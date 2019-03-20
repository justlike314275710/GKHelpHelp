//
//  PSLegalServiceTableViewCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/18.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLegalServiceTableViewCell.h"

@implementation PSLegalServiceTableViewCell

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
    CGFloat horSidePadding = 15;
    CGFloat verSidePadding = 15;
    UIView *mainView = [UIView new];
    [self addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UIView*lineView=[UIView new];
    lineView.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
    [mainView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(15);
    }];
    
    CGFloat qWidth = 100;
    CGFloat qHeight = 15;
    _legalServiceLable = [UILabel new];
   _legalServiceLable.font = FontOfSize(12);
    _legalServiceLable.textAlignment = NSTextAlignmentLeft;
    _legalServiceLable.textColor =[UIColor blackColor];
    NSString*legal_service=NSLocalizedString(@"legal_service", @"法律服务");
    _legalServiceLable.text=legal_service;
    [mainView addSubview: _legalServiceLable];
    [ _legalServiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(2*verSidePadding);
        make.width.mas_equalTo(qWidth);
        make.height.mas_equalTo(qHeight);
    }];
    
    _moreButton=[[UIButton alloc]init];
    [mainView addSubview:_moreButton];
    NSString*more=NSLocalizedString(@"more", @"更多");
    [_moreButton setTitle:more forState:0];
    _moreButton.contentHorizontalAlignment=
    UIControlContentHorizontalAlignmentRight;
    [_moreButton setTitleColor:AppBaseTextColor3 forState:0];
    _moreButton.titleLabel.font=FontOfSize(12);
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-horSidePadding);
        make.top.mas_equalTo(2*verSidePadding);
        make.width.mas_equalTo(qWidth);
        make.height.mas_equalTo(qHeight);
    }];
    
    
    _FinanceButton=[[UIButton alloc]init];
//    [_FinanceButton setImage: forState:0];
    [_FinanceButton setBackgroundImage:[UIImage imageNamed:@"财务纠纷背景图"] forState:0];
    [mainView addSubview:_FinanceButton];
    [_FinanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo
        (_legalServiceLable.mas_bottom).offset(horSidePadding);
        make.width.mas_equalTo(SCREEN_WIDTH/2-1.5*horSidePadding);
        make.height.mas_equalTo(80);
    }];
    
    UILabel*FinanceLable=[UILabel new];
    NSString*financial_embroilment=NSLocalizedString(@"financial_embroilment", @"财务纠纷");
    FinanceLable.text=financial_embroilment;
    [_FinanceButton addSubview:FinanceLable];
    [FinanceLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    FinanceLable.textColor=[UIColor whiteColor];
    [FinanceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(25);
    }];
    FinanceLable.numberOfLines=0;
    
    UILabel*FinanceTitleLable=[UILabel new];
    NSString*legitimate_interests=NSLocalizedString(@"legitimate_interests", @"最大化维护您的合法权益");
    FinanceTitleLable.text=legitimate_interests;
    [_FinanceButton addSubview:FinanceTitleLable];
    [FinanceTitleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
    FinanceTitleLable.textColor=[UIColor whiteColor];
    [FinanceTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(44);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(25);
    }];
    FinanceTitleLable.numberOfLines=0;
   
    
    _MarriageButton=[[UIButton alloc]init];
//    [_MarriageButton setImage:[UIImage imageNamed:@"婚姻家庭背景图"] forState:0];
    [_MarriageButton setBackgroundImage:[UIImage imageNamed:@"婚姻家庭背景图"] forState:0];
    [mainView addSubview:_MarriageButton];
    [_MarriageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo
        (_FinanceButton.mas_right).offset(horSidePadding);
        make.top.mas_equalTo
        (_legalServiceLable.mas_bottom).offset(horSidePadding);
        make.width.mas_equalTo(SCREEN_WIDTH/2-1.5*horSidePadding);
        make.height.mas_equalTo(80);
    }];
    
    UILabel*MarriageLable=[UILabel new];
    NSString*marriage_family=NSLocalizedString(@"marriage_family", @"婚姻家庭");
    MarriageLable.text=marriage_family;
    [_MarriageButton addSubview:MarriageLable];
    [MarriageLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    MarriageLable.textColor=[UIColor whiteColor];
    [MarriageLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(25);
    }];
    MarriageLable.numberOfLines=0;
    
    UILabel*MarriageTitleLable=[UILabel new];
    NSString*law_protect=NSLocalizedString(@"law_protect", @"让法律守护你我他");
    MarriageTitleLable.text=law_protect;
    [_MarriageButton addSubview:MarriageTitleLable];
    [MarriageTitleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
    MarriageTitleLable.textColor=[UIColor whiteColor];
    [MarriageTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(44);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(25);
    }];
    MarriageTitleLable.numberOfLines=0;
    
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}

@end
