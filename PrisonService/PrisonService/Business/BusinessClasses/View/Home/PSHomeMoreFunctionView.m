//
//  PSHomeMoreFunctionView.m
//  PrisonService
//
//  Created by kky on 2019/6/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSHomeMoreFunctionView.h"
#import "UIButton+LZCategory.h"

@interface PSHomeMoreFunctionView() {
    NSArray *_titles;
    NSArray *_imageIcons;
}
@property (nonatomic,strong)UILabel *label;


@end

@implementation PSHomeMoreFunctionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self renderContents];
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
-(void)layoutSubviews {
    [super layoutSubviews];
}


-(void)renderContents {
    
    [self addSubview:self.label];
    
    NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
    NSString*laws_regulations=NSLocalizedString(@"laws_regulations", @"全民普法");
    NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
    _titles = @[prison_opening,laws_regulations,work_dynamic];
    _imageIcons = @[@"狱务公开icon",@"全民普法icon",@"工作动态icon"];
    int moreItemWidth = (KScreenWidth)/_titles.count;
    for (int i = 0; i<_titles.count;i++) {

        UIImageView *moreItemBg = [UIImageView new];
        moreItemBg.userInteractionEnabled = YES;
        moreItemBg.image = IMAGE_NAMED(@"更多服务单个底");
        moreItemBg.frame = CGRectMake(i*moreItemWidth,22,moreItemWidth,160);
        [self addSubview:moreItemBg];
        UIButton *moreBtnItem = [UIButton new];
        moreBtnItem.frame = CGRectMake(0, 0,moreItemBg.width,moreItemBg.width);
        moreBtnItem.tag = 1000+i;
        [moreBtnItem setImage:IMAGE_NAMED(_imageIcons[i]) forState:UIControlStateNormal];
        [moreBtnItem setTitle:_titles[i] forState:UIControlStateNormal];
        [moreBtnItem setTitleColor:UIColorFromRGB(51,51,51) forState:UIControlStateNormal];
        moreBtnItem.titleLabel.font = FontOfSize(12);
        [moreBtnItem setbuttonType:LZCategoryTypeBottom spaceHeght:15];
        [moreItemBg addSubview:moreBtnItem];
        [moreBtnItem addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)itemAction:(UIButton *)sender {
    NSInteger index = sender.tag-1000;
    if (self.moreFunctionBlock) {
        self.moreFunctionBlock(index);
    }
    
}
-(UILabel *)label{
    if (!_label) {
        _label = [UILabel new];
        _label.text = @"更多服务";
        _label.font = boldFontOfSize(14);
        _label.textColor = UIColorFromRGB(51, 51,51);
        _label.textAlignment=NSTextAlignmentLeft;
        _label.frame = CGRectMake(16,2, 100, 20);
    }
    return _label;
}

@end
