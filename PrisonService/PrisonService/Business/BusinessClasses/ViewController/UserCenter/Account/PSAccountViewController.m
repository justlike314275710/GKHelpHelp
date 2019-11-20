//
//  PSAccountViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAccountViewController.h"
#import "PSAccountTopView.h"
#import "PSAccountInfoCell.h"
#import "PSSessionManager.h"
#import "PSBusinessConstants.h"
#import "PSAccountEmailViewController.h"
#import "PSAccountAddressViewController.h"
#import "PSAccountEditEmailViewModel.h"
#import "PSAccountEditAddressViewModel.h"
#import "PSAlertView.h"
#import "PSchangPhoneViewController.h"
#import "PSEcomRegisterViewmodel.h"
#import "PSAuthorizationTool.h"
#import "PSImagePickerController.h"
#import "PSRegisterViewModel.h"
#import "PSConsultationViewModel.h"
#import "LLActionSheetView.h"

@interface PSAccountViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) PSAccountTopView *acctountTopView;
@property (nonatomic, strong) UITableView *infoTableView;

@end

@implementation PSAccountViewController
- (id)init {
    self = [super init];
    if (self) {
        NSString*userCenterAccount=NSLocalizedString(@"userCenterAccount", @"账号信息");
        self.title = userCenterAccount;
        
    }
    return self;
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)renderContents {
    PSAccountViewModel *accountViewModel =(PSAccountViewModel *)self.viewModel;
    self.acctountTopView = [PSAccountTopView new];
    //[self.acctountTopView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)] placeholderImage:[UIImage imageNamed:@"userCenterDefaultAvatar"]];
//    self.acctountTopView.avatarView.thumbnailUrls = @[PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
//    self.acctountTopView.avatarView.originalUrls = @[PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
    
    //_avatarView.placeholderImage = [UIImage imageNamed:@"userCenterDefaultAvatar"];
    NSURL *imageURL  = [NSURL URLWithString:PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)];
//    [self.acctountTopView.avatarView sd_setImageWithURL:imageURL placeholderImage:IMAGE_NAMED(@"userCenterDefaultAvatar")];
    self.acctountTopView.avatarView.image = accountViewModel.avatarImage;
    self.acctountTopView.nicknameLabel.text = [PSSessionManager sharedInstance].session.families.name;
    CGFloat topHeight = SCREEN_WIDTH * self.acctountTopView.topRate + SCREEN_WIDTH * self.acctountTopView.infoRate - 40;
    [self.view addSubview:self.acctountTopView];
    @weakify(self);
    [self.acctountTopView.avatarView bk_whenTapped:^{
        @strongify(self);
        [self clickAvatarView];
    }];

    [self.acctountTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(topHeight);
    }];
//    UINavigationBar *navBar = self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"userCenterAccountBack"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
//        make.size.mas_equalTo(CGSizeMake(44, CGRectGetHeight(navBar.frame)));
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(StatusHeight);
    }];
    
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    NSString*userCenterAccount=NSLocalizedString(@"userCenterAccount", @"账号信息");
    titleLabel.text = userCenterAccount;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(backButton.mas_top);
        make.bottom.mas_equalTo(backButton.mas_bottom);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(150);
    }];
    
    self.infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.infoTableView.dataSource = self;
    self.infoTableView.delegate = self;
    self.infoTableView.separatorInset = UIEdgeInsetsMake(0, 25, 0, 15);
    [self.infoTableView registerClass:[PSAccountInfoCell class] forCellReuseIdentifier:@"cellIdentifier"];
    self.infoTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.infoTableView];
    //  make.left.bottom.right.mas_equalTo(0);
    [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(self.acctountTopView.mas_bottom);
    }];
    
    UIButton*loginOutBtn =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-45, SCREEN_HEIGHT-100, 90, 35)];
    loginOutBtn.titleLabel.numberOfLines=0;
    [loginOutBtn setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    loginOutBtn.titleLabel.font = AppBaseTextFont1;
    [loginOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*loginout=NSLocalizedString(@"loginout", @"退出账号");
    [loginOutBtn setTitle:loginout forState:UIControlStateNormal];
    [self.view addSubview:loginOutBtn];
    [loginOutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
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

- (BOOL)hiddenNavigationBar {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self refreshData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

#pragma mark - 点击头像
- (void)clickAvatarView {
    [SDTrackTool logEvent:ZHXX_PAGE_XGTX];
    LLActionSheetView *alertView = [[LLActionSheetView alloc]initWithTitleArray:@[@"相册选择",@"拍照",@"更换头像"] andShowCancel:YES];
    [alertView setTitleColor:[UIColor grayColor] index:2];
    alertView.ClickIndex = ^(NSInteger index) {
        if (index == 1){
            [self openAlbum];
            NSLog(@"相册选择");
        }else if (index == 2){
            [self openCamera];
            NSLog(@"拍照");
        }
    };
    [alertView show];
}

-(void)openAlbum {
    @weakify(self);
    [PSAuthorizationTool checkAndRedirectPhotoAuthorizationWithBlock:^(BOOL result) {
        PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
            @strongify(self)
            [self handlePickerImage:cropImage];
        }];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
    }];
}

-(void)openCamera {
    @weakify(self);
    [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
        PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
            @strongify(self)
            [self handlePickerImage:cropImage];
            
        }];
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.delegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
    }];
}

