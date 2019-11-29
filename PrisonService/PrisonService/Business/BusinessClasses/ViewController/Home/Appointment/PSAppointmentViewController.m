//
//  PSAppointmentViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAppointmentViewController.h"
#import "FSCalendar.h"
#import "PSDateView.h"
#import "NSDate+Components.h"
#import "PSLastCallInfoCell.h"
#import "PSAppointmentDetailCell.h"
#import "PSAppointmentInstructionCell.h"
#import "PSAlertView.h"
#import "PSTipsConstants.h"
#import "PSCartViewController.h"
#import "PSSessionManager.h"
#import "PSIMMessageManager.h"
#import "NSString+Date.h"
#import "PSFaceAuthViewController.h"
#import "AccountsViewModel.h"
#import "PSInstructionsDataView.h"
#import "PSPrisonerFamilesViewController.h"
#import "PSPrisonerFamliesViewModel.h"
#import "PSPrisonerFamily.h"
#import "PSBusinessConstants.h"
#import "PSBuyCardView.h"
#import "PSMeetJailsnnmeViewModel.h"
#import "PSPayView.h"
#import "PSPayInfo.h"
#import "PSPayCenter.h"
#import "PSAppointmentProcessView.h"
#import "PSMeetingViewModel.h"


@interface PSAppointmentViewController ()<FSCalendarDataSource,FSCalendarDelegate,UITableViewDataSource,UITableViewDelegate,PSIMMessageObserver,PSSessionObserver,UIGestureRecognizerDelegate>
{
    void * _KVOContext;
}
@property (nonatomic, strong) FSCalendar *calendar;
@property (nonatomic, strong) PSDateView *dateView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UITableView *appointmentTableView;
@property (nonatomic,assign) CGFloat Balance;
@property (nonatomic , strong) NSArray *selectArray;
@property (nonatomic , strong) NSMutableArray *meetingMembersArray;
@property (nonatomic , strong) PSPrisonerFamily*familyModel;
@property (nonatomic , strong) PSBuyCardView *buyCardView;
@property (nonatomic, strong) PSCartViewModel *cartViewModel;
@property (nonatomic, strong) PSPrisonerDetail *prisonerDetail;
@property (nonatomic, strong) PSBuyModel *buyModel;
@property (nonatomic, strong) PSPayView *payView;
@property (strong, nonatomic) UIPanGestureRecognizer *scopeGesture;



@end

@implementation PSAppointmentViewController

#pragma mark - LifeCycle

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*family_phone=NSLocalizedString(@"family_phone", @"亲情电话");
        self.title = family_phone;
        [[PSIMMessageManager sharedInstance] addObserver:self];
        [[PSSessionManager sharedInstance] addObserver:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self requestPhoneCard];
    self.selectArray=[NSArray array];
    self.meetingMembersArray=[[NSMutableArray alloc ]init];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)dealloc {
    [[PSIMMessageManager sharedInstance] removeObserver:self];
    [[PSSessionManager sharedInstance] removeObserver:self];
    self.selectArray=nil;
    [self.calendar removeObserver:self forKeyPath:@"scope" context:_KVOContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - PrivateMethods
- (void)appointmentAction {
    
    PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];

    
    for (int i=0; i<self.selectArray.count; i++) {
        PSPrisonerFamily*familesModel=self.selectArray[i];
        if ([familesModel.familyName isEqualToString:[PSSessionManager sharedInstance].session.families.name]) {
            self.familyModel=self.selectArray[i];
        }
    }
    NSLog(@"%@",self.familyModel);
    [self.meetingMembersArray removeAllObjects];
    for (int i=0; i<self.selectArray.count; i++) {
        PSPrisonerFamily*familyModel=self.selectArray[i];
        NSDictionary*arrayDic=@{@"familyId":familyModel.familyId};
        [self.meetingMembersArray addObject:arrayDic];
    }
    NSLog(@"远程视频会见数组||%@",self.meetingMembersArray);
    appointmentViewModel.familyId=_familyModel.familyId;
    appointmentViewModel.applicationDate=[self.calendar.selectedDate yearMonthDay];
    appointmentViewModel.prisonerId=_familyModel.prisonerId;
    appointmentViewModel.charge=[NSString stringWithFormat:@"%.2f",appointmentViewModel.jailConfiguration.cost];
    appointmentViewModel.jailId=_familyModel.jailId;
    appointmentViewModel.meetingMembers=self.meetingMembersArray;
    @weakify(self)
    [appointmentViewModel addMeetingWithDate:self.calendar.selectedDate completed:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            NSString*apply_success=NSLocalizedString(@"apply_success", @"会见申请成功");
            [PSTipsView showTips:apply_success];
            [self refreshData:YES];
            //埋点...
            [SDTrackTool logEvent:APPLY_FAMILY_CALL attributes:@{STATUS:MobSUCCESS}];
            
        }else{
            
            NSString*determine=NSLocalizedString(@"determine", @"确定");
            NSString*cancel=NSLocalizedString(@"cancel", @"取消");
            [PSAlertView showWithTitle:nil message:response.msg messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                
            } buttonTitles:cancel,determine, nil];
            //[PSTipsView showTips:response.msg ? response.msg : @"预约失败"];
            //埋点...
            NSString *mobError = response.msg?response.msg:@"预约失败";
            [SDTrackTool logEvent:APPLY_FAMILY_CALL attributes:@{STATUS:MobFAILURE,ERROR_STR:mobError}];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
        
    }];
}

