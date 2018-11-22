//
//  PSRefundViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRefundViewController.h"
#import "MJRefresh.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PSTransactionRecordViewModel.h"
#import "PSTransactionRecord.h"
#import "PSRefundCell.h"

@interface PSRefundViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic, strong) UITableView *honorTableView;
@end

@implementation PSRefundViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*Transaction_details=NSLocalizedString(@"Transaction_details", @"交易明细");
        Transaction_details = NSLocalizedString(@"Account_details", @"账号明细");
        self.title = Transaction_details;
    }
    return self;
}

- (void)loadMore {
    PSTransactionRecordViewModel *rewardViewModel = (PSTransactionRecordViewModel *)self.viewModel;
    @weakify(self)
    [rewardViewModel loadMoreRefundCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [rewardViewModel refreshRefundCompleted:^(PSResponse *response) {
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
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    //(PSTransactionRecordViewModel *)self.viewModel;
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
    [self.honorTableView registerClass:[PSRefundCell class] forCellReuseIdentifier:@"PSRefundCell"];
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
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    return rewardViewModel.transactionRecords.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSRefundCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PSRefundCell"];
    PSTransactionRecordViewModel *recordViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    PSTransactionRecord *recordModel = recordViewModel.transactionRecords[indexPath.row];
    cell.dateLabel.text=[recordModel.createdAt timestampToDateString];
    cell.titleLabel.text=recordModel.reason;
    cell.contentLabel.text=recordModel.money;
    
    return cell;
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    UIImage *emptyImage = rewardViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return rewardViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
  
    NSString *tips = rewardViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return rewardViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    return rewardViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:@"点击加载" attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
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


@end
