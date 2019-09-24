//
//  PSPlatformArticleCell.m
//  PrisonService
//
//  Created by kky on 2019/8/2.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPlatformArticleCell.h"
#import "PSAccountViewModel.h"
#import "UIButton+BEEnLargeEdge.h"

@interface PSPlatformArticleCell()
@property(nonatomic,strong)UIView *bgView;
@end

@implementation PSPlatformArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColorFromRGB(249,248,254);
        self.contentView.backgroundColor = UIColorFromRGB(249,248,254);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(161);
        make.top.mas_equalTo(5);
    }];
    
    [self.bgView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(40);
    }];
    
    [self.bgView addSubview:self.headImg];
    ViewRadius(_headImg,12);
    [self.headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLab);
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(3);
        make.width.height.mas_equalTo(24);
    }];
    
    [_bgView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImg.mas_right).offset(10);
        make.height.mas_equalTo(21);
        make.width.mas_equalTo(75);
        make.centerY.mas_equalTo(self.headImg);
    }];
    
    [_bgView addSubview:self.stateImageView];
    [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_nameLab.mas_right).offset(5);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(50);
        make.centerY.mas_equalTo(self.headImg);
    }];
    
    
    [_bgView addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(_titleLab);
        make.top.mas_equalTo(_headImg.mas_bottom).offset(5);
        make.height.mas_equalTo(45);
    }];
    
    [_bgView addSubview:self.timeIconImg];
    [self.timeIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentLab);
        make.bottom.mas_equalTo(-13);
        make.width.height.mas_equalTo(10);
    }];
    
    [_bgView addSubview:self.likeBtn];
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.timeIconImg);
        make.width.height.mas_equalTo(10);
        make.centerX.mas_equalTo(_bgView.mas_centerX);
    }];

    [_bgView addSubview:self.timeLab];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeIconImg.mas_right).offset(5);
        make.centerY.height.mas_equalTo(self.timeIconImg);
        make.right.mas_equalTo(self.likeBtn.mas_left).offset(5);
    }];
    
    [_bgView addSubview:self.likeLab];
    [self.likeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_likeBtn.mas_right).offset(4);
        make.centerY.mas_equalTo(_likeBtn);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(50);
        
    }];
    
    [_bgView addSubview:self.hotIconImg];
    [self.hotIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_likeLab.mas_right).offset(10);
        make.centerY.mas_equalTo(_likeBtn);
        make.height.mas_equalTo(9);
        make.width.mas_equalTo(10);
    }];
    [_bgView addSubview:self.hotLab];
    [self.hotLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_hotIconImg.mas_right).offset(4);
        make.centerY.mas_equalTo(_hotIconImg);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(60);
        
    }];
}
//
- (void)setModel:(PSArticleDetailModel *)model {
    _model = model;
    _titleLab.text = model.title;
    _contentLab.text = model.content;
    _nameLab.text = model.penName;
    _hotLab.text = model.clientNum;
    _likeLab.text = model.praiseNum;
    //是否能点赞
    if ([_model.ispraise isEqualToString:@"0"]) {
        [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
    } else {
        [_likeBtn setImage:IMAGE_NAMED(@"已赞") forState:UIControlStateNormal];
    }
    
    //用户头像
    PSAccountViewModel *viewModel = [[PSAccountViewModel alloc] init];
    [viewModel getAvatarImageUserName:model.username Completed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _headImg.image = image;
        });
    } failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _headImg.image = IMAGE_NAMED(@"作者头像");
        });
    }];
    
    if ([model.status isEqualToString:@"pass"]) {
        _hotLab.hidden = NO;
        _likeBtn.hidden = NO;
        _hotIconImg.hidden = NO;
        _likeLab.hidden = NO;
        _stateImageView.hidden = YES;
        _timeLab.text = model.publishAt;
    } else {
        _hotLab.hidden = YES;
        _likeBtn.hidden = YES;
        _hotIconImg.hidden = YES;
        _likeLab.hidden = YES;
        _stateImageView.hidden = NO;
        if ([model.status isEqualToString:@"publish"]) {
            _stateImageView.image = IMAGE_NAMED(@"审核中");
            _timeLab.text = model.publishAt;
        } else if ([model.status isEqualToString:@"reject"]) {
             _stateImageView.image = IMAGE_NAMED(@"未通过");
            _timeLab.text = model.publishAt;
        } else if ([model.status isEqualToString:@"shelf"]) {
            _stateImageView.image = IMAGE_NAMED(@"已下架");
            _timeLab.text = model.publishAt;
        }
    }
    
    


}

-(void)setCollecModel:(PSCollectArticleListModel *)collecModel{
    
    _collecModel = collecModel;
    _titleLab.text = collecModel.title;
    _contentLab.text = collecModel.content;
    _nameLab.text = collecModel.pen_name;
    _timeLab.text = collecModel.created_at;
    _hotLab.text = collecModel.client_num;
    _likeLab.text = collecModel.praise_num;
    
    
    //是否能点赞
    if ([collecModel.is_praise isEqualToString:@"0"]) {
        [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
    } else {
        [_likeBtn setImage:IMAGE_NAMED(@"已赞") forState:UIControlStateNormal];
    }
    //用户头像
    PSAccountViewModel *viewModel = [[PSAccountViewModel alloc] init];
    [viewModel getAvatarImageUserName:collecModel.username Completed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _headImg.image = image;
        });
    } failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _headImg.image = IMAGE_NAMED(@"作者头像");
        });
    }];
}

