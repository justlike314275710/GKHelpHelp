//
//  PSArticleReportCell.m
//  PrisonService
//
//  Created by kky on 2019/10/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleReportCell.h"

@implementation PSArticleReportCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = UIColorFromRGB(249,248,254);
//        self.contentView.backgroundColor = UIColorFromRGB(249,248,254);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    [self addSubview:self.reasonLab];
    [self.reasonLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.left.mas_equalTo(15);
        make.width.mas_equalTo(250);
    }];
    
    [self addSubview:self.lineImg];
    [self.lineImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-2);
        make.right.mas_equalTo(2);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self addSubview:self.seletedBtn];
    [self.seletedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(-15);
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

#pragma mark ---------- setting&&getting
-(UILabel *)reasonLab{
    if (!_reasonLab) {
        _reasonLab = [[UILabel alloc] init];
        _reasonLab.text = @"";
        _reasonLab.textAlignment = NSTextAlignmentLeft;
        _reasonLab.textColor = UIColorFromRGB(51, 51, 51);
        _reasonLab.font = FontOfSize(12);
    }
    return _reasonLab;
}
-(UIButton *)seletedBtn{
    if(_seletedBtn==nil){
        _seletedBtn = [[UIButton alloc] init];
        [_seletedBtn setImage:IMAGE_NAMED(@"未勾选") forState:UIControlStateNormal];
        [_seletedBtn setImage:IMAGE_NAMED(@"已勾选") forState:UIControlStateSelected];
        _seletedBtn.userInteractionEnabled = NO;
    }
    return _seletedBtn;
}

-(UIImageView *)lineImg{
    if(_lineImg==nil){
        _lineImg = [[UIImageView alloc] init];
        _lineImg.image = IMAGE_NAMED(@"分割线");
    }
    return _lineImg;
}

@end
