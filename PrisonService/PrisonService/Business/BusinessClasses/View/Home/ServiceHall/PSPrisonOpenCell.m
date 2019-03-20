//
//  PrisonOpenCell.m
//  PrisonService
//
//  Created by kky on 2019/2/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPrisonOpenCell.h"
@interface PSPrisonOpenCell()
@property (nonatomic ,strong) UIView *bgView;
@end

@implementation PSPrisonOpenCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self renderContents];
    }
    return self;
}

-(void)renderContents {
    
    NSInteger spaceX = 15;
    [self.contentView addSubview:self.bgView];
    self.bgView.frame = CGRectMake(spaceX,5,SCREEN_WIDTH-2*spaceX,90);
 
    [self.bgView addSubview:self.iconImg];
    self.iconImg.frame = CGRectMake(spaceX,spaceX,60,60);
    
    [self.bgView addSubview:self.titleLab];
    self.titleLab.frame = CGRectMake(self.iconImg.right+25,(_bgView.height-20)/2,200,20);
    self.titleLab.text = @"暂予监外执行";
    
    [self.bgView addSubview:self.arrowImg];
    self.arrowImg.frame = CGRectMake(self.bgView.width-19-12,(_bgView.height-7)/2 ,7, 12);
    
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    NSString *imageicon = [data valueForKey:@"imageicon"];
    NSString *title = [data valueForKey:@"title"];
    self.titleLab.text = title;
    self.iconImg.image = [UIImage imageNamed:imageicon];
}

-(UIView*)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        _bgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:33/255.0 blue:52/255.0 alpha:0.08].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0,0);
        _bgView.layer.shadowOpacity = 1;
        _bgView.layer.shadowRadius = 4;
        _bgView.layer.cornerRadius = 4;
    }
    return _bgView;
}

- (UIImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [UIImageView new];
    }
    return _iconImg;
}
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
    }
    return _titleLab;
}
- (UIImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [UIImageView new];
        _arrowImg.image = [UIImage imageNamed:@"进入下一步icon"];
    }
    return _arrowImg;
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
