//
//  PSPurchaseViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPurchaseViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSPurchaseCell.h"
#import "PSTipsConstants.h"
#import "PSCartViewController.h"
#import "PSSessionManager.h"

@interface PSPurchaseViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *cartTableView;

@end

@implementation PSPurchaseViewController
- (id)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*userCenterCart=NSLocalizedString(@"userCenterCart", @"购物记录");
         userCenterCart = NSLocalizedString(@"recharge_record", @"充值记录");
        self.title = userCenterCart;
    }
    return self;
}

- (void)buyCardAction {
    PSCartViewController *cartViewController = [[PSCartViewController alloc] initWithViewModel:[PSCartViewModel new]];
    [self.navigationController pushViewController:cartViewController animated:YES];
}

- (void)loadMore {
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    @weakify(self)
    [cartViewModel loadMorePurchaseCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [cartViewModel refreshPurchaseCompleted:^(PSResponse *response) {
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
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    if (cartViewModel.hasNextPage) {
        @weakify(self)
        self.cartTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.cartTableView.mj_footer = nil;
    }
    [self.cartTableView.mj_header endRefreshing];
    [self.cartTableView.mj_footer endRefreshing];
    [self.cartTableView reloadData];
}

- (void)renderContents {
    self.cartTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.cartTableView.dataSource = self;
    self.cartTableView.delegate = self;
    self.cartTableView.emptyDataSetSource = self;
    self.cartTableView.emptyDataSetDelegate = self;
    self.cartTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cartTableView.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.cartTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.cartTableView registerClass:[PSPurchaseCell class] forCellReuseIdentifier:@"PSPurchaseCell"];
    self.cartTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.cartTableView];
    [self.cartTableView mas_makeConstraints:^(MASConstraintMaker *make) {
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    return cartViewModel.purchases.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 205;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSPurchaseCell"];
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    PSPurchase *purchase = cartViewModel.purchases[indexPath.row];
    cell.orderNOLabel.text = [NSString stringWithFormat:@"订单编号：%@",purchase.tradeNo];
    NSString *payment = nil;
    if ([purchase.paymentType isEqualToString:@"weixin"]) {
        payment = @"微信支付";
    }else if ([purchase.paymentType isEqualToString:@"alipay"]) {
        payment = @"支付宝";
    }else{
        payment = @"未知支付";
    }
    NSInteger quantity = purchase.quantity == 0 ? 1 : purchase.quantity;
    cell.paymentLabel.text = [NSString stringWithFormat:@"支付方式：%@",payment];
    cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",purchase.amount / quantity];
    cell.quantityLabel.text = [NSString stringWithFormat:@"x%ld",(long)quantity];
    cell.timeLabel.text = purchase.gmtPayment;
    NSMutableAttributedString *infoString = [NSMutableAttributedString new];
    [infoString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"共%ld件商品 合计：",(long)quantity] attributes:@{NSFontAttributeName:FontOfSize(10),NSForegroundColorAttributeName:AppBaseTextColor1}]];
    [infoString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f",purchase.amount] attributes:@{NSFontAttributeName:FontOfSize(13),NSForegroundColorAttributeName:AppBaseTextColor1}]];
    cell.infoLabel.attributedText = infoString;
    @weakify(self)
    [cell.buyButton bk_whenTapped:^{
        @strongify(self)
        [self buyCardAction];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    UIImage *emptyImage = cartViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return cartViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    NSString *tips = cartViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return cartViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
    
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    return cartViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:@"点击加载" attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
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
