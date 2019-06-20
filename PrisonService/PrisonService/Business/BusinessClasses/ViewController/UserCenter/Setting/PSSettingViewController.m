//
//  PSSettingViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSSettingViewController.h"
#import "PSSwitch.h"
#import "YYText.h"
#import "PSTipsConstants.h"
#import "PSProtocolViewController.h"
#import "PSAlertView.h"
#import "PSWriteFeedbackViewController.h"
#import "PSSessionManager.h"
#import "PSLoginViewModel.h"
#import "PSSessionNoneViewController.h"
#import "PSStorageViewController.h"
#import "PSSorageViewModel.h"
#import "PSWriteFeedbackListViewController.h"
#import "PSFeedbackListViewModel.h"
#import "PSPasswordViewController.h"
#import "PSPasswordViewModel.h"
#import "PSResetPasswordViewController.h"
@interface PSSettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *settingTableView;

@end

@implementation PSSettingViewController
- (id)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*userCenterSetting=NSLocalizedString(@"userCenterSetting", @"设置");
        self.title = userCenterSetting;
    }
    return self;
}

- (void)openProtocol {
    PSProtocolViewController *protocolViewController = [[PSProtocolViewController alloc] init];
    [self presentViewController:protocolViewController animated:YES completion:nil];
//    [self.navigationController pushViewController:protocolViewController animated:YES];
}

- (void)contactUs {
    NSString*ContactUs=NSLocalizedString(@"ContactUs", @"联系我们");
    NSString*cancel=NSLocalizedString(@"cancel", @"取消");
    NSString*immediately=NSLocalizedString(@"immediately", @"立即联系");
    NSString*ContactDetail=NSLocalizedString(@"ContactDetail", ContactDetails);
    [PSAlertView showWithTitle:ContactUs message:ContactDetail messageAlignment:NSTextAlignmentLeft image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *phoneUrl = [NSString stringWithFormat:@"tel://%@",ContactPhone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrl]];
        }
    } buttonTitles:cancel,immediately, nil];
}

- (void)writeFeedback {

    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:{
            PSFeedbackListViewModel *viewModel = [PSFeedbackListViewModel new];
            viewModel.writefeedType = PSWritefeedBack;
            PSWriteFeedbackListViewController *feedbackListVC = [[PSWriteFeedbackListViewController alloc] initWithViewModel:viewModel];
            [self.navigationController pushViewController:feedbackListVC animated:YES];
            
        }
            break;
        default:
        {
            PSLoginViewModel*viewModel=[[PSLoginViewModel alloc]init];
            [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]initWithViewModel:viewModel] animated:YES];
        }
        break;
    }
}

-(void)passWordSave{
    PSPasswordViewModel*viewModel=[[PSPasswordViewModel alloc]init];
    [viewModel requestBoolPasswordCompleted:^(PSResponse *response) {
        [self.navigationController pushViewController:[[PSResetPasswordViewController alloc]initWithViewModel:viewModel] animated:YES];
    } failed:^(NSError *error) {
        [PSAlertView showWithTitle:@"提示" message:@"请先设置密码" messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
            [self.navigationController pushViewController:[[PSPasswordViewController alloc]initWithViewModel:viewModel] animated:YES];
            }
        } buttonTitles:@"取消",@"设置", nil];
    }];
    
}

- (void)refreshStorage {
    PSSettingViewModel *settingViewModel = (PSSettingViewModel *)self.viewModel;
    UILabel *valueLab = (UILabel *)[self.view viewWithTag:11];
    if (valueLab) valueLab.text = [settingViewModel allstorage];
}
- (void)insert_storage {
    
    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:{
            PSStorageViewController *storageViewController = [[PSStorageViewController alloc] initWithViewModel:[[PSSorageViewModel alloc] init]];
            storageViewController.clearScuessBlock = ^{
                [self refreshStorage];
            };
            [self.navigationController pushViewController:storageViewController animated:YES];
        }
            break;
        default:
        {
            PSLoginViewModel*viewModel=[[PSLoginViewModel alloc]init];
            [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]initWithViewModel:viewModel] animated:YES];
        }
            break;
    }
}

- (void)logout {
    NSString*Confirm_logout=NSLocalizedString(@"Confirm_logout", @"确定注销账号?");
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    NSString*cancel=NSLocalizedString(@"cancel", @"取消");
    [PSAlertView showWithTitle:nil message:Confirm_logout messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[PSSessionManager sharedInstance] doLogout];
        }
    } buttonTitles:cancel,determine, nil];
}

