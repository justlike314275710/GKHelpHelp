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
#import "PSBusinessConstants.h"
#import "PSUserSession.h"

@interface PSPlatformArticleCell()
@property(nonatomic,strong)UIImageView *bgView;
@end

@implementation PSPlatformArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColorFromRGB(249,248,254);
        self.contentView.backgroundColor = UIColorFromRGB(249,248,254);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self renderContents];
        [self SDWebImageAuth];
    }
    return self;
}

- (void)renderContents {
    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(175);
        make.top.mas_equalTo(0);
    }];
    
    [self.bgView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-25);
        make.top.mas_equalTo(22);
        make.height.mas_equalTo(20);
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
        make.height.mas_equalTo(35);
        make.centerY.mas_equalTo(self.headImg);
    }];
    [self.nameLab setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
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
        make.top.mas_equalTo(_headImg.mas_bottom).offset(8);
        make.height.mas_equalTo(40);
    }];
    
    [_bgView addSubview:self.timeIconImg];
    [self.timeIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentLab);
        make.bottom.mas_equalTo(-33);
        make.width.height.mas_equalTo(10);
    }];
    
    [_bgView addSubview:self.likeBtn];
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.timeIconImg);
        make.width.height.mas_equalTo(10);
        make.centerX.mas_equalTo(_bgView.mas_centerX);
    }];
    self.likeBtn.touchExtendInset = UIEdgeInsetsMake(-15, -15, -15, -15);
    
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
    _contentLab.lineSpace = @"6";
    _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
    //是否能点赞
    if ([_model.ispraise isEqualToString:@"0"]) {
        [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
        _likeBtn.selected = NO;
    } else {
        [_likeBtn setImage:IMAGE_NAMED(@"已赞") forState:UIControlStateNormal];
        _likeBtn.selected = YES;
    }
    
    //用户头像
    NSString*url=AvaterImageWithUsername(_model.username);
    //自己头像
    NSString*username=[NSString stringWithFormat:@"%@",[LXFileManager readUserDataForKey:@"username"]];
    if ([username isEqualToString:_model.username]) {
        NSLog(@"hahaaha");
        NSString*urlSting=[NSString stringWithFormat:@"%@%@",EmallHostUrl,URL_get_userAvatar];
        [_headImg sd_setImageWithURL:[NSURL URLWithString:urlSting] placeholderImage:IMAGE_NAMED(@"作者头像") options:SDWebImageRefreshCached];
    } else {
        [_headImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"作者头像"] options:SDWebImageRefreshCached];
    }
    
    
    if ([model.status isEqualToString:@"pass"]) {
        _hotLab.hidden = NO;
        _likeBtn.hidden = NO;
        _hotIconImg.hidden = NO;
        _likeLab.hidden = NO;
        _stateImageView.hidden = YES;
        _timeLab.text = model.auditAt;
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
            _timeLab.text = model.auditAt;
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
    _contentLab.lineSpace = @"6";
    _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentLab.lineSpace = @"6";
    _contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //是否能点赞
    if ([collecModel.is_praise isEqualToString:@"0"]) {
        [_likeBtn setImage:IMAGE_NAMED(@"未赞") forState:UIControlStateNormal];
        _likeBtn.selected = NO;
    } else {
        [_likeBtn setImage:IMAGE_NAMED(@"已赞") forState:UIControlStateNormal];
        _likeBtn.selected = YES;
    }

    //用户头像
    NSString*url=AvaterImageWithUsername(_collecModel.username);
    //自己头像
    NSString*username=[NSString stringWithFormat:@"%@",[LXFileManager readUserDataForKey:@"username"]];
    if ([username isEqualToString:_collecModel.username]) {
        NSLog(@"hahaaha");
        NSString*urlSting=[NSString stringWithFormat:@"%@%@",EmallHostUrl,URL_get_userAvatar];
        [_headImg sd_setImageWithURL:[NSURL URLWithString:urlSting] placeholderImage:IMAGE_NAMED(@"作者头像") options:SDWebImageRefreshCached];
    } else {
        [_headImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"作者头像"] options:SDWebImageRefreshCached];
    }
}

-(void)SDWebImageAuth{
    
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [SDWebImageManager.sharedManager.imageDownloader setValue:token forHTTPHeaderField:@"Authorization"];
    [SDWebImageManager sharedManager].imageCache.config.maxCacheAge=5*60.0;
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
- (UIImageView *)bgView{
    if (!_bgView) {
        _bgView = [UIImageView new];
        _bgView.image = IMAGE_NAMED(@"platcell_bottom");
        _bgView.userInteractionEnabled = YES;
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
