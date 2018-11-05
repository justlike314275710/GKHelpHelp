//
//  PSMeViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/17.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "PSPrisonerManageViewController.h"
#import "PSHistoryViewController.h"
#import "PSBalanceViewController.h"
#import "PSSettingViewController.h"
#import "PSSettingViewModel.h"
#import "PSLoginViewController.h"
#import "PSSettingSectionModel.h"
#import "PSBusinessConstants.h"
#import "PSSettingItemModel.h"
#import "PSMeViewController.h"
#import "PSSettingCell.h"
#import "PSLoginViewModel.h"
#import "PSSessionManager.h"
#import "PYPhotoBrowser.h"
#import "AccountsViewModel.h"
#import "PSMeetingHistoryViewModel.h"
#import "PSPurchaseViewController.h"
#import "PSSettingViewModel.h"
#import "PSSessionNoneViewController.h"
#import "PSAddFamiliesViewController.h"
#import "PSRegisterViewModel.h"
#import "PSFamilyServiceViewController.h"
#import "PSPurchaseViewModel.h"
#import "PSAccountViewController.h"
#import "PSAccountViewModel.h"
#import "PSMyAdviceViewController.h"
#import "PSConsultationViewModel.h"
#import "PSFamilyRemittanceViewController.h"
#import "PSFamilyRemittanceViewModel.h"

@interface PSMeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) UITableView *settingTableview;
@property (nonatomic,strong) NSArray *modelArray;
@property (nonatomic, strong, readonly) PYPhotosView *avatarView;
@property (nonatomic , strong) NSString *PrisonerDetailName;
@property (nonatomic , strong) NSString *balanceSting;
@end

@implementation PSMeViewController


#pragma mark  - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshData];
    // Do any additional setup after loading the view.
}
#pragma mark  - notification

#pragma mark  - action
-(void)refreshData{
    NSString*home_me=NSLocalizedString(@"home_me", @"我的");
    self.title=home_me;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestBalance) name:JailChange object:nil];
    self.view.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
    self.settingTableview.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:{
            [self updateContent];
            [self requestBalance];
            [self renderContents];
        }
            break;
        default:
            [self setupModelArray];
            [self renderContents];
            break;
    }

}


-(void)requestBalance{
    [[PSLoadingView sharedInstance]show];
    AccountsViewModel*accountsModel=[[AccountsViewModel alloc]init];
    [accountsModel requestAccountsCompleted:^(PSResponse *response) {
        self.balanceSting=[NSString stringWithFormat:@"¥%.2f",[accountsModel.blance floatValue]];
        [[PSLoadingView sharedInstance]dismiss];
        [self setupModelArray];
        [self.settingTableview reloadData];
    } failed:^(NSError *error) {
       // [PSTipsView showTips:@"获取余额失败"];
        [[PSLoadingView sharedInstance]dismiss];
    }];
    
}
- (void)headerViewTapAction:(id)tap {
    
    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:{
           [self.navigationController pushViewController:[[PSAccountViewController alloc] initWithViewModel:[[PSAccountViewModel alloc] init]] animated:YES];
        }
            break;
        default:
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]init] animated:YES];
            self.hidesBottomBarWhenPushed=NO;
            break;
    }
}


