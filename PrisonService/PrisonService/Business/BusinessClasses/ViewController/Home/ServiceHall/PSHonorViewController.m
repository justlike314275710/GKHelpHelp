//
//  PSHonorViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSHonorViewController.h"
#import "PSHonorCell.h"
#import "NSString+Date.h"
#import "NSDate+Components.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"

@interface PSHonorViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *honorTableView;

@end

@implementation PSHonorViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"年度荣誉";
    }
    return self;
}

- (void)loadMore {
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    @weakify(self)
    [rewardViewModel loadMoreRewardsCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [rewardViewModel refreshRewardsCompleted:^(PSResponse *response) {
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
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    if (rewardViewModel.hasNextPage) {
        @weakify(self)
        self.honorTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.honorTableView.mj_footer = nil;
    }
    [self.honorTableView.mj_header endRefreshing];
    [self.honorTableView.mj_footer endRefreshing];
    [self.honorTableView reloadData];
}

- (void)renderContents {
    _honorTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.honorTableView.dataSource = self;
    self.honorTableView.delegate = self;
    self.honorTableView.emptyDataSetSource = self;
    self.honorTableView.emptyDataSetDelegate = self;
    self.honorTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.honorTableView.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.honorTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.honorTableView registerClass:[PSHonorCell class] forCellReuseIdentifier:@"PSHonorCell"];
    self.honorTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.honorTableView];
    [self.honorTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
    [self refreshData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    return rewardViewModel.rewardsAndPunishments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSHonorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSHonorCell"];
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    PSRewardAndPunishment *rewardPunishment = rewardViewModel.rewardsAndPunishments[indexPath.row];
    cell.dateLabel.text = [[rewardPunishment.datayear stringToDateWithFormat:@"yyyy-MM-dd"] yearString];
    cell.honorLabel.text = rewardPunishment.ndry;
    return cell;
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    UIImage *emptyImage = rewardViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return rewardViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    NSString *tips = rewardViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return rewardViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSRewardAndPunishmentViewModel *rewardViewModel = (PSRewardAndPunishmentViewModel *)self.viewModel;
    return rewardViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
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
