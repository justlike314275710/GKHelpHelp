
//
//  PSRefundViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "PSMyAdviceViewController.h"
#import "PSConsultationViewModel.h"
#import "PSRefundViewController.h"
#import "MJRefresh.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PSMyAdviceTableViewCell.h"
#import "PSConsultation.h"
#import "MJExtension.h"
#import "PSCustomer.h"
#import "PSSessionManager.h"

@interface PSMyAdviceViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic, strong) UITableView *honorTableView;
@end

@implementation PSMyAdviceViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title =@"我的咨询";
    }
    return self;
}

- (void)loadMore {
      PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
        @weakify(self)
    [viewModel loadMyAdviceCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)

    [viewModel refreshMyAdviceCompleted:^(PSResponse *response) {
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
     PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    //(PSTransactionRecordViewModel *)self.viewModel;
    if (viewModel.hasNextPage) {
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
     self.view.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
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
    [self.honorTableView registerClass:[PSMyAdviceTableViewCell class] forCellReuseIdentifier:@"PSMyAdviceTableViewCell"];
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
     PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    return viewModel.myAdviceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   PSMyAdviceTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PSMyAdviceTableViewCell"];
   PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    PSConsultation*Model=viewModel.myAdviceArray[indexPath.row];
    cell.moneyLab.text=[NSString stringWithFormat:@"¥%.2f",[Model.reward floatValue]];
    cell.contentLab.text=Model.des;
    cell.nameLab.text=[PSSessionManager sharedInstance].session.families.name?[PSSessionManager sharedInstance].session.families.name:[LXFileManager readUserDataForKey:@"phoneNumber"];;
    if ([Model.status isEqualToString:@"PENDING_PAYMENT"]) {
        [cell.statusButton setTitle:@"处理中" forState:0];
    }
    NSString*yearTime=[Model.createdTime substringToIndex:10];
     NSRange range1 = NSMakeRange(11, 5);
    NSString*minunteTime=[Model.createdTime substringWithRange:range1];
    cell.timeLab.text=[NSString stringWithFormat:@"%@ %@",yearTime,minunteTime];

    
    return cell;
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
     PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    UIImage *emptyImage = viewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return viewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    
    NSString *tips = viewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return viewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
     PSConsultationViewModel *viewModel =(PSConsultationViewModel *)self.viewModel;
    return viewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:@"点击加载" attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
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