- (void)handlePickerImage:(UIImage *)image {
    PSAccountViewModel *accountViewModel =[PSAccountViewModel new];
    accountViewModel.avatarImage = image;
    [accountViewModel uploadUserAvatarImageCompleted:^(BOOL successful, NSString *tips) {
        if (successful) {
            self.acctountTopView.avatarView.image = image;
            KPostNotification(KNotificationUserAvaterChangeScuess, nil);
            [PSTipsView showTips:@"头像修改成功"];
        } else {
            [PSTipsView showTips:@"头像修改失败"];
        }
    }];
}

- (void)refreshData {
     PSAccountViewModel *accountViewModel =(PSAccountViewModel *)self.viewModel;
     [[PSLoadingView sharedInstance]show];
     [accountViewModel requestAccountBasicinfoCompleted:^(PSResponse *response) {
         dispatch_async(dispatch_get_main_queue(), ^{
              [self.infoTableView  reloadData];
              [[PSLoadingView sharedInstance] dismiss];
         });
    } failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
            
        });
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSAccountViewModel *accountViewModel = (PSAccountViewModel *)self.viewModel;
    return accountViewModel.infoItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PSAccountInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.font = AppBaseTextFont2;
    cell.textLabel.textColor = AppBaseTextColor1;
    cell.detailTextLabel.font = AppBaseTextFont2;
    cell.detailTextLabel.textColor = AppBaseTextColor1;
    PSAccountViewModel *accountViewModel =(PSAccountViewModel *)self.viewModel;
    PSAccountInfoItem *infoItem = accountViewModel.infoItems[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:infoItem.itemIconName];
    cell.textLabel.text = infoItem.itemName;
    cell.detailTextLabel.text = [infoItem.infoText isKindOfClass:[NSNull class]]?@"":infoItem.infoText;
    cell.detailTextLabel.numberOfLines=0;
    if (0==indexPath.row) {
        cell.accessoryType = UITableViewCellSeparatorStyleNone;
    }else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
 
    return cell;
}




#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (1==indexPath.row) {
        [SDTrackTool logEvent:ZHXX_PAGE_LXDH];
        PSchangPhoneViewController*changPhoneViewController=[[PSchangPhoneViewController alloc]initWithViewModel:[[PSEcomRegisterViewmodel alloc]init]];
        [self.navigationController pushViewController:changPhoneViewController animated:YES];
    }
   else if (2==indexPath.row) {
       [SDTrackTool logEvent:ZHXX_PAGE_JTZZ];
        PSAccountAddressViewController *addressViewController = [[PSAccountAddressViewController alloc] initWithViewModel:[PSAccountEditAddressViewModel new]];
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
    else if (3==indexPath.row){
        [SDTrackTool logEvent:ZHXX_PAGE_YZBM];
        PSAccountEmailViewController *emailViewController = [[PSAccountEmailViewController alloc] initWithViewModel:[PSAccountEditEmailViewModel new]];
        [self.navigationController pushViewController:emailViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
