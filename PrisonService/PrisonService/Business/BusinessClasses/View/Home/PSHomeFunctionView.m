//
//  PSHomeFunctionView.m
//  PrisonService
//
//  Created by kky on 2019/6/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSHomeFunctionView.h"
#import "UIButton+LZCategory.h"

@interface PSHomeFunctionView() {
    NSArray *_titles;
    NSArray *_imageIcons;
}
@property (nonatomic,strong)UIImageView *bgImageView;

@end

@implementation PSHomeFunctionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
         imageIcons:(NSArray *)imageIcons
{
    self = [super initWithFrame:frame];
    if (self) {
        _titles = titles;
        _imageIcons = imageIcons;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    
    [self addSubview:self.bgImageView];
    CGFloat itemBtnWidth = (self.size.width-20)/_titles.count;
    for (int i = 0; i<_titles.count; i++) {
        UIButton *itemBtn = [UIButton new];
        itemBtn.frame = CGRectMake(itemBtnWidth*i+10,0,itemBtnWidth,88);
        [itemBtn setImage:IMAGE_NAMED(_imageIcons[i]) forState:UIControlStateNormal];
        [itemBtn setTitle:_titles[i] forState:UIControlStateNormal];
        [itemBtn setTitleColor:UIColorFromRGB(51,51,51) forState:UIControlStateNormal];
        itemBtn.titleLabel.font = FontOfSize(12);
        itemBtn.tag = 10088+i;
        [itemBtn lz_initButton:itemBtn];
        [self addSubview:itemBtn];
        [itemBtn addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)itemAction:(UIButton *)sender {
    NSInteger index = sender.tag - 10088;
    if (self.homeFunctionBlock) {
        self.homeFunctionBlock(index);
    }
}
-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.image = IMAGE_NAMED(@"commonBg");
        _bgImageView.frame = CGRectMake(0,0,self.size.width,self.size.height);
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

@end
