//
//  PSAllHistoryViewController.m
//  PrisonService
//
//  Created by kky on 2019/5/30.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSAllHistoryViewController.h"
#import "PSHistoryViewController.h"
#import "LegaladviceViewController.h"
#import "ZWTopSelectButton.h"
#import "ZWTopSelectVcView.h"
#import "PSMyAdviceViewController.h"
#import "PSConsultationViewModel.h"
#import "LawyerAdviceViewController.h"
#import "UIColor+HexString.h"
#import "PSMeetingHistoryViewModel.h"
#import "PSLocalHistoryViewContller.h"
#import "PSLocalMeetingHistoryViewModel.h"

@interface PSAllHistoryViewController ()<ZWTopSelectVcViewDataSource,ZWTopSelectVcViewDelegate> {
    BOOL              isChangeChildVc;
    int               selectIndex;
    UIViewController *selectViewController;
}
@property (nonatomic, strong) ZWTopSelectVcView *topSelectVcView;

@end

@implementation PSAllHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会见历史";
    [self setupUI];
}

#pragma mark - PrivateMethods
- (void)setupUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    ZWTopSelectVcView *topSelectVcView=[[ZWTopSelectVcView alloc]init];
    self.topSelectVcView.isCloseSwipeGesture = YES;
    topSelectVcView.frame=CGRectMake(0,14,KScreenWidth,KScreenHeight);
    [self.view addSubview:topSelectVcView];
    self.topSelectVcView=topSelectVcView;
    self.topSelectVcView.dataSource=self;
    self.topSelectVcView.delegate=self;
    [self.topSelectVcView setupZWTopSelectVcViewUI];
    self.topSelectVcView.animationType=Push;
}

#pragma mark - ZWTopSelectVcViewDelegate
- (void)topSelectVcView:(ZWTopSelectVcView *)topSelectVcView didSelectVc:(UIViewController *)selectVc atIndex:(int)index
{
    selectIndex = index;
    selectViewController = selectVc;
}

#pragma mark - ZWTopSelectVcViewDataSource
//初始化设置
-(NSMutableArray *)totalControllerInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcView
{
    NSMutableArray *controllerMutableArr=[NSMutableArray array];
    PSHistoryViewController*showoneVc =[[PSHistoryViewController alloc]initWithViewModel:[[PSMeetingHistoryViewModel alloc]init]];
    showoneVc.title=@"远程探视";
    [controllerMutableArr addObject:showoneVc];
    
    PSLocalHistoryViewContller*showtwoVc =[[PSLocalHistoryViewContller alloc]initWithViewModel:[[PSLocalMeetingHistoryViewModel alloc]init]];
    showtwoVc.title=@"实地会见";
    [controllerMutableArr addObject:showtwoVc];
    
    return controllerMutableArr;
}

//（可选）初始化展示第几个控制器（默认第一个，以UIViewController查找，优先级高）
-(UIViewController *)showChildViewVcNameInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcView
{
    return selectViewController;
}
//顶部按钮间隔线颜色
-(UIColor *)topSliderLineSpacingColorInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcViedew
{
    return [UIColor clearColor];
}
//顶部按钮文字选中背景色设置
-(UIColor *)topSliderViewSelectedTitleColorInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcViedew
{
    return UIColorFromRGB(38, 76, 144);
}
//顶部按钮文字未选中背景色设置
-(UIColor *)topSliderViewNotSelectedTitleColorInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcViedew
{
    return  UIColorFromRGB(102,102,102);
}
//顶部滑块背景设置
-(UIColor *)topSliderViewBackGroundColorInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcView
{
    return UIColorFromRGB(38, 76, 144);
}

-(CGFloat)topSliderViewHeightZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcView {
    return 1.f;
}

-(CGFloat)topViewHeightInZWTopSelectVcView:(ZWTopSelectVcView *)topSelectVcView {
    return 35;
}

#pragma mark - Setting&Getting





@end
