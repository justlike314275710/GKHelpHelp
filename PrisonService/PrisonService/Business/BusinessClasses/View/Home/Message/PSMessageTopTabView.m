//
//  PSMessageTopTabView.m
//  PrisonService
//
//  Created by kky on 2019/9/5.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSMessageTopTabView.h"
#import "YLButton.h"

#define msitemWidth   KScreenWidth/3
#define mstopTabHeight 35
#define mssliderWidth msitemWidth*0.7
@interface PSMessageTopTabView(){
     NSInteger _currentIndex;
     UIView *_slideView;
     float _spacesX;
     UIViewController *_vc;
     NSArray *_vcs;
    NSArray *_numbers;
}
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSArray *normalImages;
@property (nonatomic,strong) NSArray *selectedImages;
@property (nonatomic,strong) id<PSMessageTopTabViewDelegate> delegate;

@end

@implementation PSMessageTopTabView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(249,248,254);
        self.frame = CGRectMake(0, 0, KScreenWidth, 45);
        _currentIndex = 0;
        [self setupUI];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
       normalImages:(NSArray *)normalImages
     selectedImages:(NSArray *)selectedImages
       currentIndex:(NSInteger)currentIndex
           delegate:(id<PSMessageTopTabViewDelegate>)delegate
     viewController:(UIViewController *)viewController
            numbers:(NSArray *)numbers
        
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(249,248,254);
        self.frame = CGRectMake(0, 0, KScreenWidth,45);
        _vc = viewController;
        _titles = titles;
        _normalImages = normalImages;
        _selectedImages = selectedImages;
        _delegate = delegate;
        _numbers = numbers;
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    UIView *TabBarView = [[UIView alloc] init];
    TabBarView.frame = CGRectMake(0, 10, KScreenWidth, mstopTabHeight);
    TabBarView.backgroundColor = [UIColor whiteColor];
    [self addSubview:TabBarView];
    UIView *toplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenHeight, 1)];
    toplineView.backgroundColor = UIColorFromRGB(217, 217, 217);
    [TabBarView addSubview:toplineView];
    UIView *bottomlineView = [[UIView alloc] initWithFrame:CGRectMake(0,mstopTabHeight,KScreenWidth, 1)];
    bottomlineView.backgroundColor = UIColorFromRGB(217, 217, 217);
    [TabBarView addSubview:bottomlineView];
    
    _slideView = [self slider];
    [TabBarView addSubview:_slideView];
    _spacesX = 0.15*msitemWidth;
    _slideView.x = _spacesX;
    
    for (int i = 0; i<3; i++) {
        YLButton *item = [self setItem:[[_numbers objectAtIndex:i] integerValue]];
        item.frame = CGRectMake(i*msitemWidth,1,msitemWidth,mstopTabHeight-2);
        [item setImage:IMAGE_NAMED(_normalImages[i]) forState:UIControlStateNormal];
        [item setImage:IMAGE_NAMED(_selectedImages[i]) forState:UIControlStateSelected];
        [item setTitle:_titles[i] forState:UIControlStateNormal];
        item.backgroundColor = [UIColor clearColor];
        [TabBarView addSubview:item];
        item.selected = _currentIndex==i?YES:NO;
        [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = 100+i;
    }
}

-(void)setViewControllers:(NSArray *)viewControllers {
    
    _vcs = viewControllers;
    _vc.view.clipsToBounds = YES;//超过父视图部分不显示
    UIViewController *vc1 = [viewControllers objectAtIndex:0];
    UIViewController *vc2 = [viewControllers objectAtIndex:1];
    UIViewController *vc3 = [viewControllers objectAtIndex:2];
    [_vc addChildViewController:vc1];
    [_vc addChildViewController:vc2];
    [_vc addChildViewController:vc3];
    [_vc.view addSubview:vc1.view];
    [_vc.view addSubview:vc2.view];
    [_vc.view addSubview:vc3.view];
    vc1.view.frame = CGRectMake(0,50, KScreenWidth, KScreenHeight-50);
    vc2.view.frame = CGRectMake(1*KScreenWidth,50,KScreenWidth,KScreenHeight-50);
    vc3.view.frame = CGRectMake(2*KScreenWidth,50,KScreenWidth,KScreenHeight-50);
}

- (void)setNumbers:(NSArray *)numbers {
    YLButton *item1 = [self viewWithTag:100];
    YLButton *item2 = [self viewWithTag:101];
    YLButton *item3 = [self viewWithTag:102];
    
}

- (void)itemAction:(YLButton *)sender {
    NSInteger index = sender.tag-100;
    if (index == _currentIndex) return;
    NSInteger time = labs(index-_currentIndex);
    [self changeItemState];
    sender.selected = YES;
    [UIView animateWithDuration:0.2*time animations:^{
        _slideView.frame = CGRectMake(index*msitemWidth+_spacesX,mstopTabHeight,msitemWidth*0.75,1);
    } completion:^(BOOL finished) {
        
    }];
    
    if (_delegate&&[_delegate respondsToSelector:@selector(pagescrollMenuViewItemOnClick:index: lastindex:)]) {
        [_delegate pagescrollMenuViewItemOnClick:sender index:index lastindex:_currentIndex];
    }
    [self pagescrollMenuViewItemOnClick:sender index:index];
    
    //取消当前页面红点
    YLButton *ylButton = [self viewWithTag:100+_currentIndex];
    [ylButton.imageView hideBadgeView];
    
    _currentIndex = index;
    
}

-(void)pagescrollMenuViewItemOnClick:(UIButton *) sender index:(NSInteger)index{
    
    NSInteger sliderIndex = index-_currentIndex;
    NSInteger slidertime = labs(sliderIndex);
    if (sliderIndex>0) {
        [UIView animateWithDuration:slidertime*0.2 animations:^{
            [_vcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIViewController *vc = obj;
                vc.view.x = vc.view.x - KScreenWidth*slidertime;
            }];
        } completion:nil];
    } else {
        [UIView animateWithDuration:slidertime*0.2 animations:^{
            [_vcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIViewController *vc = obj;
                vc.view.x = vc.view.x + KScreenWidth*slidertime;
            }];
        } completion:nil];
    }
}

- (void)changeItemState {
    for (int i = 0;i<3;i++) {
        YLButton *item = [self viewWithTag:i+100];
        item.selected = NO;
    }
}

- (YLButton *)setItem:(NSInteger)number {
    YLButton *item = [YLButton buttonWithType:UIButtonTypeCustom];
    item.imageRect = CGRectMake(msitemWidth/2-30,13,15,15);
    item.titleRect = CGRectMake(msitemWidth/2-10,10,msitemWidth,20);
    [item setTitleColor:UIColorFromRGB(102, 102, 102) forState:UIControlStateNormal];
    [item setTitleColor:UIColorFromRGB(38, 76, 144) forState:UIControlStateSelected];
    item.titleLabel.textAlignment = NSTextAlignmentLeft;
    item.titleLabel.font = FontOfSize(12);
    item.imageView.redDotNumber = number;
    item.imageView.redDotBorderWidth = 1.0;
    item.imageView.redDotBorderColor = [UIColor redColor];
    item.imageView.clipsToBounds = NO;
    [item.imageView ShowBadgeView];
    if (number==0) {
        [item.imageView hideBadgeView];
    } else {
        [item.imageView ShowBadgeView];
    }
    return item;
}

- (UIView *)slider {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0,mstopTabHeight,mssliderWidth,1);
    view.backgroundColor = UIColorFromRGB(38,76,144);
    return view;
}










@end