- (void)checkFaceAuth {
     PSMeetingViewModel*meetingviewModel=[PSMeetingViewModel new];
    meetingviewModel.familymeetingID=[PSSessionManager sharedInstance].session.families.id;
    meetingviewModel.faceType=PSFaceAppointment;
    meetingviewModel.FamilyMembers=self.selectArray;
    PSFaceAuthViewController *authViewController = [[PSFaceAuthViewController alloc] init];
    authViewController.apppintmentArray=self.selectArray;
    authViewController = [authViewController initWithViewModel:meetingviewModel];
    [authViewController setCompletion:^(BOOL successful) {
        if (successful) {
            [self appointmentAction];
        }
        [self.navigationController popViewControllerAnimated:NO];
    }];
    [self.navigationController pushViewController:authViewController animated:NO];
}

- (void)handleAppointmentApply {
    PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
    if ([appointmentViewModel.jailConfiguration.face_recognition isEqualToString:@"0"]) {
        [self appointmentAction];
    }else{
        [self checkFaceAuth];
    }
     //[self appointmentAction];
}

-(void)addPrisonerFamliesAction{
    self.selectArray=nil;
     PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
    PSPrisonerFamliesViewModel *prisonerFamliesViewModel = [[PSPrisonerFamliesViewModel alloc]init];
   prisonerFamliesViewModel.face_recognition=appointmentViewModel.jailConfiguration.face_recognition;
    PSPrisonerFamilesViewController*familesViewController=[[PSPrisonerFamilesViewController alloc]initWithViewModel:prisonerFamliesViewModel];
    familesViewController.returnValueBlock = ^(NSArray *arrayValue) {
        self.selectArray=arrayValue;
    };
    
    [familesViewController setCompletion:^(BOOL successful) {
        if (successful) {
            //[self appointmentAction];
            [self applyAction];
        }
    }];
    
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:familesViewController animated:YES];
   
}

