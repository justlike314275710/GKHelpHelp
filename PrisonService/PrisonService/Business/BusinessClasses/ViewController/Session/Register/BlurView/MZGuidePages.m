//
//  MZGuidePages.m
//  MZGuidePages
//
//  Created by boco on 15/11/13.
//  Copyright © 2015年 Machelle. All rights reserved.
//

#import "MZGuidePages.h"

//#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
//#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface MZGuidePages () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation MZGuidePages

// init
- (instancetype)init
{
    return [self initWithImageDatas:nil completion:nil];
}

// init with imageDatas and completion
- (instancetype)initWithImageDatas:(NSArray *)imageDatas completion:(void (^)(void))buttonAction
{
    self = [super init];
    if (self)
    {
        [self initView];
        //因为使用了懒加载，_imageDatas = imageDatas不会调用initContentView
        [self setImageDatas:imageDatas];
        _buttonAction = buttonAction;
    }
    return self;
}

//懒加载，并初始化内容
- (void)setImageDatas:(NSArray *)imageDatas
{
    _imageDatas = imageDatas;
    [self initContentView];
}

//基础视图初始化
- (void)initView
{
    // init view
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    // init scrollView
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    // init pageControl
    _pageControl =
        [[UIPageControl alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 30, SCREEN_WIDTH, 10)];
    _pageControl.currentPage = 0;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControl];

    // init button
    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actionButton.frame =
    CGRectMake(SCREEN_WIDTH  - 120, 40, 100, 100);
    _actionButton.layer.cornerRadius = 5;
    _actionButton.layer.masksToBounds = YES;
    [_actionButton setTitle:@" " forState:UIControlStateNormal];
    _actionButton.tintColor = [UIColor clearColor];
    _actionButton.backgroundColor = [UIColor clearColor];
    [_actionButton addTarget:self
                       action:@selector(enterButtonClick)
             forControlEvents:UIControlEventTouchUpInside];
     [self addSubview: _actionButton];
}

//指定数据后，初始化显示内容
- (void)initContentView
{
    if (_imageDatas.count)
    {
        _pageControl.numberOfPages = _imageDatas.count;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * _imageDatas.count, SCREEN_HEIGHT);

        
        for (int i = 0; i < _imageDatas.count; i++)
        {
            NSString *imageName = _imageDatas[i];
            self.imgView =
                [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
           self.imgView.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.scrollView addSubview:_imgView];
            _imgView.tag = i;
            _imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [_imgView addGestureRecognizer:tap];
            if (i==_imageDatas.count-1) {
              UIButton*hideBtn= [UIButton buttonWithType:UIButtonTypeCustom];
                hideBtn.frame =
                CGRectMake(10, 100, SCREEN_WIDTH-20, SCREEN_HEIGHT/2);
                hideBtn.layer.cornerRadius = 5;
                hideBtn.layer.masksToBounds = YES;
               [ hideBtn setTitle:@"" forState:UIControlStateNormal];
                hideBtn.tintColor = [UIColor clearColor];
                hideBtn.backgroundColor = [UIColor clearColor];
                [hideBtn addTarget:self
                                  action:@selector(enterButtonClick)
                        forControlEvents:UIControlEventTouchUpInside];
                [self.imgView addSubview: hideBtn];
            }

        }
    }
}



#pragma mark
#pragma mark Action
- (void)enterButtonClick
{
    if (_buttonAction)
    {
        _buttonAction();
    }
}

#pragma mark
#pragma mark UIScrollView delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    _pageControl.currentPage = (_scrollView.contentOffset.x + SCREEN_WIDTH / 2) / SCREEN_WIDTH;
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page = self.scrollView.contentOffset.x / SCREEN_WIDTH + 0.5;
    self.pageControl.currentPage = page;
}
-(void)tapGesture:(UITapGestureRecognizer *)tap{
    
    
    int offset = self.scrollView.contentOffset.x;
    offset += SCREEN_WIDTH;
    if (offset >= SCREEN_WIDTH * self.imageDatas.count) {
        offset = SCREEN_WIDTH * (self.imageDatas.count-1);
    }
    [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    
}
//在结束滚动时设置页面，比滚动中改变页面性能更好，因为滚动一次只调用一次
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    _pageControl.currentPage = (_scrollView.contentOffset.x + SCREEN_WIDTH / 2) / SCREEN_WIDTH;
}


- (void)changeImage {
    [self.scrollView setContentOffset:CGPointMake((self.imgView.tag)*SCREEN_WIDTH , 0) animated:YES];
    self.scrollView.bouncesZoom = NO;
}

@end