- (void)selectHallFunctionAtIndex:(NSInteger)index {
    PSSettingItemModel*itemModel=self.modelArray[index];
    NSString*VI_member=NSLocalizedString(@"VI_member", @"服刑人员");
    NSString*telephone_balance=
    NSLocalizedString(@"telephone_balance", @"亲情电话余额");
    NSString*userCenterHistory=
    NSLocalizedString(@"userCenterHistory", @"会见历史");
    NSString*recharge_record=
    NSLocalizedString(@"recharge_record", @"充值记录");
    NSString*userCenterAccreditation=
    NSLocalizedString(@"userCenterAccreditation", @"家属认证");
    NSString*my_advice=NSLocalizedString(@"my_advice", @"我的咨询");
    NSString*add_relatives=NSLocalizedString(@"add_relatives", @"添加亲属");
    NSString*family_server=NSLocalizedString(@"family_server", @"家属服务");
    NSString*family_remittance = NSLocalizedString(@"family_remittance", @"家属汇款");
    NSString*userCenterSetting=NSLocalizedString(@"userCenterSetting", @"设置");
    if ([itemModel.funcName isEqualToString:VI_member]) {
        [self managePrisoner];
    }
    else if ([itemModel.funcName isEqualToString:telephone_balance]){
      
        [self.navigationController pushViewController:[[PSBalanceViewController alloc] init] animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:userCenterHistory]){
        [self.navigationController pushViewController:[[PSHistoryViewController alloc]initWithViewModel:[[PSMeetingHistoryViewModel alloc]init]]animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:recharge_record]){
        [self.navigationController pushViewController:[[PSPurchaseViewController alloc] initWithViewModel:[[PSPurchaseViewModel alloc] init]] animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:userCenterAccreditation]){
        [self.navigationController pushViewController:[[PSSessionNoneViewController alloc] init] animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:add_relatives ]){
        [self.navigationController pushViewController:[[PSAddFamiliesViewController alloc] initWithViewModel:[[PSRegisterViewModel alloc]init]] animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:family_server]){
        PSFamilyServiceViewController *serviceViewController = [[PSFamilyServiceViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
        [self.navigationController pushViewController:serviceViewController animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:family_remittance]){
        PSFamilyRemittanceViewController *remittanceViewController = [[PSFamilyRemittanceViewController alloc] initWithViewModel:[PSFamilyRemittanceViewModel new]];
        [self.navigationController pushViewController:remittanceViewController animated:YES];
    }
    else if ([itemModel.funcName isEqualToString:userCenterSetting]){
        [self.navigationController pushViewController:[[PSSettingViewController alloc] initWithViewModel:[[PSSettingViewModel alloc] init]] animated:YES];
        
    }
    else if ([itemModel.funcName isEqualToString:my_advice]){
        [self.navigationController pushViewController:[[PSMyAdviceViewController alloc] initWithViewModel:[[PSConsultationViewModel alloc] init]] animated:YES];
        
    }
    else{
        NSString*coming_soon=NSLocalizedString(@"coming_soon", @"敬请期待");
        [PSTipsView showTips:coming_soon];
    }
    
}

- (void)managePrisoner {
    
    PSPrisonerManageViewController *manageViewController = [[PSPrisonerManageViewController alloc] initWithViewModel:self.viewModel];
    [manageViewController setDidManaged:^{
        [self updateContent];
    }];
    [self.navigationController pushViewController:manageViewController animated:YES];
}

- (void)updateContent {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    NSInteger selectedIndex = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails.count > selectedIndex ? homeViewModel.passedPrisonerDetails[selectedIndex] : nil;
    self.PrisonerDetailName=prisonerDetail.name;
    [self setupModelArray];
    [self.settingTableview reloadData];

    
}
#pragma mark  - UITableViewDelegate



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PSSettingCell";
    PSSettingItemModel*itemModel=self.modelArray[indexPath.row];
    PSSettingCell*cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PSSettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.item=itemModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:{
             [self selectHallFunctionAtIndex:indexPath.row];
        }
            break;
        default:
            
            if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]) {
                [[PSSessionManager sharedInstance]doLogout];
            } else {
                if (indexPath.row==9) {
                    [self.navigationController pushViewController:[[PSSettingViewController alloc] initWithViewModel:[[PSSettingViewModel alloc] init]] animated:YES];
                } else {
                    self.hidesBottomBarWhenPushed=YES;
                    PSLoginViewModel*viewModel=[[PSLoginViewModel alloc]init];
                    [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]initWithViewModel:viewModel] animated:YES];
                    self.hidesBottomBarWhenPushed=NO;
                }
            }
            break;
    }
    //[self selectHallFunctionAtIndex:indexPath.row];
}

#pragma mark  - UI
- (void)renderContents {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
     [self.view addSubview:headerView];
    //headerView.backgroundColor =UIColorFromRGBA(234, 234, 234, 1);
    UIImageView *headerBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    headerBgImageView.image = [UIImage imageNamed:@"我的顶部背景"];
    [headerView addSubview:headerBgImageView];
    
      UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerViewTapAction:)];
        [headerView addGestureRecognizer:tapGesturRecognizer];

    
    
    CGFloat radius = 34;
    _avatarView = [PYPhotosView photosView];
    _avatarView.frame=CGRectMake(27, 35, 68, 68);
    _avatarView.layer.cornerRadius = radius;
    _avatarView.layer.borderWidth = 1.0;
    _avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    _avatarView.photoWidth = radius * 2;
    _avatarView.photoHeight = radius * 2;
    _avatarView.placeholderImage = [UIImage imageNamed:@"个人中心-头像"];
      [headerView addSubview:_avatarView];
    _avatarView.thumbnailUrls = @[PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
    _avatarView.originalUrls = @[PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
    

    
    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]) {
        UIButton*loginButton=[[UIButton alloc]initWithFrame:CGRectMake(130, 37, 180, 42)];
        [headerView addSubview:loginButton];
        NSString*click_login=NSLocalizedString(@"click_login", @"点击登录");
        [loginButton setTitle:click_login forState:0];
        loginButton.titleLabel.font=FontOfSize(18);
        [loginButton setBackgroundColor:[UIColor clearColor]];
        [loginButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [loginButton.layer setBorderWidth:1.0];
        [loginButton bk_whenTapped:^{
            [[PSSessionManager sharedInstance]doLogout];
        }];
        
    } else {
    
    UILabel*nameLable=[[UILabel alloc]initWithFrame:CGRectMake(105, 37, 180, 22)];
    nameLable.text=[PSSessionManager sharedInstance].session.families.name?[PSSessionManager sharedInstance].session.families.name:[LXFileManager readUserDataForKey:@"phoneNumber"];
    [nameLable setTextColor:[UIColor whiteColor]];
    [nameLable setFont:FontOfSize(18)];
    [headerView addSubview:nameLable];
    
    UILabel*phoneLable=[[UILabel alloc]initWithFrame:CGRectMake(105, 60, 180, 40)];
    phoneLable.text= [[PSSessionManager sharedInstance].session.families.phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    [phoneLable setTextColor:[UIColor whiteColor]];
    [phoneLable setFont:FontOfSize(14)];
    [headerView addSubview:phoneLable];
    }
    
    self.settingTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.settingTableview.showsVerticalScrollIndicator=NO;
    self.settingTableview.dataSource = self;
    self.settingTableview.delegate = self;
    self.settingTableview.tableFooterView = [UIView new];
    [self.settingTableview  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.settingTableview registerClass:[PSSettingCell class] forCellReuseIdentifier:@"PSSettingCell"];
    [self.view addSubview:self.settingTableview];
    [self.settingTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(140);
        make.bottom.mas_equalTo(-60);
    }];
}
#pragma mark  - setter & getter


