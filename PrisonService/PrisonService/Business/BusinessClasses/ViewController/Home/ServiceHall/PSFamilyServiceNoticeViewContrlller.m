//
//  PSFamilyServiceNoticeViewContrlller.m
//  PrisonService
//
//  Created by kky on 2019/5/30.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSFamilyServiceNoticeViewContrlller.h"
#import "MJRefresh.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSFamilyServiceNoticeCell.h"
#import "PSTipsConstants.h"
#import "PSFamilyServiceNoticeModel.h"
#import "PSFamilyServiceNoticeViewModel.h"
#import "PSCancelReasonView.h"


@interface PSFamilyServiceNoticeViewContrlller ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
{
    
}
@property(nonatomic,strong)UITableView *myTableview;


@end

@implementation PSFamilyServiceNoticeViewContrlller

#pragma mark - LifeCycle
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*family_server=@"服务通知";
        self.title = family_server;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)loadMore {
    PSFamilyServiceNoticeViewModel *meetingHistoryModel =(PSFamilyServiceNoticeViewModel *)self.viewModel;
    @weakify(self)
    [meetingHistoryModel loadMoreRefundCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}
- (void)refreshData {
    PSFamilyServiceNoticeViewModel *meetingHistoryModel =(PSFamilyServiceNoticeViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance]show];
    @weakify(self)
    
    [meetingHistoryModel refreshRefundCompleted:^(PSResponse *response) {
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
    PSFamilyServiceNoticeViewModel *meetingHistoryModel =(PSFamilyServiceNoticeViewModel *)self.viewModel;
    if (meetingHistoryModel.hasNextPage) {
        @weakify(self)
        self.myTableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.myTableview.mj_footer = nil;
    }
    [self.myTableview.mj_header endRefreshing];
    [self.myTableview.mj_footer endRefreshing];
    [self.myTableview reloadData];
}
- (void)renderContents {
    self.view.backgroundColor=[UIColor whiteColor];
    self.myTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.myTableview.dataSource = self;
    self.myTableview.delegate = self;
    self.myTableview.emptyDataSetSource = self;
    self.myTableview.emptyDataSetDelegate = self;
    self.myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableview.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.myTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.myTableview registerClass:[PSFamilyServiceNoticeCell class] forCellReuseIdentifier:@"PSFamilyServiceNoticeCell"];
    self.myTableview.tableFooterView = [UIView new];
    [self.view addSubview:self.myTableview];
    [self.myTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSFamilyServiceNoticeViewModel *meetingHistoryModel =(PSFamilyServiceNoticeViewModel *)self.viewModel;
    return meetingHistoryModel.meeetHistorys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSFamilyServiceNoticeViewModel *meetingHistoryModel =(PSFamilyServiceNoticeViewModel *)self.viewModel;
    PSFamilyServiceNoticeModel *MeettingHistory= meetingHistoryModel.meeetHistorys[indexPath.row];
    NSString *str = MeettingHistory.remarks ;//你想显示的字符串
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize: 12] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    if ([MeettingHistory.status isEqualToString:@"DENIED"]) { //已拒绝
        return size.height + 150;
    } else {
         return size.height + 135;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSFamilyServiceNoticeCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PSFamilyServiceNoticeCell"];
    PSFamilyServiceNoticeViewModel *meetingHistoryModel =(PSFamilyServiceNoticeViewModel *)self.viewModel;
    PSFamilyServiceNoticeModel *MeettingHistory= meetingHistoryModel.meeetHistorys[indexPath.row];
    cell.model = MeettingHistory;
    return cell;
}



#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSFamilyServiceNoticeViewModel *historyViewModel = (PSFamilyServiceNoticeViewModel *)self.viewModel;
    UIImage *emptyImage = historyViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return historyViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSFamilyServiceNoticeViewModel *historyViewModel = (PSFamilyServiceNoticeViewModel *)self.viewModel;
    NSString *tips = historyViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return historyViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
    
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSFamilyServiceNoticeViewModel *historyViewModel = (PSFamilyServiceNoticeViewModel *)self.viewModel;
    return historyViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}



@end
