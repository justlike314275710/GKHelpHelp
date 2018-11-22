//
//  PSBuyCardViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBuyCardViewController.h"
#import "PSBuyCardStepCell.h"
#import "PSPayView.h"
#import "PSPayCenter.h"
#import "PSSessionManager.h"
#import "PSBusinessConstants.h"

@interface PSBuyCardViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *buyTableView;
@property (nonatomic, strong) PSPayView *payView;

@end

@implementation PSBuyCardViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"购买亲情电话卡";
    }
    return self;
}

- (void)goPay {
    PSPhoneCardViewModel *phoneCardViewModel = (PSPhoneCardViewModel *)self.viewModel;
    NSInteger selectedIndex = phoneCardViewModel.selectedPaymentIndex;
    if (selectedIndex >= 0 && selectedIndex < phoneCardViewModel.payments.count) {
        PSPayment *paymentInfo = phoneCardViewModel.payments[selectedIndex];
        PSPayInfo *payInfo = [PSPayInfo new];
        payInfo.familyId = [PSSessionManager sharedInstance].session.families.id;
        payInfo.jailId = phoneCardViewModel.prisonerDetail.jailId;
        payInfo.productID = phoneCardViewModel.phoneCard.id;
        CGFloat price = phoneCardViewModel.phoneCard.price;
        //> 0 ? phoneCardViewModel.phoneCard.price : phoneCardViewModel.phoneCard.defaultPrice;
        payInfo.amount = phoneCardViewModel.quantity * price;
        payInfo.productName = phoneCardViewModel.phoneCard.title;
        payInfo.quantity = phoneCardViewModel.quantity;
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
                }
            }else{
                self.payView.status = PSPaySuccessful;
                [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
            }
        }];
    }
}

- (void)buyCardAction {
    PSPhoneCardViewModel *phoneCardViewModel = (PSPhoneCardViewModel *)self.viewModel;
    CGFloat price = phoneCardViewModel.phoneCard.price;
    //> 0 ? phoneCardViewModel.phoneCard.price : phoneCardViewModel.phoneCard.defaultPrice;
    CGFloat amount = phoneCardViewModel.quantity * price;
    PSPayView *payView = [PSPayView new];
    [payView setGetAmount:^CGFloat{
        return amount;
    }];
    [payView setGetRows:^NSInteger{
        return phoneCardViewModel.payments.count;
    }];
    [payView setGetSelectedIndex:^NSInteger{
        return phoneCardViewModel.selectedPaymentIndex;
    }];
    [payView setGetIcon:^UIImage *(NSInteger index) {
        PSPayment *payment = phoneCardViewModel.payments.count > index ? phoneCardViewModel.payments[index] : nil;
        return payment ? [UIImage imageNamed:payment.iconName] : nil;
    }];
    [payView setGetName:^NSString *(NSInteger index) {
        PSPayment *payment = phoneCardViewModel.payments.count > index ? phoneCardViewModel.payments[index] : nil;
        return payment ? payment.name : nil;
    }];
    [payView setSeletedPayment:^(NSInteger index) {
        phoneCardViewModel.selectedPaymentIndex = index;
    }];
    @weakify(self)
    [payView setGoPay:^{
        @strongify(self)
        [self goPay];
    }];
    [payView showAnimated:YES];
    _payView = payView;
}

- (void)reduceQuantity {
    PSPhoneCardViewModel *phoneCardViewModel = (PSPhoneCardViewModel *)self.viewModel;
    if (phoneCardViewModel.quantity > 1) {
        phoneCardViewModel.quantity --;
        [self.buyTableView reloadData];
    }
}

- (void)increaseQuantity {
    PSPhoneCardViewModel *phoneCardViewModel = (PSPhoneCardViewModel *)self.viewModel;
    phoneCardViewModel.quantity ++;
    [self.buyTableView reloadData];
}

- (void)renderContents {
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton addTarget:self action:@selector(buyCardAction) forControlEvents:UIControlEventTouchUpInside];
    buyButton.titleLabel.font = AppBaseTextFont1;
    UIImage *bgImage = [UIImage imageNamed:@"universalBtGradientBg"];
    [buyButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buyButton setTitle:@"购买" forState:UIControlStateNormal];
    [self.view addSubview:buyButton];
    [buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(bgImage.size);
    }];
    self.buyTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.buyTableView.dataSource = self;
    self.buyTableView.delegate = self;
    self.buyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIImage *headerImage = [UIImage imageNamed:@"appointmentBuyHeader"];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, RELATIVE_WIDTH_VALUE(headerImage.size.height))];
    headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    headerImageView.image = headerImage;
    self.buyTableView.tableHeaderView = headerImageView;
    self.buyTableView.tableFooterView = [UIView new];
    [self.buyTableView registerClass:[PSBuyCardStepCell class] forCellReuseIdentifier:@"PSBuyCardStepCell"];
    [self.view addSubview:self.buyTableView];
    [self.buyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(buyButton.mas_top).offset(-20);
    }];
}

- (void)requestPhoneCard {
    PSPhoneCardViewModel *phoneCardViewModel = (PSPhoneCardViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [phoneCardViewModel requestPhoneCardCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self renderContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self renderContents];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self requestPhoneCard];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate
#pragma mark - UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 460;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSBuyCardStepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSBuyCardStepCell"];
    PSPhoneCardViewModel *phoneCardViewModel = (PSPhoneCardViewModel *)self.viewModel;
    cell.titleLabel.text = phoneCardViewModel.phoneCard.title;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%ld",(long)phoneCardViewModel.quantity];
    @weakify(self)
    [cell.increaseButton bk_whenTapped:^{
        @strongify(self)
        [self increaseQuantity];
    }];
    [cell.reduceButton bk_whenTapped:^{
        @strongify(self)
        [self reduceQuantity];
    }];
    CGFloat price = phoneCardViewModel.phoneCard.price;
    //> 0 ? phoneCardViewModel.phoneCard.price : phoneCardViewModel.phoneCard.defaultPrice;
    cell.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
    return cell;
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