- (void)renderContents {
    

    
    YYLabel *extraLabel = [YYLabel new];
    extraLabel.backgroundColor = [UIColor clearColor];
    extraLabel.numberOfLines = 0;
    NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle new];
    paraStyle.lineSpacing = 3.0;
    NSMutableAttributedString *extraString = [NSMutableAttributedString new];
    NSString*usageProtocol_ContactUs=NSLocalizedString(@"usageProtocol_ContactUs", @"狱务通软件使用协议 | 联系我们\n");
    [extraString appendAttributedString:[[NSAttributedString alloc] initWithString:usageProtocol_ContactUs attributes:@{NSFontAttributeName:AppBaseTextFont2,NSForegroundColorAttributeName:AppBaseTextColor3,NSParagraphStyleAttributeName:paraStyle}]];
    NSString*company_CopyRight=NSLocalizedString(@"company_CopyRight", @"公司copyright");
    [extraString appendAttributedString:[[NSAttributedString alloc] initWithString:company_CopyRight attributes:@{NSFontAttributeName:AppBaseTextFont2,NSForegroundColorAttributeName:AppBaseTextColor2,NSParagraphStyleAttributeName:paraStyle}]];
    extraString.yy_alignment = NSTextAlignmentCenter;
    extraLabel.attributedText = extraString;
    [self.view addSubview:extraLabel];
    [extraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo([NSObject judegeIsVietnamVersion]?100:60);
    }];
    @weakify(self)
    [extraLabel setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        @strongify(self)
        NSString *tapString = [text yy_plainTextForRange:range];
        NSString*usageProtocol=NSLocalizedString(@"usageProtocol", @"狱务通软件使用协议");
        //NSString *protocolString = @"狱务通软件使用协议";
        //NSString *contactString = @"联系我们";
        NSString *ContactUs=NSLocalizedString(@"ContactUs", @"联系我们");
        if (tapString) {
            if ([usageProtocol containsString:tapString]) {
                [self openProtocol];
            }else if([ContactUs containsString:tapString]){
                [self contactUs];
            }
        }
    }];
    self.settingTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.settingTableView.backgroundColor = AppBaseBackgroundColor2;
    self.settingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.settingTableView.dataSource = self;
    self.settingTableView.delegate = self;
    self.settingTableView.separatorInset =UIEdgeInsetsMake(0, 15, 0, 15);
    self.settingTableView.tableFooterView = [UIView new];
    [self.settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:self.settingTableView];
    [self.settingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(extraLabel.mas_top).offset(-20);
    }];
    
    UIButton*loginOutBtn =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-45, SCREEN_HEIGHT-240, 90, 35)];
    loginOutBtn.titleLabel.numberOfLines=0;
    [loginOutBtn setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    loginOutBtn.titleLabel.font = AppBaseTextFont1;
    [loginOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*loginout=NSLocalizedString(@"loginout", @"退出账号");
    [loginOutBtn setTitle:loginout forState:UIControlStateNormal];
    [self.view addSubview:loginOutBtn];
    [loginOutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
}

- (PSSwitch *)statusSwitch {
    PSSwitch *mySwitch = [[PSSwitch alloc] initWithFrame:CGRectMake(0, 0, 27, 16)];
    return mySwitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self refreshStorage];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    PSSettingViewModel *settingViewModel = (PSSettingViewModel *)self.viewModel;
    return settingViewModel.settingItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSSettingViewModel *settingViewModel = (PSSettingViewModel *)self.viewModel;
    return [settingViewModel.settingItems[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.font = AppBaseTextFont2;
    cell.textLabel.textColor = AppBaseTextColor1;
    cell.detailTextLabel.font = AppBaseTextFont2;
    cell.detailTextLabel.textColor = AppBaseTextColor1;
    PSSettingViewModel *settingViewModel = (PSSettingViewModel *)self.viewModel;
    PSSettingItem *settingitem = settingViewModel.settingItems[indexPath.section][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:settingitem.itemIconName];
    cell.textLabel.text = settingitem.itemName;
    
    UILabel *valueLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-120,(cell.contentView.height-20)/2,100, 20)];
    valueLab.textAlignment = NSTextAlignmentRight;
    valueLab.text = settingitem.itemValue;
    valueLab.textColor = UIColorFromRGB(153,153,153);
    valueLab.font = FontOfSize(12);
    valueLab.tag = indexPath.section+10;
    [cell.contentView addSubview:valueLab];
    
    if ([settingitem.itemName isEqualToString:@"闹钟提醒"]) {
        PSSwitch *mySwitch = [self statusSwitch];
        mySwitch.on = YES;
        cell.accessoryView = mySwitch;
    }else if ([settingitem.itemName isEqualToString:@"独立密码设置"]) {
        PSSwitch *mySwitch = [self statusSwitch];
        cell.accessoryView = mySwitch;
    }else{
        cell.accessoryView = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSSettingViewModel *settingViewModel = (PSSettingViewModel *)self.viewModel;
    PSSettingItem *settingitem = settingViewModel.settingItems[indexPath.section][indexPath.row];
    NSString*feedback=NSLocalizedString(@"feedback", @"意见反馈");
    NSString*storage = NSLocalizedString(@"storage", @"存储空间");
    NSString*passWord=@"重置密码";
    if ([settingitem.itemName isEqualToString:feedback]) {
        [self writeFeedback];
    }
    if ([settingitem.itemName isEqualToString:storage]) {
        [self insert_storage];
    }
    if ([settingitem.itemName isEqualToString:passWord]) {
        [self passWordSave];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