- (void)setupModelArray
{
    PSSettingItemModel *nameItem = [[PSSettingItemModel alloc]init];
    NSString*VI_member=NSLocalizedString(@"VI_member", @"服刑人员");
    nameItem.funcName = VI_member;
    nameItem.img = [UIImage imageNamed:@"服刑人员"];
    nameItem.detailText = self.PrisonerDetailName;
    nameItem.accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    
    PSSettingItemModel *balanceItem = [[PSSettingItemModel alloc]init];
    NSString*telephone_balance=NSLocalizedString(@"telephone_balance", @"亲情电话余额");
    balanceItem.funcName =telephone_balance;
    balanceItem.img = [UIImage imageNamed:@"亲情电话余额"];
    balanceItem.detailText =self.balanceSting;
    balanceItem.accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    PSSettingItemModel *historyItem = [[PSSettingItemModel alloc]init];
    NSString*userCenterHistory=
    NSLocalizedString(@"userCenterHistory", @"会见历史");
    historyItem.funcName = userCenterHistory;
    historyItem.img = [UIImage imageNamed:@"会见历史"];
    historyItem.accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    PSSettingItemModel *RechargeItem = [[PSSettingItemModel alloc]init];
    NSString*recharge_record=NSLocalizedString(@"recharge_record", @"充值记录");
    RechargeItem.funcName =recharge_record;
    RechargeItem.img = [UIImage imageNamed:@"充值记录"];
    RechargeItem.accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    
    PSSettingItemModel *ConsultationItem = [[PSSettingItemModel alloc]init];
    NSString*my_advice=NSLocalizedString(@"my_advice", @"我的咨询");
    ConsultationItem.funcName = my_advice;
    ConsultationItem.img = [UIImage imageNamed:@"我的咨询"];
    ConsultationItem.accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    PSSettingItemModel *AuthenticationItem = [[PSSettingItemModel alloc]init];
    NSString*userCenterAccreditation=
    NSLocalizedString(@"userCenterAccreditation", @"家属认证");
    AuthenticationItem .funcName = userCenterAccreditation;
    AuthenticationItem .img = [UIImage imageNamed:@"家属认证"];
    AuthenticationItem .accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    PSSettingItemModel *addFamilyItem = [[PSSettingItemModel alloc]init];
    NSString*add_relatives=NSLocalizedString(@"add_relatives", @"添加亲属");
    addFamilyItem .funcName =add_relatives;
    addFamilyItem .img = [UIImage imageNamed:@"添加家属"];
    addFamilyItem .accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    PSSettingItemModel *familyServiceItem = [[PSSettingItemModel alloc]init];
    NSString*family_server=NSLocalizedString(@"family_server", @"家属服务");
    familyServiceItem .funcName = family_server;
    familyServiceItem .img = [UIImage imageNamed:@"家属服务"];
    familyServiceItem .accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    PSSettingItemModel *familyRemittanceItem = [[PSSettingItemModel alloc] init];
    NSString *family_remittance = NSLocalizedString(@"family_remittance", @"家属汇款");
    familyRemittanceItem.funcName = family_remittance;
    familyRemittanceItem.img = [UIImage imageNamed:@"家属汇款"];
    familyRemittanceItem.accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    
    
    
    
    PSSettingItemModel *settingItem = [[PSSettingItemModel alloc]init];
    NSString*userCenterSetting=NSLocalizedString(@"userCenterSetting", @"设置");
    settingItem .funcName = userCenterSetting;
    settingItem .img = [UIImage imageNamed:@"设置"];
    settingItem .accessoryType = PSSettingAccessoryTypeDisclosureIndicator;
    _modelArray = @[nameItem,balanceItem,historyItem,RechargeItem,ConsultationItem,AuthenticationItem,addFamilyItem,familyServiceItem,familyRemittanceItem,settingItem];

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
