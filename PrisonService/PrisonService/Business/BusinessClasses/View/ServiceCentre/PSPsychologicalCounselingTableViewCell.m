//
//  PSPsychologicalCounselingTableViewCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/18.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPsychologicalCounselingTableViewCell.h"

@implementation PSPsychologicalCounselingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

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

-(void)renderContents{
    UIView* bgView = [UIView new];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UIView*lineView=[UIView new];
    lineView.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);;
    [bgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(15);
    }];

    UIImageView *bgImageView = [UIImageView new];
    bgImageView.image = [[UIImage imageNamed:@"心理咨询底"] stretchImage];
    [bgView addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.edges.mas_equalTo(UIEdgeInsetsZero);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(lineView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(70);
    }];
    
    CGFloat horSidePadding = 15;
    CGFloat qWidth = 100;
    CGFloat qHeight = 15;
    
    UILabel* psychologicalLable = [UILabel new];
    psychologicalLable.font = boldFontOfSize(15);
    psychologicalLable.textAlignment = NSTextAlignmentLeft;
    psychologicalLable.textColor =[UIColor blackColor];
    NSString*psychological_counseling=
    NSLocalizedString(@"psychological_counseling", @"心理咨询");
    psychologicalLable.text=psychological_counseling;
    [bgView addSubview: psychologicalLable];
    [ psychologicalLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2*horSidePadding);
        make.top.mas_equalTo(2*horSidePadding);
        make.width.mas_equalTo(qWidth);
        make.height.mas_equalTo(qHeight);
    }];
    
    UILabel* psychologicalTitleLable = [UILabel new];
    psychologicalTitleLable.font = FontOfSize(12);
    psychologicalTitleLable.textAlignment = NSTextAlignmentLeft;
    psychologicalTitleLable.textColor =AppBaseTextColor1;
    NSString*service_guarantee=NSLocalizedString(@"service_guarantee", @"优质服务,咨询保证");
    psychologicalTitleLable.text=service_guarantee;
    [bgView addSubview: psychologicalTitleLable];
    [ psychologicalTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2*horSidePadding);
        make.top.mas_equalTo(psychologicalLable.mas_bottom)
        .offset(horSidePadding-5);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(qHeight);
    }];
    
    
    _goButton=[[UIButton alloc]init];
    [_goButton setImage:[UIImage imageNamed:@"进入"] forState:0];
    [bgView addSubview:_goButton];
    [_goButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-2*horSidePadding);
        make.centerY.mas_equalTo(bgView.mas_centerY);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    
    
//    UIView*lineBgView=[UIView new];
//    lineBgView.backgroundColor=UIColorFromRGBA(234, 234, 234, 0.6);
//    [bgView addSubview:lineBgView];
//    [lineBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.top.mas_equalTo(bgImageView.mas_bottom);
//        make.width.mas_equalTo(SCREEN_WIDTH);
//        make.height.mas_equalTo(15);
//    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
