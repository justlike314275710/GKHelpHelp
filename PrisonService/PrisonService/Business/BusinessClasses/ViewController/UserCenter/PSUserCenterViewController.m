//
//  PSUserCenterViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/3.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSUserCenterViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "PSUserCenterTopView.h"
#import "PSAccountViewController.h"
#import "PSContentManager.h"
#import "PSPurchaseViewController.h"
#import "PSSettingViewController.h"
#import "PSBalanceViewController.h"
#import "PSSessionManager.h"
#import "PSAlertView.h"
#import "PSBusinessConstants.h"
#import "PSHistoryViewController.h"
#import "PSMeetingHistoryViewModel.h"
#import "PSRegisterViewModel.h"
#import "VIRegisterViewModel.h"

#import "PSSessionPassedViewController.h"
#import "PSSessionPendingController.h"
#import "PSSessionNoneViewController.h"
#import "PSAddFamiliesViewController.h"
#import "VIAddFamilesViewController.h"
@interface PSUserCenterViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) PSUserCenterTopView *topView;
@property (nonatomic, strong) UITableView *contentTableView;

@end

@implementation PSUserCenterViewController

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

-(void)showAlertWithmessage:(NSString*)message{
    UIAlertController*alert=[UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction*sureAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PSSessionManager sharedInstance] doLogout];
    }];
    UIAlertAction*cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:nil completion:nil];
}

- (UIViewController *)buildContentViewControllerWithItem:(PSUserCenterItem *)item {
    UIViewController *contentViewController = nil;
    switch (item.itemType) {
        case PSUserCenterAccount:
        {
            contentViewController = [[PSAccountViewController alloc] initWithViewModel:[[PSAccountViewModel alloc] init]];
        }
            break;
            
        case PSUserCenterHistory:
        {
            contentViewController =[[PSHistoryViewController alloc]initWithViewModel:[[PSMeetingHistoryViewModel alloc]init]];
            
        }
            break;
        case PSUserCenterCart:
        {
            contentViewController = [[PSPurchaseViewController alloc] initWithViewModel:[[PSPurchaseViewModel alloc] init]];
        }
            break;
        case PSUserCenterSetting:
        {
            contentViewController = [[PSSettingViewController alloc] initWithViewModel:[[PSSettingViewModel alloc] init]];
        }
            break;
        case PSUserCenterBalance:
        {
            contentViewController = [[PSBalanceViewController alloc] init];
        }
            break;
        case PSUserCenterAuthentication:
        {
             contentViewController = [[PSSessionNoneViewController alloc] init];

        }
            break;
        case PSUserCenterAddFamilies:
        {
            NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
            NSString*language = langArr.firstObject;
              if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
                  contentViewController = [[VIAddFamilesViewController alloc] initWithViewModel:[[VIRegisterViewModel alloc]init]];
             } else {
                contentViewController = [[PSAddFamiliesViewController alloc] initWithViewModel:[[PSRegisterViewModel alloc]init]];
             }
            
        }
            break;
        default:
            break;
    }
    return contentViewController;
}

- (void)renderContents {
    if (!self.contentView) {
        MMDrawerController *drawerController = self.mm_drawerController;
        CGFloat maxLeftDrawerWidth = drawerController.maximumLeftDrawerWidth;
        self.contentView = [UIView new];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(maxLeftDrawerWidth);
        }];
        self.topView = [PSUserCenterTopView new];
        self.topView.avatarView.thumbnailUrls = @[PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
        self.topView.avatarView.originalUrls = @[PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
        [self.contentView addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.mas_equalTo(self.topView.mas_width).multipliedBy(0.75);
        }];
        self.topView.nicknameLabel.text =
        [PSSessionManager sharedInstance].session.families.name?[PSSessionManager sharedInstance].session.families.name:[LXFileManager readUserDataForKey:@"phoneNumber"];

        self.contentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.contentTableView.dataSource = self;
        self.contentTableView.delegate = self;
        [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
        [self.contentView addSubview:self.contentTableView];
        [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.top.mas_equalTo(self.topView.mas_bottom);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self renderContents];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // [self renderContents];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSUserCenterViewModel *userCenterViewModel = (PSUserCenterViewModel *)self.viewModel;
    return userCenterViewModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.font = AppBaseTextFont2;
    cell.textLabel.textColor = AppBaseTextColor1;
    PSUserCenterViewModel *userCenterViewModel = (PSUserCenterViewModel *)self.viewModel;
    PSUserCenterItem *item = userCenterViewModel.items[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:item.itemIconName];
    cell.textLabel.text = item.itemName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSUserCenterViewModel *userCenterViewModel = (PSUserCenterViewModel *)self.viewModel;
    PSUserCenterItem *item = userCenterViewModel.items[indexPath.row];
    if ([PSSessionManager sharedInstance].loginStatus==PSLoginDenied||[PSSessionManager sharedInstance].loginStatus==PSLoginNone||[PSSessionManager sharedInstance].loginStatus==PSLoginPending) {
        if (item.itemType == PSUserCenterLogout) {
            //注销
            [self logout];
        }else{
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
            [[PSContentManager sharedInstance].currentNavigationController pushViewController:[[PSSessionNoneViewController alloc] init] animated:NO];
        }
    }
    else {
        if (item.itemType == PSUserCenterLogout) {
            //注销
            [self logout];
        }
        
        else{
            UIViewController *contentViewController = [self buildContentViewControllerWithItem:item];
            if (contentViewController) {
                [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
                [[PSContentManager sharedInstance].currentNavigationController pushViewController:contentViewController animated:NO];
            }
        }
    }
    
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
