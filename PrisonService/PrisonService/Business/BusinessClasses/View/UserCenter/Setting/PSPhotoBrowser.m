//
//  PSPhotoBrowser.m
//  PrisonService
//
//  Created by kky on 2018/12/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPhotoBrowser.h"

#define BrowserX 15
#define BrowserY 183
#define BrowserHeight 270


@interface PSPhotoBrowser ()<UIScrollViewDelegate>
@property(nonatomic, strong) UIToolbar *shadowView;
@property(nonatomic, strong) UIScrollView *scrollview;
@property(nonatomic, assign) NSInteger imagesCount;
@property(nonatomic, assign) NSInteger imagesIndex;
@property(nonatomic, strong) NSArray *imaegs;
@property(nonatomic, strong) UIButton *leftBtn;
@property(nonatomic, strong) UIButton *rightBtn;


@end

@implementation PSPhotoBrowser

+(instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images atIndex:(NSInteger)index
{
    return [self showFromImageView:imageView withImages:images atIndex:index dismiss:nil];
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images atIndex:(NSInteger)index dismiss:(DismissBlock)block {
    
    int scrollview_width = SCREEN_WIDTH-120;
    int browser_height = scrollview_width + 30;
    PSPhotoBrowser *browser = [[PSPhotoBrowser alloc] initWithFrame:CGRectMake(BrowserX,BrowserY, SCREEN_WIDTH-2*BrowserX,browser_height)];
    browser.backgroundColor = [UIColor whiteColor];
    browser.imagesIndex = index;
//    browser.imageView = imageView;
//    browser.images = images;
    browser.imagesCount = images.count;
    browser.imaegs = images;
//    [browser resetCountLabWithIndex:index+1];
    [browser configureBrowser];
//    [browser animateImageViewAtIndex:index];
//    browser.dismissDlock = block;
    
    return browser;
}


#pragma mark - Private Methods
-(void)configureBrowser {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.shadowView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self addSubview:self.scrollview];
    self.scrollview.contentSize = CGSizeMake(self.scrollview.width*self.imagesCount, self.scrollview.height);
    [self addSubview:self.leftBtn];
    [self addSubview:self.rightBtn];
    for (int i = 0; i<self.imagesCount; i++) {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollview.width*i,0,self.scrollview.width, self.scrollview.width)];
//        imageV.image = self.imaegs[i];
        [imageV sd_setImageWithURL:self.imaegs[i]];
        [self.scrollview addSubview:imageV];
    }
    [self.scrollview setContentOffset:CGPointMake(self.imagesIndex * self.scrollview.frame.size.width, 0) animated:NO];
}

- (void)disMissView {
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH,325);
    } completion:^(BOOL finished) {
        if (self) [self removeFromSuperview];
        if (_shadowView) [_shadowView removeFromSuperview];
    }];
}

- (void)leftNextPage {
    self.imagesIndex --;
    if (self.imagesIndex >= 0) {
        [self.scrollview setContentOffset:CGPointMake(self.imagesIndex * self.scrollview.frame.size.width, 0) animated:YES];
    } else {
        self.imagesIndex = 0;
    }
}

- (void)rightNextPage {
    self.imagesIndex ++;
    if (self.imagesIndex <= self.imagesCount-1) {
        [self.scrollview setContentOffset:CGPointMake(self.imagesIndex * self.scrollview.frame.size.width, 0) animated:YES];
    } else {
        self.imagesIndex = self.imagesIndex-1;
    }
}
#pragma mark - Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index=scrollView.contentOffset.x/scrollView.bounds.size.width;
    self.imagesIndex = index;
}

#pragma mark - Setting&&Getting
- (UIToolbar *)shadowView {
    if (!_shadowView) {
        _shadowView= [[UIToolbar alloc]initWithFrame:CGRectZero];
        _shadowView.barStyle = UIBarStyleBlackTranslucent;//半透明
        _shadowView.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _shadowView.userInteractionEnabled = YES;
        _shadowView.alpha = 0.8f;
        @weakify(self);
        [_shadowView bk_whenTapped:^{
            @strongify(self);
            [self disMissView];
        }];
    }
    return _shadowView;
}

-(UIScrollView *)scrollview {
    
    if (!_scrollview) {
        int scrollview_width = SCREEN_WIDTH-120;
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(45,15, scrollview_width, scrollview_width)];
        _scrollview.pagingEnabled = YES;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.delegate = self;
        
    }
    return _scrollview;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(13,(self.height-24)/2, 20, 24);
        [_leftBtn setImage:[UIImage imageNamed:@"左"] forState:UIControlStateNormal];
        @weakify(self);
        [_leftBtn bk_whenTapped:^{
            @strongify(self);
            [self leftNextPage];
        }];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(self.width-32,(self.height-24)/2, 20, 24);
        [_rightBtn setImage:[UIImage imageNamed:@"右"] forState:UIControlStateNormal];
        @weakify(self);
        [_rightBtn bk_whenTapped:^{
            @strongify(self);
            [self rightNextPage];
        }];
    }
    return _rightBtn;
}






@end
