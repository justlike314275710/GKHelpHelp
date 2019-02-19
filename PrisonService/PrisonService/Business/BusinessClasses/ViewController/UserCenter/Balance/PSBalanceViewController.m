 //
//  PSBalanceViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBalanceViewController.h"
#import "PSBalanceTopView.h"
#import "PSAlertView.h"
#import "PSSessionManager.h"
#import "AccountsViewModel.h"
#import "Accounts.h"
#import "PSRefundViewController.h"
#import "PSRefundViewModel.h"
#import "PSTransactionRecordViewModel.h"
#import "PSBusinessConstants.h"
#import "PSAccountrefundViewController.h"
#import "PSCartViewModel.h"
#import "PSBuyCardView.h"
#import "PSPayView.h"
#import "PSMeetJailsnnmeViewModel.h"
#import "PSPayInfo.h"
#import "PSPayCenter.h"
@interface PSBalanceViewController ()

@property (nonatomic,strong) PSBalanceTopView *balanceTopView;
@property (nonatomic,strong) NSString*balanceSting;
@property (nonatomic,strong) UILabel *totalLab;

@property (nonatomic, strong) UILabel *cardPriceLab;
@property (nonatomic, strong) PSBuyCardView *buyCardView;
@property (nonatomic, strong) PSCartViewModel *cartViewModel;
@property (nonatomic, strong) PSPrisonerDetail *prisonerDetail;
@property (nonatomic, strong) PSBuyModel *buyModel;
@property (nonatomic, strong) PSPayView *payView;

@end

@implementation PSBalanceViewController
//- (id)init {
//    self = [super init];
//    if (self) {
//        self.title = @"我的余额";
//    }
//    return self;
//}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmRefundAction{
    PSRefundViewModel*refundViewModel=[[PSRefundViewModel alloc]init];
    [refundViewModel requestRefundCompleted:^(PSResponse *response) {
        if (response.code==200) {
           // [PSTipsView showTips:response.msg];
            [PSAlertView showWithTitle:@"退款成功" message:refundViewModel.msgData messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==0) {
                    [self requestBalance];
                }
            } buttonTitles:@"确定", nil];
        }
        else{
            [PSTipsView showTips:response.msg];
        }
    } failed:^(NSError *error) {
         [PSTipsView showTips:@"退款失败"];
    }];
}

- (void)refundAction {
    
    if ([self.balanceSting floatValue] == 0) {
        [PSTipsView showTips:@"当前没有可退款金额!"];
        return;
    }
  
    PSAccountrefundViewController *AccountRefundVC = [[PSAccountrefundViewController alloc] initWithViewModel:[PSViewModel new]];
    AccountRefundVC.refundBlock = ^(NSString *balanceSting) {
        
        _totalLab.textColor = [UIColor whiteColor];
        _totalLab.font = FontOfSize(47);
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:_totalLab.text];
        [attrStr addAttribute:NSFontAttributeName value:FontOfSize(12) range:NSMakeRange(_totalLab.text.length-1, 1)];
        _totalLab.attributedText = attrStr;
        self.balanceSting = balanceSting;
        if ([NSObject judegeIsVietnamVersion]) _totalLab.text = [NSString stringWithFormat:@"$%.2f",[balanceSting floatValue]];
        
    };
    
    [self.navigationController pushViewController:AccountRefundVC animated:YES];
    
    return;
    [PSAlertView showWithTitle:nil message:[NSString stringWithFormat:@"确定退款%.2f元",[self.balanceSting floatValue]] messageAlignment:NSTextAlignmentCenter image:[UIImage R_imageNamed:@"userCenterBalanceRefund"] handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex==1) {
            [self confirmRefundAction];//确定退款
        }
    } buttonTitles:@"取消",@"确定退款", nil];

    
}

