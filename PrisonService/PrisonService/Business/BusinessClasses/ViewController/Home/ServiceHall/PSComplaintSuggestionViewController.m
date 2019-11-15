//
//  PSComplaintSuggestionViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSComplaintSuggestionViewController.h"
#import "WMPageController.h"
#import "PSPublicityViewController.h"
#import "PSComplaintViewController.h"
#import "PSWriteComplaintViewController.h"
#import "PSWriteFeedbackListViewController.h"
#import "PSFeedbackListViewModel.h"
#import "PSWriteFeedbackViewController.h"

@interface PSComplaintSuggestionViewController ()<WMPageControllerDataSource>

@property (nonatomic, strong) WMPageController *contentViewController;

@end

@implementation PSComplaintSuggestionViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
         NSString*complain_advice=NSLocalizedString(@"complain_advice", @"投诉建议");
        self.title = complain_advice;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
//    UIBarButtonItem *rightBtn =[self.navigationItem.rightBarButtonItems objectAtIndex:0];
//    rightBtn.customView.hidden = NO;
}

- (void)writeComplaintAndSuggestion {
//    PSWriteSuggestionViewModel
    /*
    PSWriteComplaintViewController *complaintViewController = [[PSWriteComplaintViewController alloc] initWithViewModel:[PSWriteSuggestionViewModel new]];
    @weakify(self)
    [complaintViewController setSendCompleted:^{
        @strongify(self)
        [self.contentViewController reloadData];
        self.contentViewController.selectIndex = 1;
    }];
    [self.navigationController pushViewController:complaintViewController animated:YES];
     */
    PSFeedbackViewModel *viewModel = [PSFeedbackViewModel new];
    viewModel.writefeedType = PSPrisonfeedBack;
    PSWriteFeedbackViewController *feedbackViewController = [[PSWriteFeedbackViewController alloc] initWithViewModel:viewModel];
    [self.navigationController pushViewController:feedbackViewController animated:YES];
    [SDTrackTool logEvent:TSJY_PAGE_TXYJFK];
}

- (void)renderContents {
    [self createRightBarButtonItemWithTarget:self action:@selector(writeComplaintAndSuggestion) normalImage:[UIImage imageNamed:@"serviceHallWriteIcon"] highlightedImage:nil];
    _contentViewController = [WMPageController new];
    _contentViewController.dataSource = self;
    _contentViewController.menuViewStyle = WMMenuViewStyleLine;
    _contentViewController.menuViewContentMargin = 10;
    _contentViewController.progressHeight = 0.5;
    _contentViewController.titleSizeSelected = 15;
    _contentViewController.titleSizeNormal = 15;
    _contentViewController.titleColorSelected = AppBaseTextColor1;
    _contentViewController.titleColorNormal = AppBaseTextColor2;
    _contentViewController.progressColor = AppBaseTextColor1;
    _contentViewController.pageAnimatable = YES;
    _contentViewController.automaticallyCalculatesItemWidths = YES;
    [self.view addSubview:_contentViewController.view];
    [_contentViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    UIBarButtonItem *rightBtn =[self.navigationItem.rightBarButtonItems objectAtIndex:0];
//    rightBtn.customView.hidden = YES;;
}


- (BOOL)hiddenNavigationBar {
    return NO;
}


#pragma mark -
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return 2;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    NSString*public_information=NSLocalizedString(@"public_information", @"公示信息");
    NSString*complaint_feedback=NSLocalizedString(@"complain_advice", @"投诉建议");
    NSString *eventid = index==0?TSJY_PAGE_GSXX:TSJY_PAGE_TSJY;
    [SDTrackTool logEvent:eventid];
    return index == 0 ? public_information : complaint_feedback;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = nil;
    if (index == 0) {
        viewController = [[PSPublicityViewController alloc] initWithViewModel:self.viewModel];
    }else{
//        viewController = [[PSComplaintViewController alloc] initWithViewModel:[PSSuggestionViewModel new]];
//
        PSFeedbackListViewModel *viewModel = [PSFeedbackListViewModel new];
        viewModel.writefeedType = PSPrisonfeedBack;
        viewController = [[PSWriteFeedbackListViewController alloc] initWithViewModel:viewModel];
    }
    return viewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
