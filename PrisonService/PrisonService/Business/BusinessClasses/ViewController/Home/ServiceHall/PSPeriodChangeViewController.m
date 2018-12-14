//
//  PSPeriodChangeViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPeriodChangeViewController.h"
#import "PSPeriodChangeCell.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"

@interface PSPeriodChangeViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *periodTableView;

@end

@implementation PSPeriodChangeViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"刑期变动";
    }
    return self;
}

- (void)loadMore {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    @weakify(self)
    [periodViewModel loadMorePeriodChangesCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [periodViewModel refreshPeriodChangesCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    }];
}

- (void)reloadContents {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    if (periodViewModel.hasNextPage) {
        @weakify(self)
        self.periodTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.periodTableView.mj_footer = nil;
    }
    [self.periodTableView.mj_header endRefreshing];
    [self.periodTableView.mj_footer endRefreshing];
    [self.periodTableView reloadData];
}

- (void)renderContents {
    _periodTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.periodTableView.dataSource = self;
    self.periodTableView.delegate = self;
    self.periodTableView.emptyDataSetSource = self;
    self.periodTableView.emptyDataSetDelegate = self;
    self.periodTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.periodTableView.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.periodTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.periodTableView registerClass:[PSPeriodChangeCell class] forCellReuseIdentifier:@"PSPeriodChangeCell"];
    self.periodTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.periodTableView];
    [self.periodTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
    [self refreshData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    return periodViewModel.periodChanges.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSPeriodChangeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSPeriodChangeCell"];
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    PSPeriodChange *period = periodViewModel.periodChanges[indexPath.row];
    cell.startDateLabel.text = [period.updatedAt timestampToDateString];
    cell.rangeLabel.text = [NSString stringWithFormat:@"%ld年%ld月%ld日",(long)period.changeyear,(long)period.changemonth,(long)period.changeday];
    cell.typeLabel.text = period.changetype;
    NSString *endDate = period.termFinish.length > 10 ? [period.termFinish substringToIndex:10] : nil;
    cell.endDateLabel.text = endDate;
    return cell;
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    UIImage *emptyImage = periodViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return periodViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    NSString *tips = periodViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return periodViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSPeriodChangeViewModel *periodViewModel = (PSPeriodChangeViewModel *)self.viewModel;
    return periodViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
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
