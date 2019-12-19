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
#import "PSMeetJailsnnmeViewModel.h"
#import "PSBuyCardView.h"
#import "PSPayView.h"
#import "PSAlertView.h"
#import "PSPayInfo.h"
#import "PSPayCenter.h"
#import "PSBusinessConstants.h"

@interface PSPurchaseViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *cartTableView;
@property (nonatomic , strong)PSBuyCardView *buyCardView;
@property (nonatomic, strong) PSCartViewModel *cartViewModel;
@property (nonatomic, strong) PSPrisonerDetail *prisonerDetail;
@property (nonatomic, strong) PSBuyModel *buyModel;
@property (nonatomic, strong) PSPayView *payView;

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
//    PSCartViewController *cartViewController = [[PSCartViewController alloc] initWithViewModel:[PSCartViewModel new]];
//    [self.navigationController pushViewController:cartViewController animated:YES];
    
     [self requestInfoPhoneCard];
}

- (void)requestInfoPhoneCard {
    
    self.cartViewModel = [PSCartViewModel new];
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [self.cartViewModel requestPhoneCardCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self payTips];
        //        [self renderContents];
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
        //        [self renderContents];
    }];
}

-(void)payTips{
    _prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        _prisonerDetail = details[index];
    }
    PSMeetJailsnnmeViewModel*meetJailsnnmeViewModel=[[PSMeetJailsnnmeViewModel alloc]init];
    [meetJailsnnmeViewModel requestMeetJailsterCompleted:^(PSResponse *response) {
        NSString*notice_title=NSLocalizedString(@"notice_title", @"提请注意");
        NSString*notice_content=NSLocalizedString(@"notice_content", @"您购买的远程探视卡将用于与%@的视频会见");
        NSString*notice_agreed=NSLocalizedString(@"notice_agreed", @"确定");
        NSString*notice_disagreed=NSLocalizedString(@"notice_disagreed", @"取消");
        [PSAlertView showWithTitle:notice_title message:[NSString stringWithFormat:notice_content,meetJailsnnmeViewModel.jailsSting] messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self settlementAction:meetJailsnnmeViewModel.jailsSting];
            }
        } buttonTitles:notice_disagreed,notice_agreed, nil];
    } failed:^(NSError *error) {
        
        if (error.code>=500) {
            [self showNetError:error];
        } else {
            NSString *tips = NSLocalizedString(@"Unable to connect to server, please check network settings",@"无法连接到服务器,请检查网络设置");
            [PSTipsView showTips:tips];
        }
    }];
}