-(void)requestBalance{
    [[PSLoadingView sharedInstance]show];
    [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
    AccountsViewModel*accountsModel=[[AccountsViewModel alloc]init];
    [accountsModel requestAccountsCompleted:^(PSResponse *response) {
//        self.balanceTopView.balanceLabel.text = [NSString stringWithFormat:@"¥%.2f",[accountsModel.blance floatValue]];
        self.balanceSting=accountsModel.blance;
        _totalLab.textColor = [UIColor whiteColor];
        _totalLab.font = FontOfSize(47);
        _totalLab.text= [NSString stringWithFormat:@"¥%@元",self.balanceSting];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:_totalLab.text];
        [attrStr addAttribute:NSFontAttributeName value:FontOfSize(12) range:NSMakeRange(_totalLab.text.length-1, 1)];
        _totalLab.attributedText = attrStr;
        if ([NSObject judegeIsVietnamVersion]) _totalLab.text = [NSString stringWithFormat:@"$%.2f",[accountsModel.blance floatValue]];
        

        [[PSLoadingView sharedInstance]dismiss];
        if ([accountsModel.blance floatValue]==0.00){
            [self.balanceTopView.refundButton setBackgroundImage:[UIImage R_imageNamed:@"universalButtongrayBg"] forState:UIControlStateNormal];
            self.balanceTopView.refundButton.userInteractionEnabled=NO;
  
        }
        else{
            [self.balanceTopView.refundButton setBackgroundImage:[UIImage R_imageNamed:@"universalButtonBg"] forState:UIControlStateNormal];
            self.balanceTopView.refundButton.userInteractionEnabled=YES;
        }
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance]dismiss];
        [PSTipsView showTips:@"获取余额失败"];
    }];
}

- (void)renderContents {
 
    self.balanceTopView = [PSBalanceTopView new];
    @weakify(self)
    [self.balanceTopView.refundButton bk_whenTapped:^{
        @strongify(self)
        [self refundAction];
    }];
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString* language = langArr.firstObject;
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        self.balanceTopView.refundButton.hidden=YES;
    }
    else{
        self.balanceTopView.refundButton.hidden=NO;
    }

    CGFloat topHeight = SCREEN_WIDTH * self.balanceTopView.topRate + SCREEN_WIDTH * self.balanceTopView.infoRate - 40;
    [self.view addSubview:self.balanceTopView];
    [self.balanceTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(topHeight);
    }];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage R_imageNamed:@"userCenterAccountBack"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44,40));
        make.top.mas_equalTo(StatusHeight);
    }];
    
    
    UIButton *balanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [balanceButton addTarget:self action:@selector(AccountDetails) forControlEvents:UIControlEventTouchUpInside];
    NSString*Account_details=NSLocalizedString(@"Account_details", @"账号明细");
    [balanceButton setTitle:Account_details forState:UIControlStateNormal];
    balanceButton.titleLabel.font=AppBaseTextFont2;
    balanceButton.titleLabel.numberOfLines=0;
    [self.view addSubview:balanceButton];
    [balanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.size.mas_equalTo(CGSizeMake(60,40));
        make.top.mas_equalTo(StatusHeight);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
     NSString*userCenterBalance=NSLocalizedString(@"userCenterBalance", @"我的余额");
    titleLabel.text = userCenterBalance;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backButton.mas_top);
        make.bottom.mas_equalTo(backButton.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(100);
    }];
}