- (void)applyAction {
    PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
    CGFloat price = appointmentViewModel.phoneCard.price;
    if (price-self.Balance>0.0000001) {
        NSString*determine=NSLocalizedString(@"determine", @"确定");
        NSString*cancel=NSLocalizedString(@"cancel", @"取消");
        NSString*msg = NSLocalizedString(@"To apply for this meeting, you need %.2f yuan. If your balance is insufficient, please recharge.", @"申请本次会见需要%.2f元，您的余额不足请充值");
        
        [PSAlertView showWithTitle:nil message:[NSString stringWithFormat:msg,price] messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self buyCardAction];
            }
        } buttonTitles:cancel,determine, nil];
    }else{
         NSString*notice_title=NSLocalizedString(@"notice_title", @"提请注意");
        NSString*notice_agreed=NSLocalizedString(@"notice_agreed", @"同意");
        NSString*notice_disagreed=NSLocalizedString(@"notice_disagreed", @"不同意");
        NSString*apply_content=NSLocalizedString(@"apply_content", @"您预约%@与%@进行远程视频会见,按约定,本次会见支付人民币%.2f元,系统将从远程探视卡余额中自动扣除");
        //[self.calendar.selectedDate yearMonthDayChinese]
        [PSAlertView showWithTitle:notice_title message:[NSString stringWithFormat:apply_content,[self.calendar.selectedDate yearMonthDay],appointmentViewModel.prisonerDetail.name,price] messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self handleAppointmentApply];
            }
        } buttonTitles:notice_disagreed,notice_agreed, nil];
    }
}

- (void)helpAction:(UIButton *)sender {
    NSString*usehelp=NSLocalizedString(@"UseHelp", "使用说明");
    NSString*Directions_for_use=NSLocalizedString(@"Directions_for_use", @"使用说明");
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    [PSAlertView showWithTitle:Directions_for_use message:usehelp messageAlignment:NSTextAlignmentLeft image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        
    } buttonTitles:determine, nil];
}
//购买亲情卡
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
//isWrite 手写的金额还是选项卡
- (void)buyCard:(NSInteger)index isWrite:(BOOL)isWrite {
    
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
        [self goPayindex:index isWrite:isWrite];
    }];
    [payView showAnimated:YES];
    _payView = payView;
}

- (void)goPayindex:(NSInteger)index isWrite:(BOOL)isWrite {
    //埋点数据
    NSString *payinsertWay = isWrite?@"手填":@"选项卡";
    NSString *payCount = [NSString stringWithFormat:@"%ld",index];
    NSString *payEnter = @"远程探视界面";
    
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
                            
                            [SDTrackTool logEvent:BUY_FAMILY_CARD attributes:@{STATUS:MobFAILURE,ERROR_STR:error.domain?error.domain:@"",PAY_TYPE:payInfo.payment,PAY_INSERT_TYPE:payinsertWay,PAY_COUNT:payCount,PAY_ENTER:payEnter}];
                        }
                    }else{
//                        [self.navigationController popViewControllerAnimated:NO];
                        self.payView.status = PSPaySuccessful;
                        [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
                        
                        [SDTrackTool logEvent:BUY_FAMILY_CARD attributes:@{STATUS:MobSUCCESS,PAY_TYPE:payInfo.payment,PAY_INSERT_TYPE:payinsertWay,PAY_COUNT:payCount,PAY_ENTER:payEnter}];
                    }
                }];
            }
        }
    }
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

- (void)handleMeetingStatusMessage:(PSMeetingMessage *)message {
    if (message.status.length > 0 && message.meeting_time.length >= 10) {
        PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
        NSString *meetingDateString = [message.meeting_time substringToIndex:10];
        NSDate *meetingDate = [meetingDateString stringToDateWithFormat:@"yyyy-MM-dd"];
        PSMeeting *meeting = [appointmentViewModel meetingOfDate:meetingDate];
        if (meeting) {
            meeting.status = message.status;
            meeting.meetingTime = message.meeting_time;
            [appointmentViewModel updateMeetingsOfYearMonth:meetingDate.yearMonth];
            if ([meetingDate.yearMonth isEqualToString:self.calendar.currentPage.yearMonth]) {
                [self.calendar reloadData];
                [self.appointmentTableView reloadData];
            }
        }
    }
}