- (void)settlementAction:(NSString *)prison_names {
    if (self.cartViewModel.quantity > 0 &&self.cartViewModel.amount>0) {
        _buyModel = [[PSBuyModel alloc] init];
        _buyModel.family_members = [PSSessionManager sharedInstance].session.families.name;
        _buyModel.Amount_of_money = self.cartViewModel.amount;
        _buyModel.Inmates = prison_names;
        _buyModel.Prison_name = _prisonerDetail.jailName;
         self.buyCardView.buyModel = _buyModel;
        [self.buyCardView showView:self];
        
    }else{
        if (self.cartViewModel.amount==0) {
            NSString *msg = NSLocalizedString(@"The prison is a free meeting with the prison, no need to buy", @"该监狱为免费会见监狱,无需购买");
            [PSTipsView showTips:msg];
        } else {
            NSString *msg = NSLocalizedString(@"Please select the item you want to buy", @"请选中您要购买的商品");
            [PSTipsView showTips:msg];
        }
    }
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
    
//    "Order number"="订单编号";
//    "buy again"="再次购买";
//    "total"="合计";
//    "payment method"="支付方式";
//    "Total %ld items"="共%ld件商品";
    
    
    NSString *order_number = NSLocalizedString(@"Order number", @"订单编号");
    NSString *payMethod = NSLocalizedString(@"payment method", @"支付方式");
    NSString *total = NSLocalizedString(@"total", @"合计");
    NSString *total_ld = NSLocalizedString(@"Total %ld items", @"支付方式");
    NSString *totalStr = [NSString stringWithFormat:@"%@, %@: ",total_ld,total];
    
    PSPurchaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSPurchaseCell"];
    PSPurchaseViewModel *cartViewModel = (PSPurchaseViewModel *)self.viewModel;
    PSPurchase *purchase = cartViewModel.purchases[indexPath.row];
    cell.orderNOLabel.text = [NSString stringWithFormat:@"%@：%@",order_number,purchase.tradeNo];
    NSString *payment = nil;
    if ([purchase.paymentType isEqualToString:@"weixin"]) {
        payment = NSLocalizedString(@"weChat_payment", @"微信支付");
    }else if ([purchase.paymentType isEqualToString:@"alipay"]) {
        payment = NSLocalizedString(@"Alipay", @"支付宝");
    }else{
        payment = NSLocalizedString(@"UnknownPayment", @"未知支付");
    }
    NSInteger quantity = purchase.quantity == 0 ? 1 : purchase.quantity;
    cell.paymentLabel.text = [NSString stringWithFormat:@"%@：%@",payMethod,payment];
    cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",purchase.amount / quantity];
    cell.quantityLabel.text = [NSString stringWithFormat:@"x%ld",(long)quantity];
    cell.timeLabel.text = purchase.gmtPayment;
    NSMutableAttributedString *infoString = [NSMutableAttributedString new];
    [infoString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:totalStr,(long)quantity] attributes:@{NSFontAttributeName:FontOfSize(10),NSForegroundColorAttributeName:AppBaseTextColor1}]];
    [infoString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f",purchase.amount] attributes:@{NSFontAttributeName:FontOfSize(13),NSForegroundColorAttributeName:AppBaseTextColor1}]];
    cell.infoLabel.attributedText = infoString;
    @weakify(self)
    [cell.buyButton bk_whenTapped:^{
        @strongify(self)
        [SDTrackTool logEvent:YCTS_PAGE_ZCGM];
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
    return cartViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
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

- (void)buyCard:(NSInteger)index {
    
    PSCartViewModel *cartViewModel = self.cartViewModel;
    cartViewModel.amount = index*_buyModel.Amount_of_money;
    cartViewModel.totalQuantity = index;
    PSPayView *payView = [PSPayView new];
    [payView setGetAmount:^CGFloat{
        return index*_buyModel.Amount_of_money;
    }];
    [payView setGetRows:^NSInteger{
        return cartViewModel.payments.count;
    }];
    [payView setGetSelectedIndex:^NSInteger{
        return cartViewModel.selectedPaymentIndex;
    }];
    [payView setGetIcon:^UIImage *(NSInteger index) {
        PSPayment *payment = cartViewModel.payments.count > index ? cartViewModel.payments[index] : nil;
        return payment ? [UIImage imageNamed:payment.iconName] : nil;
    }];
    [payView setGetName:^NSString *(NSInteger index) {
        PSPayment *payment = cartViewModel.payments.count > index ? cartViewModel.payments[index] : nil;
        return payment ? payment.name : nil;
    }];
    [payView setSeletedPayment:^(NSInteger index) {
        cartViewModel.selectedPaymentIndex = index;
    }];
    @weakify(self)
    [payView setGoPay:^{
        @strongify(self)
        [self goPay];
    }];
    [payView showAnimated:YES];
    _payView = payView;
}

- (void)goPay {
    PSCartViewModel *cartViewModel = self.cartViewModel;
    NSInteger selectedIndex = cartViewModel.selectedPaymentIndex;
    if (selectedIndex >= 0 && selectedIndex < cartViewModel.payments.count) {
        if (cartViewModel.products.count > 0) {
            PSProduct *product = cartViewModel.products[0];
            if (product.selected) {
                PSPayment *paymentInfo = cartViewModel.payments[selectedIndex];
                PSPayInfo *payInfo = [PSPayInfo new];
                payInfo.familyId = [PSSessionManager sharedInstance].session.families.id;
                payInfo.jailId = cartViewModel.prisonerDetail.jailId;
                payInfo.productID = product.id;
                payInfo.amount = cartViewModel.amount;
                payInfo.productName = product.title;
                payInfo.quantity = cartViewModel.quantity;
                payInfo.payment = paymentInfo.payment;
                [[PSLoadingView sharedInstance] show];
                @weakify(self)
                [[PSPayCenter payCenter] goPayWithPayInfo:payInfo type:PayTypeBuy callback:^(BOOL result, NSError *error) {
                    @strongify(self)
                    [[PSLoadingView sharedInstance] dismiss];
                    [[PSSessionManager sharedInstance] synchronizeUserBalance];
                    if (error) {
                        if (error.code != 106 && error.code != 206) {
                            [PSTipsView showTips:error.domain];
                            [SDTrackTool logEvent:BUY_FAMILY_CARD attributes:@{STATUS:MobFAILURE,ERROR_STR:error.domain?error.domain:@"",PAY_TYPE:payInfo.payment}];
                        }
                    }else{
                        [self.navigationController popViewControllerAnimated:NO];
                        self.payView.status = PSPaySuccessful;
                        [SDTrackTool logEvent:BUY_FAMILY_CARD attributes:@{STATUS:MobSUCCESS,PAY_TYPE:payInfo.payment}];
                        [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
                    }
                }];
            }
        }
    }
}

#pragma mark - Setting&Getting
- (PSBuyCardView *)buyCardView {
    if (!_buyCardView) {
        
        _buyCardView = [[PSBuyCardView alloc] initWithFrame:CGRectZero buyModel:_buyModel index:1];
        @weakify(self);
        _buyCardView.buyBlock = ^(NSInteger index, BOOL isWrite) {
            @strongify(self);
            [self buyCard:index];
        };
    }
    return _buyCardView;
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
