//
//  PSCartViewController.m
//  PrisonService
//
//  Created by calvin on 2018/5/14.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSCartViewController.h"
#import "PSCartProductCell.h"
#import "PSPayCenter.h"
#import "PSSessionManager.h"
#import "PSPayView.h"
#import "PSAlertView.h"
#import "PSMeetJailsnnmeViewModel.h"
#import "PSBusinessConstants.h"
@interface PSCartViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *cartTableView;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UIButton *settlementButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) PSPayView *payView;

@end

@implementation PSCartViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*shopping_cart=NSLocalizedString(@"shopping_cart", @"购物车");
        self.title = shopping_cart;
    }
    return self;
}

- (void)requestPhoneCard {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [cartViewModel requestPhoneCardCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self renderContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self renderContents];
    }];
}

- (IBAction)allSelectOperation:(id)sender {
    UIButton *button = sender;
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    [cartViewModel selectedAllProducts:!button.selected];
    [self updateContents];
}

-(void)payTips{
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    PSMeetJailsnnmeViewModel*meetJailsnnmeViewModel=[[PSMeetJailsnnmeViewModel alloc]init];
    [meetJailsnnmeViewModel requestMeetJailsterCompleted:^(PSResponse *response) {
        NSString*notice_title=NSLocalizedString(@"notice_title", @"提请注意");
        NSString*notice_content=NSLocalizedString(@"notice_content", @"您购买的亲情电话卡将用于与%@的视频会见");
        NSString*notice_agreed=NSLocalizedString(@"notice_agreed", @"确定");
        NSString*notice_disagreed=NSLocalizedString(@"notice_disagreed", @"取消");
        [PSAlertView showWithTitle:notice_title message:[NSString stringWithFormat:notice_content,meetJailsnnmeViewModel.jailsSting] messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self settlementAction:nil];
            }
        } buttonTitles:notice_disagreed,notice_agreed, nil];
    } failed:^(NSError *error) {
        
        if (error.code>=500) {
            [self showNetError];
        } else {
            NSString *tips = NSLocalizedString(@"Unable to connect to server, please check network settings",@"无法连接到服务器,请检查网络设置");
            [PSTipsView showTips:tips];
        }
    }];

}
- (IBAction)settlementAction:(id)sender {
    
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    if (cartViewModel.quantity > 0 &&cartViewModel.amount>0) {
        [self buyCardAction];
    }else{
        if (cartViewModel.amount==0) {
            NSString *msg = NSLocalizedString(@"The prison is a free meeting with the prison, no need to buy", @"该监狱为免费会见监狱,无需购买");
            [PSTipsView showTips:msg];
        } else {

            NSString *msg = NSLocalizedString(@"Please select the item you want to buy", @"请选中您要购买的商品");
            [PSTipsView showTips:msg];
        }
     
    }
}

- (void)selectOperationAtIndex:(NSInteger)index {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    [cartViewModel selectOperationAtIndex:index];
    [self updateContents];
}

- (void)reduceOperationAtIndex:(NSInteger)index {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    [cartViewModel reduceOperationAtIndex:index];
    [self updateContents];
}

- (void)increaseOperationAtIndex:(NSInteger)index {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    [cartViewModel increaseOperationAtIndex:index];
    [self updateContents];
}

- (void)buyCardAction {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    PSPayView *payView = [PSPayView new];
    [payView setGetAmount:^CGFloat{
        return cartViewModel.amount;
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
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
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
                        }
                    }else{
                        [self.navigationController popViewControllerAnimated:NO];
                        self.payView.status = PSPaySuccessful;
                        [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
                    }
                }];
            }
        }
    }
}

