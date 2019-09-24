//
//  PSPlatformHeadView.m
//  PrisonService
//
//  Created by kky on 2019/8/5.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPlatformHeadView.h"
#import "UIButton+BEEnLargeEdge.h"

@interface PSPlatformHeadView () {
    NSString *_title;
}
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIButton *insertAction;

@end

@implementation PSPlatformHeadView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self renderContents];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _title = title;
        [self renderContents];
    }
    return self;
}

- (void)renderContents{
    
    [self addSubview:self.titleLab];
    _titleLab.text = _title;
    [self addSubview:self.insertAction];
    
}

#pragma mark - Setting
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.frame = CGRectMake(15, 10, 100, 20);
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.font = boldFontOfSize(15);
        _titleLab.textColor = UIColorFromRGB(51, 51, 51);
    }
    return _titleLab;
}

- (UIButton *)insertAction {
    if (!_insertAction) {
        _insertAction = [UIButton buttonWithType:UIButtonTypeCustom];
        _insertAction.frame = CGRectMake(KScreenWidth-25,12,10,16);
        [_insertAction be_setEnlargeEdgeWithTop:10 right:5 bottom:10 left:100];
        [_insertAction setImage:[UIImage imageNamed:@"进入icon"] forState:UIControlStateNormal];
        [_insertAction addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _insertAction;
}

- (void)action:(UIButton *)sender {
    if (self.block) {
        self.block(_title);
    }
}

@end
