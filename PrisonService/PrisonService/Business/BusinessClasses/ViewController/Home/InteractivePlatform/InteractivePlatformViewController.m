//
//  InteractivePlatformViewController.m
//  PrisonService
//
//  Created by kky on 2019/8/1.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "InteractivePlatformViewController.h"
#import "PSPlatformMenuView.h"
#import "InteractiveArticleViewController.h"
#import "CollectionArtcleViewController.h"
#import "MineArticleViewController.h"
#import "PSPublishArticleViewController.h"
#import "PSCollecArtcleListViewModel.h"
#import "PSPublishArtcleListViewModel.h"
#import "PSMyTotalArtcleListViewModel.h"
#import "PSPublishArticleViewModel.h"
#import "PSArticleDetailViewModel.h"


@interface InteractivePlatformViewController ()<PSPlatfromMenuViewDelegate> {
    InteractiveArticleViewController *_ArticleVC;
    CollectionArtcleViewController *_CollectionVC;
    MineArticleViewController *_MineArticleVC;
    NSArray *_arrayVCs;
    NSInteger _currentIndex;
    BOOL _author;
}
@property (nonatomic,strong) UIButton *publishBtn;

@end

@implementation InteractivePlatformViewController

#pragma mark - CycleLife
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"互动平台";
    self.view.backgroundColor = UIColorFromRGB(249,248,254);
    self.view.clipsToBounds = YES;//超过父视图部分不显示
    NSArray *titels = @[@"互动文章",@"我的收藏",@"我的文章"];
    NSArray *normalImages = @[@"互动文章－未选中",@"我的收藏－未选中",@"我的文章－未选中"];
    NSArray *selectedImages = @[@"互动文章－选中",@"我的收藏－选中",@"我的文章－选中"];
    PSPlatformMenuView *menuView = [[PSPlatformMenuView alloc] initWithFrame:CGRectMake(25,21, KScreenWidth-50,60) titles:titels normalImages:normalImages selectedImages:selectedImages delegate:self currentIndex:0];
    menuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:menuView];
    
    _arrayVCs = [self setArrayChildVCs];
    
    [self.view addSubview:self.publishBtn];
    
    [self setupData];
    
    _author = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)setupData{
    PSArticleDetailViewModel *detailViewModel = [[PSArticleDetailViewModel alloc] init];
    [detailViewModel authorArticleCompleted:^(PSResponse *response) {
        if ([detailViewModel.authorModel.isEnabled isEqualToString:@"1"]) {
            [_publishBtn setEnabled:YES];
            [_publishBtn setImage:IMAGE_NAMED(@"发布") forState:UIControlStateNormal];
            _author = YES;
        } else {
            [_publishBtn setImage:IMAGE_NAMED(@"不能发布") forState:UIControlStateNormal];
            _author = NO;
        }
    } failed:^(NSError *error) {
        
    }];
}

#pragma mark - PrivateMethosd
- (NSArray *)setArrayChildVCs {
    //互动文章
    PSPublishArtcleListViewModel *publishArtcleViewModel = [PSPublishArtcleListViewModel new];
    _ArticleVC = [[InteractiveArticleViewController alloc] initWithViewModel:publishArtcleViewModel];
    
    //收藏文章
    PSCollecArtcleListViewModel *collecArtcleViewModel = [PSCollecArtcleListViewModel new];
    _CollectionVC = [[CollectionArtcleViewController alloc] initWithViewModel:collecArtcleViewModel];
    
    //我的文章
    PSMyTotalArtcleListViewModel *myTotalArticleViewModel = [PSMyTotalArtcleListViewModel new];
    _MineArticleVC = [[MineArticleViewController alloc] initWithViewModel:myTotalArticleViewModel];
    
    [self addChildViewController:_ArticleVC];
    [self addChildViewController:_CollectionVC];
    [self addChildViewController:_MineArticleVC];
    [self.view addSubview:_ArticleVC.view];
    [self.view addSubview:_CollectionVC.view];
    [self.view addSubview:_MineArticleVC.view];
    _ArticleVC.view.frame = CGRectMake(0, 100, KScreenWidth, KScreenHeight-100);
    _CollectionVC.view.frame = CGRectMake(1*KScreenWidth,100,KScreenWidth,KScreenHeight-100);
    _MineArticleVC.view.frame = CGRectMake(2*KScreenWidth,100,KScreenWidth,KScreenHeight-100);
    _currentIndex = 0;
    return @[_ArticleVC,_CollectionVC,_MineArticleVC];
}

#pragma mark - Delegate
//MARK:PSPlatfromMenuViewDelegate
- (void)pagescrollMenuViewItemOnClick:(YLButton *)button index:(NSInteger)index {
    
    NSInteger sliderIndex = index-_currentIndex;
    NSInteger slidertime = labs(sliderIndex);
    if (sliderIndex>0) {
        [UIView animateWithDuration:slidertime*0.2 animations:^{
            _ArticleVC.view.x = _ArticleVC.view.x - KScreenWidth*slidertime;
            _CollectionVC.view.x = _CollectionVC.view.x - KScreenWidth*slidertime;
            _MineArticleVC.view.x = _MineArticleVC.view.x - KScreenWidth*slidertime;
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        [UIView animateWithDuration:slidertime*0.2 animations:^{
            _ArticleVC.view.x = _ArticleVC.view.x + KScreenWidth*slidertime;
            _CollectionVC.view.x = _CollectionVC.view.x + KScreenWidth*slidertime;
            _MineArticleVC.view.x = _MineArticleVC.view.x + KScreenWidth*slidertime;
        } completion:^(BOOL finished) {
            
        }];
    }
    _currentIndex = index;
}

#pragma mark - TouchEvent
- (void)publishBtnAction:(UIButton *)sender {
    PSPublishArticleViewModel *viewModel = [[PSPublishArticleViewModel alloc] init];
    if (!_author) {
        [PSTipsView showTips:@"暂无权限!"];
        return;
    }
    viewModel.type = PSPublishArticle;
    PSPublishArticleViewController *publishVC = [[PSPublishArticleViewController alloc] initWithViewModel:viewModel];
    [self.navigationController pushViewController:publishVC animated:YES];
}
#pragma mark - Seting&&Getting
- (UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishBtn.frame = CGRectMake(KScreenWidth-59,KScreenHeight-150,50,50);
        [_publishBtn setImage:IMAGE_NAMED(@"") forState:UIControlStateNormal];
        [_publishBtn addTarget:self action:@selector(publishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}





@end