#pragma mark - TouchEvent
-(void)praiseAction:(UIButton *)sender {
    //互动文章
    if (_model) {
        if ([_model.ispraise isEqualToString:@"0"]) {
            if (self.praiseBlock) {
                self.praiseBlock(YES, _model.id, ^(BOOL action) {
                    if (action) {
                        [_likeBtn setImage:IMAGE_NAMED(@"已赞") forState:UIControlStateNormal];
                        _likeLab.text = [NSString stringWithFormat:@"%d",[_model.praiseNum intValue]+1];
                        _model.praiseNum = _likeLab.text;
                        _model.ispraise = @"1";
                    }
                });
            }
        } else {
            if (self.praiseBlock) {
                self.praiseBlock(NO, _model.id, ^(BOOL action) {
                    [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
                    _likeLab.text = [NSString stringWithFormat:@"%d",[_model.praiseNum intValue]-1];
                    _model.praiseNum = _likeLab.text;
                    _model.ispraise = @"0";
                });
            }
        }
    }
    //是否能点赞(收藏列表)
    if (_collecModel) {
        if ([_collecModel.is_praise isEqualToString:@"0"]) {
            if (self.praiseBlock) {
                self.praiseBlock(YES, _collecModel.id, ^(BOOL action) {
                    if (action) {
                      [_likeBtn setImage:IMAGE_NAMED(@"已赞") forState:UIControlStateNormal];
                        _likeLab.text = [NSString stringWithFormat:@"%d",[_collecModel.praise_num intValue]+1];
                        _collecModel.praise_num = _likeLab.text;
                        _collecModel.is_praise = @"1";
                    }
                });
            }
        } else {
            if (self.praiseBlock) {
                self.praiseBlock(NO, _collecModel.id, ^(BOOL action) {
                     [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
                     _likeLab.text = [NSString stringWithFormat:@"%d",[_collecModel.praise_num intValue]-1];
                     _collecModel.praise_num = _likeLab.text;
                    _collecModel.is_praise = @"0";
                });
            }
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setting&&Getting
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        _bgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:41/255.0 blue:108/255.0 alpha:0.18].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0,4);
        _bgView.layer.shadowOpacity = 1;
        _bgView.layer.shadowRadius = 12;
        _bgView.layer.cornerRadius = 4;
    }
    return _bgView;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.text = @"今夜的月光超载太重照着我一夜哄不成梦每根";
        _titleLab.textColor = UIColorFromRGB(51,51,51);
        _titleLab.font = boldFontOfSize(15);
        _titleLab.numberOfLines = 2;
        _titleLab.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLab;
}
- (UIImageView *)headImg {
    if (!_headImg) {
        _headImg = [UIImageView new];
        _headImg.image = IMAGE_NAMED(@"作者头像");
    }
    return _headImg;
}

- (UIImageView *)timeIconImg {
    if (!_timeIconImg) {
        _timeIconImg = [UIImageView new];
        _timeIconImg.image = IMAGE_NAMED(@"时间");
    }
    return _timeIconImg;
}

- (UIImageView *)hotIconImg {
    if (!_hotIconImg) {
        _hotIconImg = [UIImageView new];
        _hotIconImg.image = IMAGE_NAMED(@"热度");
    }
    return _hotIconImg;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton new];
        [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
        [_likeBtn be_setEnlargeEdge:10];
        [_likeBtn addTarget:self action:@selector(praiseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [UILabel new];
        _nameLab.text = @"国科吴彦祖肖局";
        _nameLab.font = FontOfSize(12);
        _nameLab.textColor = UIColorFromRGB(102, 102, 102);
        _nameLab.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLab;
}

- (UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [UILabel new];
        _contentLab.text = @"像盲目的鱼群渴望海水爱情是叹息燃烧起的一阵暴风烟就像盲目的鱼群渴望海水爱情是叹息燃烧起的一阵暴风烟就像没有路的森林绕了几回热情是刺激j望必然的反射行为...";
        _contentLab.font = FontOfSize(12);
        _contentLab.textColor = UIColorFromRGB(102, 102, 102);
        _contentLab.textAlignment = NSTextAlignmentLeft;
        _contentLab.numberOfLines = 2;
    }
    return _contentLab;
}

- (UILabel *)timeLab{
    if (!_timeLab) {
        _timeLab = [UILabel new];
        _timeLab.text = @"2019-07-09 11:11:11";
        _timeLab.font = FontOfSize(10);
        _timeLab.textColor = UIColorFromRGB(153,153,153);
        _timeLab.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLab;
}
- (UILabel *)likeLab{
    if (!_likeLab) {
        _likeLab = [UILabel new];
        _likeLab.text = @"";
        _likeLab.font = FontOfSize(10);
        _likeLab.textColor = UIColorFromRGB(153,153,153);
        _likeLab.textAlignment = NSTextAlignmentLeft;
    }
    return _likeLab;
}

- (UILabel *)hotLab{
    if (!_hotLab) {
        _hotLab = [UILabel new];
        _hotLab.text = @"";
        _hotLab.font = FontOfSize(10);
        _hotLab.textColor = UIColorFromRGB(153,153,153);
        _hotLab.textAlignment = NSTextAlignmentLeft;
    }
    return _hotLab;
}

- (UIImageView *)stateImageView {
    if (!_stateImageView) {
        _stateImageView = [UIImageView new];
        _stateImageView.image = IMAGE_NAMED(@"未通过");
        _stateImageView.hidden = YES;
    }
    return _stateImageView;
}


@end
