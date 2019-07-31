//
//  PSWorkViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWorkViewController.h"
#import "PSWorkCell.h"
#import "NSString+Date.h"
#import "PSWebViewController.h"
#import "PSBusinessConstants.h"
#import "PSContentManager.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"
#import "UIViewController+Tool.h"
#import "PSPrisonOpenCell.h"

@interface PSWorkViewController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property(nonatomic,strong)UIImageView *contentImg;



@end

@implementation PSWorkViewController

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMore {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    workViewModel.jailId=self.jailId;
    @weakify(self)
    [workViewModel loadMoreNewsCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    workViewModel.jailId=self.jailId;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    if ([self showAdv]) {
        [workViewModel refreshAllDataCompleted:^(PSResponse *response) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        } failed:^(NSError *error) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        }];
    }else{
        [workViewModel refreshNewsCompleted:^(PSResponse *response) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        } failed:^(NSError *error) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self updateUI];
        }];
    }
}

- (void)updateUI {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    if ([self showAdv]) {
        if (workViewModel.newsType==1||workViewModel.newsType==2||workViewModel.newsType==3) {
            _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.55467) imageURLStringsGroup:nil];
            _advView.backgroundColor = UIColorFromRGB(249, 248, 254);
            
            NSString*serviceHallAdvDefault=NSLocalizedString(@"serviceHallAdvDefault", @"工作动态");
            _advView.placeholderImage = [UIImage imageNamed:@"狱务公开头图1"];
            _advView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
            self.contentImg.frame = CGRectMake((_advView.width-217)/2,(_advView.height-34)/2,217,34);
            [self shakeToShow:self.contentImg];
            self.contentImg.image = [UIImage imageNamed:@"为了公平正义"];
            [_advView addSubview:self.contentImg];
            
            
            self.workTableView.tableHeaderView = _advView;
        }
    }else{
        self.workTableView.tableHeaderView = nil;
    }
    [self reloadContents];
}

- (void)shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 4;// 动画时间
    animation.repeatCount = 1000;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];// 这三个数字，我只研究了前两个，所以最后一个数字我还是按照它原来写1.0；前两个是控制view的大小的；
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}



-(UIImageView *)contentImg{
    if (!_contentImg) {
        _contentImg = [UIImageView new];
    }
    return _contentImg;
}


- (void)reloadContents {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    if (workViewModel.hasNextPage) {
        @weakify(self)
        self.workTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.workTableView.mj_footer = nil;
    }
    [self.workTableView.mj_header endRefreshing];
    [self.workTableView.mj_footer endRefreshing];
    [self.workTableView reloadData];
}

- (void)renderContents {
    _workTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.workTableView.dataSource = self;
    self.workTableView.delegate = self;
    self.workTableView.emptyDataSetSource = self;
    self.workTableView.emptyDataSetDelegate = self;
    self.workTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.workTableView.backgroundColor = UIColorFromRGB(249, 248, 254);
    @weakify(self)
    self.workTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.workTableView registerClass:[PSWorkCell class] forCellReuseIdentifier:@"PSWorkCell"];
    self.workTableView.tableFooterView = [UIView new];
    if (@available(iOS 11.0, *)) {
        self.workTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.workTableView];
    [self.workTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImage:[UIImage imageNamed:@"userCenterAccountBack"] forState:UIControlStateNormal];
    [self.view addSubview:_backButton];
    _backButton.hidden = YES;
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.top.mas_equalTo(10);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_backButton.mas_top);
        make.bottom.mas_equalTo(_backButton.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(100);
    }];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
}

//- (void)setTitimeNSString *)title {
//
//   _titleLabel.text = title;
//}

- (BOOL)showAdv {
    return YES;
}

//- (BOOL)hiddenNavigationBar {
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
    [self refreshData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self shakeToShow:self.contentImg];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    return workViewModel.newsData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    PSWorkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSWorkCell"];
    PSNews *news = workViewModel.newsData[indexPath.row];
    NSString *format = [NSObject judegeIsVietnamVersion]?@"MM-dd":@"MM月dd号";
    cell.dateLabel.text = [news.createdAt timestampToDateString:format];
    
    cell.titleLabel.text = news.title;
    cell.detailLabel.text = news.summary;
    cell.prisonLabel.text = self.jailName;
    if (cell.prisonLabel.text.length<=0) {
        NSInteger index = workViewModel.selectedPrisonerIndex;
        PSPrisonerDetail *prisonerDetail = nil;
        if (index >= 0 && index < workViewModel.passedPrisonerDetails.count) {
            prisonerDetail = workViewModel.passedPrisonerDetails[index];
            cell.prisonLabel.text = prisonerDetail.jailName;
        }
    }
    if ([cell.prisonLabel.text hasSuffix:@"▼"]&&cell.prisonLabel.text.length > 1) {
        cell.prisonLabel.text = [cell.prisonLabel.text substringToIndex:cell.prisonLabel.text.length-1];
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    PSNews *news = workViewModel.newsData[indexPath.row];
    NSString *url = [NSString stringWithFormat:@"%@/%@?t=%@",NewsUrl,news.id,[NSDate getNowTimeTimestamp]];
    PSWebViewController *newsDetailViewController = [[PSWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    newsDetailViewController.enableUpdateTitle = NO;
    if (workViewModel.newsType==1) {
        NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
        newsDetailViewController.title = prison_opening;
    }
    else if (workViewModel.newsType==2){
        NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
        newsDetailViewController.title=work_dynamic;
    }
    else if (workViewModel.newsType==3) {
//         newsDetailViewController.title = @"新闻详情";
           NSString*public_information=NSLocalizedString(@"public_information", @"公示信息");
        newsDetailViewController.title = public_information;
    }
    else if (workViewModel.newsType==4) {
        //         newsDetailViewController.title = @"新闻详情";
        NSString*public_information=NSLocalizedString(@"public_information", @"公示信息");
        newsDetailViewController.title = @"减刑假释";
    }
    else if (workViewModel.newsType==5) {
        //         newsDetailViewController.title = @"新闻详情";
        NSString*public_information=NSLocalizedString(@"public_information", @"公示信息");
        newsDetailViewController.title = @"暂予监外执行";
    }  else if  (workViewModel.newsType==6) {
        //         newsDetailViewController.title = @"新闻详情";
        NSString*public_information=NSLocalizedString(@"public_information", @"公示信息");
        newsDetailViewController.title = @"社会帮教";
    }
    
    
    if (workViewModel.newsType == 3) {
        //获取当前显示的控制器
        UIViewController *VC = [UIViewController jsd_getCurrentViewController];
        [VC.navigationController pushViewController:newsDetailViewController animated:YES];
    } else {
        newsDetailViewController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:newsDetailViewController animated:YES];
        newsDetailViewController.hidesBottomBarWhenPushed=NO;
    }


}


#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    UIImage *emptyImage = workViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return workViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    NSString *tips = workViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return workViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];

}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSWorkViewModel *workViewModel = (PSWorkViewModel *)self.viewModel;
    return workViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}


@end
