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
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self renderContents];
    }
    return self;
}


- (void)renderContents {
    CGFloat horSidePadding = 15;
    CGFloat verSidePadding = 15;
    UIImageView *mainView = [UIImageView new];
    mainView.image = IMAGE_NAMED(@"法律服务底");
    mainView.userInteractionEnabled = YES;
    [self addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(4);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-4);
        make.bottom.mas_equalTo(0);
    }];
    
    CGFloat qWidth = 100;
    CGFloat qHeight = 15;
    _legalServiceLable = [UILabel new];
    _legalServiceLable.font = boldFontOfSize(15);
    _legalServiceLable.textAlignment = NSTextAlignmentLeft;
    _legalServiceLable.textColor =[UIColor blackColor];
    NSString*legal_service=NSLocalizedString(@"legal_service", @"法律服务");
    _legalServiceLable.text=legal_service;
    [mainView addSubview: _legalServiceLable];
    [ _legalServiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2*horSidePadding);
        make.top.mas_equalTo(verSidePadding+8);
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
    _moreButton.titleLabel.font=FontOfSize(14);
    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-2*horSidePadding);
        make.top.mas_equalTo(verSidePadding+8);
        make.width.mas_equalTo(qWidth);
        make.height.mas_equalTo(qHeight);
    }];
    
    UIView*lineView=[UIView new];
    lineView.backgroundColor=UIColorFromRGBA(217,217,217,1);
    [mainView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(_moreButton.mas_bottom).offset(10);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(1);
    }];
    
    //财产纠纷
    UIView *dotView1 = [[UIView alloc] init];
    ViewBorderRadius(dotView1,4.5,1,UIColorFromRGB(255, 134, 0));
    [mainView addSubview:dotView1];
    [dotView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lineView);
        make.width.height.mas_equalTo(9);
        make.top.mas_equalTo(lineView.mas_bottom).offset(15);
    }];
    
    UILabel*FinanceTitleLable=[UILabel new];