- (void)refreshData:(BOOL)force {
    PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
    @weakify(self)
    [appointmentViewModel requestMeetingsOfYearMonth:[self.calendar.currentPage yearMonth] force:force completed:^(id data) {
        @strongify(self)
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([data count] > 0) {
                [self.calendar reloadData];
            }
            [self.appointmentTableView reloadData];
        }
    }];
}
//MARK:UI
- (void)renderContents {
    UIColor *topColor = UIColorFromHexadecimalRGB(0x264c90);
    self.dateView = [PSDateView new];
    self.dateView.backgroundColor = topColor;
    [self.view addSubview:self.dateView];
    [self.dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *language = langArr.firstObject;
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectZero];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    //self.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
     self.calendar.locale = [NSLocale localeWithLocaleIdentifier:language];
    self.calendar.headerHeight = 0;
    self.calendar.weekdayHeight = 30;
    self.calendar.appearance.weekdayTextColor = [UIColor whiteColor];
    self.calendar.appearance.weekdayFont = FontOfSize(13);
    self.calendar.appearance.titleFont = FontOfSize(13);
    self.calendar.appearance.titleTodayColor = [UIColor whiteColor];
    self.calendar.appearance.titlePlaceholderColor =AppBaseTextColor2;
    self.calendar.appearance.todayColor = topColor;
    self.calendar.appearance.selectionColor = AppBaseTextColor1;
    self.calendar.calendarWeekdayView.backgroundColor = topColor;
    self.calendar.scope = FSCalendarScopeWeek;
    if (IS_iPhone_5) {
       self.calendar.appearance.subtitleFont = FontOfSize(7);
    } else {
       self.calendar.appearance.subtitleFont = FontOfSize(8);
    }
    [self.view insertSubview:self.calendar belowSubview:self.dateView];
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.dateView.mas_bottom).offset(-1);
        make.height.mas_equalTo(260);
    }];
    NSDate *todayNext = [self.calendar.today dateByAddingTimeInterval:24 * 60 * 60];
    [self.calendar selectDate:todayNext];
    [self.dateView setNowDate:self.calendar.today selectedDate:self.calendar.selectedDate];
    
    UIButton *applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [applyButton addTarget:self action:@selector(requsetPhoneCardBalance) forControlEvents:UIControlEventTouchUpInside];
    applyButton.titleLabel.font = AppBaseTextFont1;
    UIImage *bgImage = [UIImage imageNamed:@"universalBtGradientBg"];
    [applyButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*Application_familyPhone=NSLocalizedString(@"Application_familyPhone", @"申请远程探视");
    [applyButton setTitle:Application_familyPhone forState:UIControlStateNormal];
    [self.view addSubview:applyButton];
    [applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.centerX.mas_equalTo(self.view);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    self.appointmentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.appointmentTableView.dataSource = self;
    self.appointmentTableView.delegate = self;
    self.appointmentTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.appointmentTableView.tableFooterView = [UIView new];
    [self.appointmentTableView registerClass:[PSAppointmentDetailCell class] forCellReuseIdentifier:@"PSAppointmentDetailCell"];
    [self.appointmentTableView registerClass:[PSAppointmentProcessView class] forCellReuseIdentifier:@"PSAppointmentProcessView"];
    [self.appointmentTableView registerClass:[PSAppointmentInstructionCell class] forCellReuseIdentifier:@"PSAppointmentInstructionCell"];
    [self.appointmentTableView registerClass:[PSLastCallInfoCell class] forCellReuseIdentifier:@"PSLastCallInfoCell"];
    [self.view addSubview:self.appointmentTableView];
    self.appointmentTableView.tableHeaderView = [UIView new];
    [self.appointmentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(applyButton.mas_top).offset(-20);
        make.top.mas_equalTo(self.calendar.mas_bottom).offset(0);
    }];
    
    //增加拉拽事件
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.calendar action:@selector(handleScopeGesture:)];
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGesture];
    self.scopeGesture = panGesture;
    [self.appointmentTableView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
    [self.calendar addObserver:self forKeyPath:@"scope" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:_KVOContext];
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
    
    
}

- (void)requestPhoneCard {
    PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [appointmentViewModel requestPhoneCardCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self renderContents];
        [self refreshData:YES];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self renderContents];
        [self refreshData:YES];
    }];
}