-(void)AccountDetails{
    
    PSRefundViewController *refundViewController = [[PSRefundViewController alloc] initWithViewModel:[PSTransactionRecordViewModel new]];
    [self.navigationController pushViewController:refundViewController  animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *title = NSLocalizedString(@"Family card service", @"远程探视卡服务");
    self.title = title;
    self.balanceSting = @"0";
    [self requestBalance];
    [self requestInfoPhoneCard];
    [self p_setUI];
 
}

- (void)requestInfoPhoneCard {
    
    self.cartViewModel = [PSCartViewModel new];
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [self.cartViewModel requestPhoneCardCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        NSString *Family_card = NSLocalizedString(@"Family card", @"远程探视卡");
        NSString *piece = NSLocalizedString(@"piece", @"张");
        _cardPriceLab.text = [NSString stringWithFormat:@"%@ %.2f/%@",Family_card,_cartViewModel.amount,piece];
//        [self payTips];
  
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
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


- (void)p_setUI {
    
    NSString *Account_details = NSLocalizedString(@"Account_details", @"远程探视卡明细");
    [self createRightBarButtonItemWithTarget:self action:@selector(AccountDetails) title:Account_details];
    //banner
    UIImageView *imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170)];
    imageLogo.image = [UIImage R_imageNamed:@"banner"];
    [self.view addSubview:imageLogo];
    
    UIImageView *locationLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 13, 15)];
    locationLogo.image = [UIImage R_imageNamed:@"定位"];
    [self.view addSubview:locationLogo];
    
    UILabel *locationLab = [[UILabel alloc] initWithFrame:CGRectMake(locationLogo.right+5, 10, 200, 15)];
    locationLab.textColor = [UIColor whiteColor];
    locationLab.textAlignment = NSTextAlignmentLeft;
    locationLab.font = FontOfSize(12);
    
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = nil;
    
    if (index >= 0 && index < [PSSessionManager sharedInstance].passedPrisonerDetails.count) {
        prisonerDetail = [PSSessionManager sharedInstance].passedPrisonerDetails[index];
    }
    locationLab.text=prisonerDetail.jailName;
    [self.view addSubview:locationLab];
    
    
    UIImageView *cardmoneyImg = [[UIImageView alloc] initWithFrame:CGRectMake(25, 36, 95, 17)];
    cardmoneyImg.image = [UIImage R_imageNamed:@"远程探视卡总金额"];
    
    [self.view addSubview:cardmoneyImg];
    //总金额
    _totalLab = [[UILabel alloc] initWithFrame:CGRectMake(24,cardmoneyImg.bottom+10,200,40)];
    _totalLab.textColor = [UIColor whiteColor];
    _totalLab.font = FontOfSize(47);
    _totalLab.text= [NSString stringWithFormat:@"¥%@元",self.balanceSting];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:_totalLab.text];
    [attrStr addAttribute:NSFontAttributeName value:FontOfSize(12) range:NSMakeRange(_totalLab.text.length-1, 1)];
    _totalLab.attributedText = attrStr;
    
    if ([NSObject judegeIsVietnamVersion]) _totalLab.text = [NSString stringWithFormat:@"$%@",self.balanceSting];
    
    [self.view addSubview:_totalLab];
    
    UIImageView *cardHeadImg = [[UIImageView alloc] initWithFrame:CGRectMake(15,imageLogo.bottom+15, 60, 50)];
    cardHeadImg.image = [UIImage R_imageNamed:@"亲情电话卡图"];
    [self.view addSubview:cardHeadImg];
    
    _cardPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(cardHeadImg.right+5,imageLogo.bottom+20, 200, 20)];
    _cardPriceLab.text = @"远程探视卡 2.00/张";
    _cardPriceLab.font = FontOfSize(14);
    _cardPriceLab.textColor = UIColorFromRGB(51, 51, 51);
    _cardPriceLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_cardPriceLab];

    UILabel *cardMessageLab = [[UILabel alloc] initWithFrame:CGRectMake(cardHeadImg.right+5,_cardPriceLab.bottom, 200, 30)];
    NSString *messageStr = NSLocalizedString(@"Save money and save trouble. Family Card Mobile Phone Long-distance Meeting Bridge", @"省钱省事,远程探视手机远程会见桥梁");
    cardMessageLab.numberOfLines = 0;
    cardMessageLab.text = messageStr;
    cardMessageLab.font = FontOfSize(11);
    if (IS_iPhone_5) cardMessageLab.font = FontOfSize(9);
    cardMessageLab.textColor = UIColorFromRGB(102, 102, 102);
    cardMessageLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:cardMessageLab];
    
    UIButton *buyCardBtn = [UIButton new];
    buyCardBtn.frame = CGRectMake(SCREEN_WIDTH-70, cardHeadImg.top+10,55, 30);
    NSString *buy = NSLocalizedString(@"purchase", @"购买");
    [buyCardBtn setTitle:buy forState:UIControlStateNormal];
    buyCardBtn.layer.masksToBounds = YES;
    buyCardBtn.layer.borderWidth = 1.0f;
    buyCardBtn.layer.borderColor = UIColorFromRGB(38, 76, 114).CGColor;
    buyCardBtn.layer.cornerRadius = 15;
    buyCardBtn.titleLabel.font = FontOfSize(13);
    [buyCardBtn setTitleColor:UIColorFromRGB(38, 76, 114) forState:UIControlStateNormal];
    [self.view addSubview:buyCardBtn];
    @weakify(self);
    [buyCardBtn bk_whenTapped:^{
        @strongify(self);
//        [self requestInfoPhoneCard];
        [self payTips];
    }];
    
    int btnWidth = (SCREEN_WIDTH-(15*3))/2;
    UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    buyBtn.frame = CGRectMake(15,SCREEN_HEIGHT-64-64,btnWidth,44);
    [buyBtn setBackgroundImage:[UIImage R_imageNamed:@"购买按钮底框"] forState:UIControlStateNormal];
    [buyBtn setTitle:buy forState:UIControlStateNormal];
    [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyBtn.titleLabel.font = FontOfSize(13);
    [self.view addSubview:buyBtn];
    [buyBtn bk_whenTapped:^{
        @strongify(self)
        [self requestInfoPhoneCard];
        [self payTips];
    }];
    
    
    UIButton *refundbBtn = [UIButton new];
    refundbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refundbBtn.frame = CGRectMake(SCREEN_WIDTH-btnWidth-15,SCREEN_HEIGHT-64-64,btnWidth, 44);
    [refundbBtn setBackgroundImage:[UIImage R_imageNamed:@"购买按钮底框"] forState:UIControlStateNormal];
    NSString *refun = NSLocalizedString(@"refund", @"退款");
    [refundbBtn setTitle:refun forState:UIControlStateNormal];
    [refundbBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    refundbBtn.titleLabel.font = FontOfSize(13);
    [self.view addSubview:refundbBtn];
    [refundbBtn bk_whenTapped:^{
        @strongify(self);
        NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
        NSString*language = langArr.firstObject;
        if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-CN"]||[language isEqualToString:@"vi-VN"]) {
             NSString*coming_soon=NSLocalizedString(@"coming_soon", @"该监狱暂未开通此功能");
             [PSTipsView showTips:coming_soon];
        }
        else{
            [self refundAction];
        }
    }];
    
    UIScrollView *imageScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(15,cardHeadImg.bottom+12,SCREEN_WIDTH-30,SCREEN_HEIGHT-64-cardHeadImg.bottom-12-84)];
    imageScrollview.backgroundColor = UIColorFromRGB(235, 235, 235);
    
    int width =  imageScrollview.width/2;
    int height = imageScrollview.width/2*130/164;
    int newHeight = imageScrollview.width*150/330;
    
    imageScrollview.contentSize = CGSizeMake(SCREEN_WIDTH-30,108+height*3+(newHeight+5)*3);
    imageScrollview.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:imageScrollview];

    UIImageView *yqImg = [[UIImageView alloc] initWithFrame:CGRectMake((imageScrollview.width-34)/2,20,34,17)];
    yqImg.image = [UIImage R_imageNamed:@"以前"];
    [imageScrollview addSubview:yqImg];
    
    NSArray *iamgeNames = @[@"画面一－六点出门",@"画面二－七点等车",@"画面三－两点汽车",@"画面四－三点排队",@"画面五－6点取号",@"画面六－6点半会见"];
    
    for (int i = 0; i<6; i++) {
        UIImageView *yqImagLogo = [[UIImageView alloc] initWithFrame:CGRectMake((i%2)*width,(i/2)*height+yqImg.bottom+10,width-1,height-1)];
        yqImagLogo.image = [UIImage R_imageNamed:iamgeNames[i]];
        [imageScrollview addSubview:yqImagLogo];
    }
    
    UIImageView *LineImg = [[UIImageView alloc] initWithFrame:CGRectMake((imageScrollview.width-5)/2,20+17+17+height*3,5,23)];
    LineImg.image = [UIImage R_imageNamed:@"。。。"];
    [imageScrollview addSubview:LineImg];
    
    UIImageView *nowImg = [[UIImageView alloc] initWithFrame:CGRectMake((imageScrollview.width-34)/2,LineImg.bottom+5,34,17)];
    nowImg.image = [UIImage R_imageNamed:@"现在"];
    [imageScrollview addSubview:nowImg];
    
    NSArray *nowImages = @[@"现在－画面一－看手机对话",@"现在－画面二－界面展示",@"现在－画面三－视频通话"];
    for (int i = 0;i<3;i++) {
        UIImageView *yqImagLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0,i*(newHeight+5)+nowImg.bottom+10,imageScrollview.width,newHeight)];
        yqImagLogo.image = [UIImage R_imageNamed:nowImages[i]];
        [imageScrollview addSubview:yqImagLogo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    self.balanceSting=nil;
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
//                        [self.navigationController popViewControllerAnimated:NO];
                        [self requestBalance];
                        self.payView.status = PSPaySuccessful;
                        NSString *msg = error.domain?error.domain:@"";
                        [SDTrackTool logEvent:BUY_FAMILY_CARD attributes:@{STATUS:MobSUCCESS,ERROR_STR:msg,PAY_TYPE:payInfo.payment}];
                        [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
                    }
                }];
            }
        }
    }
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
        return payment ? [UIImage R_imageNamed:payment.iconName] : nil;
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

#pragma mark - Setting&Getting
- (PSBuyCardView *)buyCardView {
    if (!_buyCardView) {
        
        _buyCardView = [[PSBuyCardView alloc] initWithFrame:CGRectZero buyModel:_buyModel index:1];
        @weakify(self);
        _buyCardView.buyBlock = ^(NSInteger index) {
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