//    NSString*legitimate_interests=NSLocalizedString(@"legitimate_interests", @"最大化维护您的合法权益");
    NSString*legitimate_interests= @"最大化维护您\n的合法权益";
    FinanceTitleLable.text=legitimate_interests;
    FinanceTitleLable.font = FontOfSize(12);
    FinanceTitleLable.textColor=UIColorFromRGB(51,51,51);
    [mainView addSubview:FinanceTitleLable];
    [FinanceTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dotView1);
        make.top.mas_equalTo(dotView1.mas_bottom).offset(7);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    FinanceTitleLable.numberOfLines=0;
    
    _FinanceButton=[[UIButton alloc]init];
    _FinanceButton.backgroundColor = UIColorFromRGB(204,237,255);
    ViewRadius(_FinanceButton,5);
    [mainView addSubview:_FinanceButton];
    [_FinanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-2*horSidePadding);
        make.top.mas_equalTo(lineView.mas_bottom).offset(horSidePadding-3);
        make.width.mas_equalTo(SCREEN_WIDTH/2-2*horSidePadding);
        make.height.mas_equalTo(60);
    }];
    
    UILabel*FinanceLable=[UILabel new];
    NSString*financial_embroilment=NSLocalizedString(@"financial_embroilment", @"财产纠纷");
    FinanceLable.text=financial_embroilment;
    FinanceLable.textAlignment = NSTextAlignmentLeft;
    [_FinanceButton addSubview:FinanceLable];
    FinanceLable.font = [UIFont boldSystemFontOfSize:14];
    FinanceLable.textColor=UIColorFromRGB(51,51,51);
    [FinanceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(17);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    UIView *financeIconView = [UIView new];
    financeIconView.backgroundColor = UIColorFromRGB(0, 107, 255);
    ViewRadius(financeIconView,1.5);
    [_FinanceButton addSubview:financeIconView];
    [financeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(FinanceLable);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(3);
        make.top.mas_equalTo(FinanceLable.mas_bottom).offset(6);
    }];
    
    UIImageView *icomImg = [UIImageView new];
    icomImg.image = IMAGE_NAMED(@"财产纠纷icon");
    [_FinanceButton addSubview:icomImg];
    [icomImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(40);
        make.top.mas_equalTo(10);
    }];
    
    //婚姻家庭
    UIView *dotView2 = [[UIView alloc] init];
    ViewBorderRadius(dotView2,4.5,1,UIColorFromRGB(255, 134, 0));
    [mainView addSubview:dotView2];
    [dotView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lineView);
        make.width.height.mas_equalTo(9);
        make.top.mas_equalTo(lineView.mas_bottom).offset(69+15);
    }];
    
    UILabel*MarriageTitleLable=[UILabel new];
    //    NSString*legitimate_interests=NSLocalizedString(@"legitimate_interests", @"最大化维护您的合法权益");
    NSString*law_protect= @"让法律守护你\n我他";
    MarriageTitleLable.text=law_protect;
    MarriageTitleLable.font = FontOfSize(12);
    MarriageTitleLable.textColor=UIColorFromRGB(51,51,51);
    [mainView addSubview:MarriageTitleLable];
    [MarriageTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dotView1);
        make.top.mas_equalTo(dotView1.mas_bottom).offset(7+69);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    MarriageTitleLable.numberOfLines=0;
    
    _MarriageButton=[[UIButton alloc]init];
    _MarriageButton.backgroundColor = UIColorFromRGB(255,242,205);
    ViewRadius(_MarriageButton,5);
    [mainView addSubview:_MarriageButton];
    [_MarriageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-2*horSidePadding);
        make.top.mas_equalTo(lineView.mas_bottom).offset(horSidePadding-3+69);
        make.width.mas_equalTo(SCREEN_WIDTH/2-2*horSidePadding);
        make.height.mas_equalTo(60);
    }];
    
    UILabel*MarriageLable=[UILabel new];
    NSString*marriage_family=NSLocalizedString(@"marriage_family", @"婚姻家庭");
    MarriageLable.text=marriage_family;
    MarriageLable.textAlignment = NSTextAlignmentLeft;
    [_MarriageButton addSubview:MarriageLable];
    MarriageLable.font = [UIFont boldSystemFontOfSize:14];
    MarriageLable.textColor=UIColorFromRGB(51,51,51);
    [MarriageLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(17);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    UIView *marriageIconView = [UIView new];
    marriageIconView.backgroundColor = UIColorFromRGB(255,134,0);
    ViewRadius(marriageIconView,1.5);
    [_MarriageButton addSubview:marriageIconView];
    [marriageIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(MarriageLable);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(3);
        make.top.mas_equalTo(MarriageLable.mas_bottom).offset(6);
    }];
    
    UIImageView *micomImg = [UIImageView new];
    micomImg.image = IMAGE_NAMED(@"婚姻家庭icon");
    [_MarriageButton addSubview:micomImg];
    [micomImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(40);
        make.top.mas_equalTo(10);
    }];
    
    
    /*
    
    _FinanceButton=[[UIButton alloc]init];
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
    NSString*financial_embroilment=NSLocalizedString(@"financial_embroilment", @"财产纠纷");
    FinanceLable.text=financial_embroilment;
    [_FinanceButton addSubview:FinanceLable];
    [FinanceLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    FinanceLable.textColor=[UIColor whiteColor];
    [FinanceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(25);
    }];
    FinanceLable.numberOfLines=0;
    
   
    
    _MarriageButton=[[UIButton alloc]init];
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
    [MarriageLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
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
    [MarriageTitleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11]];
    MarriageTitleLable.textColor=[UIColor whiteColor];
    [MarriageTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(44);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(25);
    }];
    MarriageTitleLable.numberOfLines=0;
    */
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}

@end