-(void)requsetPhoneCardBalance{
    //查询余额
     AccountsViewModel*accountsViewModel=[[AccountsViewModel alloc]init];
    [accountsViewModel requestAccountsCompleted:^(PSResponse *response) {
        self.Balance=[accountsViewModel.blance floatValue];
        //查询是该日期否能预约
        accountsViewModel.applicationDate = [self.calendar.selectedDate yearMonthDay];
        [accountsViewModel requestCheckDataCompleted:^(PSResponse *response) {
            NSInteger code = response.code;
            if (code==200) {
                [self addPrisonerFamliesAction];
            } else {
                NSString *msg = response.msg?response.msg:@"当天不支持会见!";
                [PSAlertView showWithTitle:nil message:msg messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                } buttonTitles:@"确定", nil];
            }
            
        } failed:^(NSError *error) {
            [self showNetError:error];
        }];

    } failed:^(NSError *error) {
        if (error.code>=500) {
            [self showInternetError];
        }else{
            [self showNetError:error];
        }
    }];
}

- (BOOL)judgeNowDate:(NSDate *)nowDate selectedDate:(NSDate *)seletedDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:nowDate];
    nowDateComponents.hour = 0;
    nowDateComponents.second = 0;
    NSDate *newNowDate = [calendar dateFromComponents:nowDateComponents];
    NSDateComponents *selectedDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:seletedDate];
    selectedDateComponents.hour = 0;
    selectedDateComponents.second = 0;
    NSDate *newSelectedDate = [calendar dateFromComponents:selectedDateComponents];
    NSTimeInterval timeInterval = [newSelectedDate timeIntervalSinceDate:newNowDate];
    NSInteger days = ceil(timeInterval / (24*60*60));
    
    if (days > 60) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 70;
    } else if (indexPath.row==1) {
        return 110;
    } else if (indexPath.row==2) {
        return 350;
    } else {
        return 70;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        {
            PSLastCallInfoCell *cell1 = nil;
            cell1 = (PSLastCallInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"PSLastCallInfoCell"];
            PSInstructionsDataView*instructionsDataView=[[PSInstructionsDataView alloc]init];
            [cell1 addSubview:instructionsDataView];
            PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
            PSMeeting *latestFinishedMeeting = [appointmentViewModel latestFinishedMeetingOfDate:self.calendar.currentPage];
            NSString*Last_call_time=NSLocalizedString(@"Last_call_time", @"上次通话时间：暂无通话");
            cell1.titleLab.text = latestFinishedMeeting ? [NSString stringWithFormat:@"上次通话时间：%@",latestFinishedMeeting.meetingTime] : Last_call_time;
            return cell1;

            
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PSAppointmentDetailCell"];
            PSAppointmentDetailCell *detailCell = (PSAppointmentDetailCell *)cell;
            @weakify(self)
            NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
            NSString*language = langArr.firstObject;
            if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
               detailCell.buyButton.hidden=YES;
            }
            else{
            [detailCell.buyButton bk_whenTapped:^{
                @strongify(self)
                detailCell.buyButton.hidden=NO;
                [self buyCardAction];
            }];
            }
            AccountsViewModel*accountsModel=[[AccountsViewModel alloc]init];
            [accountsModel requestAccountsCompleted:^(PSResponse *response) {
                detailCell.balanceLabel.text = [NSString stringWithFormat:@"¥%.2f",[accountsModel.blance floatValue]];
            } failed:^(NSError *error) {
                [PSTipsView showTips:@"获取余额失败"];
            }];


            PSAppointmentViewModel *appointmentViewModel = (PSAppointmentViewModel *)self.viewModel;
            NSInteger times = [appointmentViewModel passedMeetingTimesOfDate:self.calendar.currentPage];
            NSMutableAttributedString *timesString = [NSMutableAttributedString new];
            [timesString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)times] attributes:@{NSFontAttributeName:FontOfSize(14),NSForegroundColorAttributeName:UIColorFromHexadecimalRGB(0x333333)}]];
            NSString*one=NSLocalizedString(@"one", @"次");
            [timesString appendAttributedString:[[NSAttributedString alloc] initWithString:one attributes:@{NSFontAttributeName:FontOfSize(10),NSForegroundColorAttributeName:AppBaseTextColor2}]];
            detailCell.timesLabel.attributedText = timesString;
        }
            break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PSAppointmentProcessView"];
            
        }
            break;
        case 3:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PSAppointmentInstructionCell"];
