//
//  PSPlatformMenuView.m
//  PrisonService
//
//  Created by kky on 2019/8/1.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPlatformMenuView.h"
#import "YLButton.h"


#define itemWidth   KScreenWidth/4
#define menuWidth   KScreenWidth-25
#define menuHeight  60
#define sliderWidth KScreenWidth/4

@interface PSPlatformMenuView() {
    NSInteger _currentIndex;
    UIView *_slideView;
    float _spacesX;
}
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSArray *normalImages;
@property (nonatomic,strong) NSArray *selectedImages;
@property (nonatomic,strong) id<PSPlatfromMenuViewDelegate> delgate;

@end

@implementation PSPlatformMenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ViewRadius(self,30);
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
       normalImages:(NSArray *)normalImages
     selectedImages:(NSArray *)selectedImages
           delegate:(id<PSPlatfromMenuViewDelegate>)delegate
       currentIndex:(NSInteger)currentIndex
 {
    self = [super initWithFrame:frame];
    if (self) {
        ViewRadius(self,30);
        _titles = titles;
        _normalImages = normalImages;
        _selectedImages = selectedImages;
        _currentIndex = 0;
        _delgate = delegate;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {

    _slideView = [self slider];
    [self addSubview:_slideView];
    
    _spacesX = (self.width-_titles.count*itemWidth)/(_titles.count-1);
    for (int i = 0;i<_titles.count;i++) {
        YLButton *item = [self setItem];
        item.frame = CGRectMake(i*(itemWidth+_spacesX), 0,itemWidth, menuHeight);
        [item setImage:IMAGE_NAMED(_normalImages[i]) forState:UIControlStateNormal];
        [item setImage:IMAGE_NAMED(_selectedImages[i]) forState:UIControlStateSelected];
        [item setTitle:_titles[i] forState:UIControlStateNormal];
        item.backgroundColor = [UIColor clearColor];
        [self addSubview:item];
        item.selected = _currentIndex==i?YES:NO;
        [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = 10+i;
    }
}

- (void)itemAction:(YLButton *)sender {
    NSInteger index = sender.tag-10;
    if (index == _currentIndex) return;
    NSInteger time = labs(index-_currentIndex);
    [self changeItemState];
    sender.selected = YES;
    [UIView animateWithDuration:0.2*time animations:^{
        _slideView.frame = CGRectMake(index*(itemWidth+_spacesX),0,sliderWidth,menuHeight);
    } completion:^(BOOL finished) {
        
    }];
    _currentIndex = index;
    [_delgate pagescrollMenuViewItemOnClick:sender index:index];
    
}

- (void)changeItemState {
    for (int i = 0;i<_titles.count;i++) {
        YLButton *item = [self viewWithTag:i+10];
        item.selected = NO;
    }
}
- (YLButton *)setItem {
    YLButton *item = [YLButton buttonWithType:UIButtonTypeCustom];
    item.imageRect = CGRectMake((itemWidth-20)/2,13,20,18);
    item.titleRect = CGRectMake(0,34,itemWidth,20);
    [item setTitleColor:UIColorFromRGB(102, 102, 102) forState:UIControlStateNormal];
    [item setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    item.titleLabel.textAlignment = NSTextAlignmentCenter;
    item.titleLabel.font = FontOfSize(12);
    ViewRadius(item, menuHeight/2);
    return item;
}

- (UIView *)slider {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0,sliderWidth,menuHeight);
    view.backgroundColor = UIColorFromRGB(0,107,255);
    ViewRadius(view,30);
    return view;
}

@end
