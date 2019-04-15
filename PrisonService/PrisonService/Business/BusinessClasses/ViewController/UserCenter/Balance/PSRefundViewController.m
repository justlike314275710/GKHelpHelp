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
#import "NSDate+Components.h"
@interface PSRefundViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic, strong) UITableView *honorTableView;
@end

@implementation PSRefundViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*Transaction_details=NSLocalizedString(@"Transaction_details", @"交易明细");
        Transaction_details = NSLocalizedString(@"Account_details", @"远程探视卡明细");
//        Transaction_details = NSLocalizedString(@"Bill", @"账单");
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
    _honorTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.honorTableView.dataSource = self;
    self.honorTableView.delegate = self;
    self.honorTableView.emptyDataSetSource = self;
    self.honorTableView.emptyDataSetDelegate = self;
    self.honorTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.honorTableView.backgroundColor = [UIColor clearColor];
    self.honorTableView.tableFooterView = [UIView new];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    return rewardViewModel.transMonths.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 1)];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    PSTransactionRecord *model = rewardViewModel.transMonths[section][0];
    NSString *createdMonth = model.createdMonth;
    NSString *refundTotal = model.refundTotal; //退款
    NSString *rechargeTotal = model.rechargeTotal; //充值
    NSString *consumeTotal = model.consumeTotal; //消费
    
    NSDate *date = [NSDate date];
    NSString *nowMonth= [date dateStringWithFormat:@"yyyy-MM"];
    if ([nowMonth isEqualToString:model.createdMonth]) {
        NSString *this_month = NSLocalizedString(@"This month", @"本月");
        createdMonth = this_month;
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 60)];
    headView.backgroundColor = UIColorFromRGB(249, 248, 254);
    UILabel *monthLab = [[UILabel alloc] initWithFrame:CGRectMake(15,0, 200, 20)];
    monthLab.textAlignment = NSTextAlignmentLeft;
    monthLab.font = FontOfSize(12);
    monthLab.textColor = UIColorFromRGB(51,51,51);
    monthLab.text = createdMonth;
    [headView addSubview:monthLab];
    
    
    NSString *Recharge = NSLocalizedString(@"Recharge", @"充值");
    NSString *refund = NSLocalizedString(@"refund", @"退款");
    NSString *consumption = NSLocalizedString(@"consumption", @"消费");
    
    NSString *text = [NSString stringWithFormat:@"%@%.2f元 %@%.2f元 %@%.2f元",Recharge,[rechargeTotal floatValue],refund,[refundTotal floatValue],consumption,[consumeTotal floatValue]];
    if ([NSObject judegeIsVietnamVersion]) {
        text = [NSString stringWithFormat:@"%@%.2f %@%.2f %@%.2f",Recharge,[rechargeTotal floatValue],refund,[refundTotal floatValue],consumption,[consumeTotal floatValue]];
    }
    UILabel *czLab = [[UILabel alloc] initWithFrame:CGRectMake(15, monthLab.bottom,headView.width-15,20)];
    czLab.text = text;
    czLab.textAlignment = NSTextAlignmentLeft;
    czLab.font = FontOfSize(10);
    czLab.textColor = UIColorFromRGB(153, 153, 153);
    [headView addSubview:czLab];

    return headView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSTransactionRecordViewModel *rewardViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    NSArray *month = rewardViewModel.transMonths;
    NSArray *monthItem = month[section];
    return monthItem.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSRefundCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PSRefundCell"];
    PSTransactionRecordViewModel *recordViewModel =(PSTransactionRecordViewModel *)self.viewModel;
    NSArray *month = recordViewModel.transMonths;
    NSArray *monthItem = month[indexPath.section];
    PSTransactionRecord *recordModel = monthItem[indexPath.row];
    cell.dateLabel.text=[recordModel.createdAt timestampToDateDetailString];
    cell.titleLabel.text=recordModel.reason;
    cell.contentLabel.text=recordModel.money;
    if (recordModel.paymentType.length&&recordModel.paymentType.length>0) {
        NSString *payway = NSLocalizedString(@"payment method", @"支付方式");
        NSString *wxStr = NSLocalizedString(@"WeChat", @"微信");
        NSString *aliPay = NSLocalizedString(@"Alipay", @"支付宝");
        if ([recordModel.paymentType isEqualToString:@"weixin"]) {
            NSString *payString = [NSString stringWithFormat:@"%@: %@",payway,wxStr];
            cell.payWayLab.text = payString;
        } else {
            NSString *payString = [NSString stringWithFormat:@"%@: %@",payway,aliPay];
            cell.payWayLab.text = payString;
        }
    } else {
        cell.payWayLab.text = @"";
        cell.dateLabel.text = @"";
        cell.payWayLab.text=[recordModel.createdAt timestampToDateDetailString];
    }
    if (recordModel.orderNo&&recordModel.orderNo.length>0) {
        NSString *orderStr = NSLocalizedString(@"Order number", @"订单编号");
        NSString *orderNO = [NSString stringWithFormat:@"%@: %@",orderStr,recordModel.orderNo];
        cell.orderNoLab.text = orderNO;
    } else {
        cell.orderNoLab.text = @"";
    }
    if ([recordModel.money containsString:@"+"]) {
        cell.contentLabel.textColor =  [UIColor redColor];
    } else {
        cell.contentLabel.textColor =  UIColorFromRGB(51, 51, 51);
    }
    
    
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
    return rewardViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}



@end