//            @weakify[(self)
            [((PSAppointmentInstructionCell *)cell).helpButton addTarget:self action:@selector(helpAction:) forControlEvents:UIControlEventTouchUpInside];
            
//            [((PSAppointmentInstructionCell *)cell).helpButton bk_whenTapped:^{
//                @strongify(self)
//                [self helpAction];
//            }];
        }
            break;
        default:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        }
            break;
    }
    return cell;
}

#pragma mark - FSCalendarDataSource
/*
- (nullable NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date {
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    
    NSString *title = nil;
    if ([meeting.status isEqualToString:@"FINISHED"]) {
        title = @"完";
    }else if ([meeting.status isEqualToString:@"PENDING"]) {
        title = @"审";
    }else if ([meeting.status isEqualToString:@"CANCELED"]) {
        title = @"取";
    }else if ([meeting.status isEqualToString:@"DENIED"]) {
        title = @"拒";
    }else if ([meeting.status isEqualToString:@"PASSED"]) {
        title = @"待";
        
    }
    else if ([meeting.status isEqualToString:@"EXPIRED"]) {
        title = @"过";
        
    }else if (![calendar.today isEqualToDate:calendar.selectedDate] && [calendar.today isEqualToDate:date]) {
        title = @"今";
    }
    return title;
}
*/
- (nullable NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date {
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    NSString *subtitle = nil;
    if ([meeting.status isEqualToString:@"PASSED"]) {
        subtitle = meeting.meetingPeriod;
    }
    return subtitle;
}

#pragma mark - FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    if (![[self.calendar.currentPage yearMonth] isEqualToString:[date yearMonth]]) {
        [self.calendar selectDate:date scrollToDate:YES];
    }
    [self.dateView setNowDate:self.calendar.today selectedDate:self.calendar.selectedDate];
    [self.calendar reloadData];
}




- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    [self.calendar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.dateView.mas_bottom).offset(-1);
        make.height.mas_equalTo(CGRectGetHeight(bounds));
    }];
    [self.view layoutIfNeeded];
}



- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    if (![self.calendar.selectedDate.yearMonth isEqualToString:self.calendar.currentPage.yearMonth]) {
        if ([self.calendar.currentPage.yearMonth isEqualToString:self.calendar.today.yearMonth]) {
            if (![self.calendar.selectedDate.yearMonthDay isEqualToString:self.calendar.today.yearMonthDay]) {
                NSDate *todayNext = [self.calendar.today dateByAddingTimeInterval:24 * 60 * 60];
                [self.calendar selectDate:todayNext];
            }
        }else{
            [self.calendar selectDate:self.calendar.currentPage];
        }
    }
    [self.dateView setNowDate:self.calendar.today selectedDate:self.calendar.selectedDate];
    [self refreshData:NO];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    BOOL shouldSelect = NO;
    if (([date compare:self.calendar.today] == NSOrderedDescending)&&[self judgeNowDate:self.calendar.today selectedDate:date]) {
        shouldSelect = YES;

    }
    return shouldSelect;
}

#pragma mark - FSCalendarDelegateAppearance
- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleOffsetForDate:(NSDate *)date {
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    CGPoint offset = CGPointZero;
    if ([meeting.status isEqualToString:@"PASSED"]) {
        offset = CGPointMake(0, 5);
    }
    return offset;
}


- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleOffsetForDate:(NSDate *)date {
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    CGPoint offset = CGPointZero;
    if ([meeting.status isEqualToString:@"PASSED"]) {
        offset = CGPointMake(0, 12);
    }
    return offset;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    UIColor *color = nil;
    if ([meeting.status isEqualToString:@"EXPIRED"]) {
        color = AppBaseTextColor1;
    }else if ([meeting.status isEqualToString:@"FINISHED"]){
        color = UIColorFromRGB(83, 119, 185);
    }else if ([meeting.status isEqualToString:@"PENDING"]) {
        color = UIColorFromHexadecimalRGB(0xff8a07);
    }else if ([meeting.status isEqualToString:@"CANCELED"] || [meeting.status isEqualToString:@"DENIED"]) {
        color = [UIColor redColor];
    }else if ([meeting.status isEqualToString:@"PASSED"]) {
        //color = [UIColor purpleColor];
        color=UIColorFromRGB(0, 142, 60);
    }
    return color;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    UIColor *color = nil;
    if ([meeting.status isEqualToString:@"FINISHED"]) {
        color = AppBaseTextColor1;
    }else if ([meeting.status isEqualToString:@"PENDING"]) {
        color = UIColorFromHexadecimalRGB(0xff8a07);
    }else if ([meeting.status isEqualToString:@"CANCELED"] || [meeting.status isEqualToString:@"DENIED"]) {
        color = [UIColor redColor];
    }else if ([meeting.status isEqualToString:@"PASSED"]) {
        //color = [UIColor purpleColor];
        color=UIColorFromRGB(0, 142, 60);
    }
    return color;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    UIColor *defaultColor =UIColorFromHexadecimalRGB(0x333333);
    PSAppointmentViewModel *appointment = (PSAppointmentViewModel *)self.viewModel;
    PSMeeting *meeting = [appointment meetingOfDate:date];
    if (meeting || [date isEqualToDate:calendar.today]) {
        defaultColor = [UIColor whiteColor];
    }
    else if (!([date compare:self.calendar.today] == NSOrderedDescending)){
        defaultColor = AppBaseTextColor2;
    }
    else if (![self judgeNowDate:self.calendar.today selectedDate:date]){
        defaultColor = AppBaseTextColor2;
    }
    return defaultColor;
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date {
    
   
    return AppBaseTextColor1;
    
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance subtitleSelectionColorForDate:(NSDate *)date {
    return AppBaseTextColor1;
}

#pragma mark - PSIMMessageObserver
- (void)receivedMeetingMessage:(PSMeetingMessage *)message {
    switch (message.code) {
        case PSMeetingStart:
        {
            
        }
            break;
        case PSMeetingEnter:
        {
            //进入会议
            [self handleMeetingStatusMessage:message];
        }
            break;
        case PSMeetingEnd:
        {
            
        }
            break;
        case PSMeetingStatus:
        {
            [self handleMeetingStatusMessage:message];
            [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - PSSessionObserver
- (void)userBalanceDidSynchronized {
    [self.appointmentTableView reloadData];
}


#pragma mark - Setting&Getting
- (PSBuyCardView *)buyCardView {
    if (!_buyCardView) {
        
        _buyCardView = [[PSBuyCardView alloc] initWithFrame:CGRectZero buyModel:_buyModel index:1];
        @weakify(self);
        _buyCardView.buyBlock = ^(NSInteger index, BOOL isWrite) {
            @strongify(self);
            [self buyCard:index isWrite:isWrite];
        };
    }
    return _buyCardView;
}

#pragma mark - Update UI 5.27 
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == _KVOContext) {
        FSCalendarScope oldScope = [change[NSKeyValueChangeOldKey] unsignedIntegerValue];
        FSCalendarScope newScope = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        NSLog(@"From %@ to %@",(oldScope==FSCalendarScopeWeek?@"week":@"month"),(newScope==FSCalendarScopeWeek?@"week":@"month"));
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

// Whether scope gesture should begin
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = self.appointmentTableView.contentOffset.y <= -self.appointmentTableView.contentInset.top;
    if (shouldBegin) {
        CGPoint velocity = [self.scopeGesture velocityInView:self.view];
        switch (self.calendar.scope) {
                case FSCalendarScopeMonth:
                return velocity.y < 0;
                case FSCalendarScopeWeek:
                return velocity.y > 0;
        }
    }
    return shouldBegin;
}





@end