- (void)updateBottomContent {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    NSString*settlement=NSLocalizedString(@"settlement", @"结算(%ld)");
    [_settlementButton setTitle:[NSString stringWithFormat:settlement,(long)cartViewModel.totalQuantity] forState:UIControlStateNormal];
    NSString*A_combined=NSLocalizedString(@"A_combined", @"合计：");
    NSMutableAttributedString *amountString = [NSMutableAttributedString new];
    [amountString appendAttributedString:[[NSAttributedString alloc] initWithString:A_combined attributes:@{NSFontAttributeName:FontOfSize(14),NSForegroundColorAttributeName:UIColorFromHexadecimalRGB(0x333333)}]];
    [amountString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%.2f",cartViewModel.amount] attributes:@{NSFontAttributeName:FontOfSize(14),NSForegroundColorAttributeName:UIColorFromHexadecimalRGB(0xDC3B3B)}]];
    _amountLabel.attributedText = amountString;
    _selectButton.selected = cartViewModel.totalSelected;
}

- (void)updateContents {
    [self updateBottomContent];
    [self.cartTableView reloadData];
}

- (void)renderContents {
    UIView *bottomView = [UIView new];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(49);
    }];
    UIView *line = [UIView new];
    line.backgroundColor = AppBaseLineColor;
    [bottomView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    UIFont *textFont = FontOfSize(12);
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectButton addTarget:self action:@selector(allSelectOperation:) forControlEvents:UIControlEventTouchUpInside];
    [_selectButton setImage:[UIImage imageNamed:@"cartProductNormal"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"cartProductSelected"] forState:UIControlStateSelected];
    _selectButton.titleLabel.font = textFont;
    [_selectButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    [_selectButton setTitleColor:AppBaseTextColor1 forState:UIControlStateSelected];
    NSString*Future_generations=NSLocalizedString(@"Future_generations", @"  全选");
    [_selectButton setTitle:Future_generations forState:UIControlStateNormal];
    [bottomView addSubview:_selectButton];
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(60);
    }];
    _settlementButton = [UIButton buttonWithType:UIButtonTypeCustom];
//购    [_settlementButton addTarget:self action:@selector(settlementAction:) forControlEvents:UIControlEventTouchUpInside];
    [_settlementButton addTarget:self action:@selector(payTips) forControlEvents:UIControlEventTouchUpInside];
    [_settlementButton setBackgroundImage:[[UIImage imageNamed:@"universalButtonBg"] stretchImage] forState:UIControlStateNormal];
    [_settlementButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _settlementButton.titleLabel.font = textFont;
    [bottomView addSubview:_settlementButton];
    [_settlementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(100);
    }];
    _amountLabel = [UILabel new];
    _amountLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:_amountLabel];
    [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(_selectButton.mas_right).offset(5);
        make.right.mas_equalTo(_settlementButton.mas_left).offset(-5);
    }];
    [self updateBottomContent];
    
    self.cartTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.cartTableView.backgroundColor = [UIColor clearColor];
    self.cartTableView.dataSource = self;
    self.cartTableView.delegate = self;
    self.cartTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cartTableView.tableFooterView = [UIView new];
    [self.cartTableView registerClass:[PSCartProductCell class] forCellReuseIdentifier:@"PSCartProductCell"];
    [self.view addSubview:self.cartTableView];
    [self.cartTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(bottomView.mas_top);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self requestPhoneCard];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    return cartViewModel.products.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSCartProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSCartProductCell"];
    PSCartViewModel *cartViewModel = (PSCartViewModel *)self.viewModel;
    PSProduct *product = cartViewModel.products[indexPath.row];
    cell.productImageView.image = [UIImage imageNamed:@"cartProductIcon"];
    cell.productNameLabel.text = product.title;
    CGFloat price =product.price;
    //product.price > 0 ? product.price : product.defaultPrice;
    cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
    cell.quantityLabel.text = [NSString stringWithFormat:@"%ld",(long)product.quantity];
    cell.selectStatusView.selected = product.selected;
    @weakify(self)
    [cell.selectStatusView bk_whenTapped:^{
        @strongify(self)
        NSInteger index = [tableView indexPathForCell:cell].row;
        [self selectOperationAtIndex:index];
    }];
    [cell.reduceButton bk_whenTapped:^{
        @strongify(self)
        NSInteger index = [tableView indexPathForCell:cell].row;
        [self reduceOperationAtIndex:index];
    }];
    [cell.increaseButton bk_whenTapped:^{
        @strongify(self)
        NSInteger index = [tableView indexPathForCell:cell].row;
        [self increaseOperationAtIndex:index];
    }];
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
