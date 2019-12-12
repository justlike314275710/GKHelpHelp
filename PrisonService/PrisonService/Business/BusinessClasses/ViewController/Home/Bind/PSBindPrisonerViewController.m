//
//  PSBindPrisonerViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/24.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBindPrisonerViewController.h"
#import "PSBindPrisonView.h"
#import "PSDashiLine.h"
#import "PSPrisonContentViewController.h"
#import "PSPendingViewController.h"
#import "PSAuthorizationTool.h"
#import "PSImagePickerController.h"
@interface PSBindPrisonerViewController ()<PSPendingDataSource,PSPendingDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) PSBindPrisonView *prisonView;
@property (nonatomic , strong) UIScrollView *AppointmentScrollView;
@property (nonatomic ,strong) UIButton *relationButton;
@end

@implementation PSBindPrisonerViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*Bind_prisoners=NSLocalizedString(@"Bind_prisoners", @"绑定服刑人员");
        self.title = Bind_prisoners;
    }
    return self;
}

- (IBAction)bindAction:(id)sender {
    PSBindPrisonerViewModel *bindViewModel = (PSBindPrisonerViewModel *)self.viewModel;
    @weakify(self)
    [bindViewModel checkBindDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            [self bindPrisoner];
        }else{
            [PSTipsView showTips:tips];
        }
    }];
}

- (void)bindPrisoner {
    PSBindPrisonerViewModel *bindViewModel = (PSBindPrisonerViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [bindViewModel bindPrisonerCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            [self bindSuccessful];
            //埋点
            NSDictionary *MobinforDic = @{STATUS:MobSUCCESS};
            [SDTrackTool logEvent:BIND_PRISONER attributes:MobinforDic];
        }else{
            [PSTipsView showTips:response.msg ? response.msg : @"绑定失败"];
            //埋点
            NSDictionary *MobinforDic = @{STATUS:MobFAILURE,ERROR_STR:response.msg ? response.msg : @"绑定失败"};
            [SDTrackTool logEvent:BIND_PRISONER attributes:MobinforDic];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}

- (void)bindSuccessful {

    PSBindPrisonerViewModel *bindViewModel = (PSBindPrisonerViewModel *)self.viewModel;
    PSPendingViewController *pendingViewController = [[PSPendingViewController alloc] init];
    pendingViewController.title = @"绑定服刑人员";
    pendingViewController.dataSource = self;
    pendingViewController.delegate = self;
    [self.navigationController pushViewController:pendingViewController animated:YES];
}

- (void)selectAction {
    [self.view endEditing:YES];
    PSPrisonContentViewController *prisonSelectViewController = [[PSPrisonContentViewController alloc] initWithViewModel:self.viewModel];
    [prisonSelectViewController setSelectedJailCallback:^{
        [self visitorDidSelectedJail];
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:prisonSelectViewController animated:YES completion:nil];
}

- (void)visitorDidSelectedJail {
    PSBindPrisonerViewModel *bindViewModel = (PSBindPrisonerViewModel *)self.viewModel;
    self.prisonView.proviceLabel.text = bindViewModel.selectedProvince.name;
    self.prisonView.cityLabel.text = bindViewModel.selectedCity.name;
    self.prisonView.prisonLabel.text = bindViewModel.selectedJail.title;
}



- (void)renderContents {
    
    _AppointmentScrollView=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    _AppointmentScrollView.delegate=self;
    _AppointmentScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*1.4);
    _AppointmentScrollView.scrollEnabled=YES;
    _AppointmentScrollView.userInteractionEnabled=YES;
    _AppointmentScrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_AppointmentScrollView];
    
    
    CGFloat sidePadding = 15;
    CGFloat vHeight = 88;
    CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(25);
    CGFloat hWidth=SCREEN_WIDTH-2*sidePadding;
    UIFont  *textFont = FontOfSize(12);
    UIColor *titleColor = UIColorFromHexadecimalRGB(0x7d8da2);
    UIColor *textColor = AppBaseTextColor1;
    CGFloat  BUTTON_SCREEN_WIDTH=RELATIVE_HEIGHT_VALUE(193);
    CGFloat  BUTTON_SCREEN_HEIGHT=RELATIVE_HEIGHT_VALUE(134);
    CGFloat  CenterX=CGRectGetMidX(_AppointmentScrollView.frame)-BUTTON_SCREEN_HEIGHT/2-verticalPadding;
    CGSize buttonSize = CGSizeMake(RELATIVE_HEIGHT_VALUE(193), RELATIVE_HEIGHT_VALUE(134));
    
    UILabel *titleOneLabel = [UILabel new];
    titleOneLabel.font = textFont;
    titleOneLabel.textColor = titleColor;
    NSString*Prisoner_number=NSLocalizedString(@"Prisoner_number", @"囚号&关系");
    titleOneLabel.text = Prisoner_number;
    [_AppointmentScrollView addSubview:titleOneLabel];
    titleOneLabel.frame=CGRectMake(sidePadding, verticalPadding, hWidth, 13);

    
    UIView *topBgView = [UIView new];
    topBgView.layer.borderWidth = 1.0;
    topBgView.layer.borderColor = AppBaseLineColor.CGColor;
    topBgView.layer.cornerRadius = 8.0;
    [_AppointmentScrollView addSubview:topBgView];
    topBgView.frame=CGRectMake(sidePadding, CGRectGetMaxY(titleOneLabel.frame)+verticalPadding, hWidth, vHeight);
    

    
    PSDashiLine *line = [PSDashiLine new];
    [topBgView addSubview:line];
    line.frame=CGRectMake(0, 44,hWidth ,1);

    
    PSBindPrisonerViewModel *bindViewModel = (PSBindPrisonerViewModel *)self.viewModel;
    UITextField *prisonerTextField = [[UITextField alloc] init];
    prisonerTextField.font = textFont;
    NSString*enter_PrisonerNumber=NSLocalizedString(@"enter_PrisonerNumber", @"请输入囚号");
    prisonerTextField.placeholder = enter_PrisonerNumber;
    prisonerTextField.textColor = textColor;
    [topBgView addSubview:prisonerTextField];
    prisonerTextField.frame=CGRectMake(sidePadding, 0, hWidth, vHeight/2);
    [prisonerTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        bindViewModel.prisonerNumber = textField.text;
    }];

    
    UITextField *relationTextField = [[UITextField alloc] init];
    relationTextField.font = textFont;
    NSString*enter_Relationship=NSLocalizedString(@"enter_Relationship", @"请输入与服刑人员关系");
    relationTextField.placeholder = enter_Relationship;
    relationTextField.textColor = textColor;
    [topBgView addSubview:relationTextField];
    relationTextField.frame=CGRectMake(sidePadding, CGRectGetMaxY(prisonerTextField.frame), hWidth, vHeight/2);
    [relationTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        bindViewModel.relationShip = textField.text;
    }];

    self.prisonView = [PSBindPrisonView new];
    @weakify(self)
    [self.prisonView.proviceButton bk_whenTapped:^{
        @strongify(self)
        [self selectAction];
    }];
    [self.prisonView.cityButton bk_whenTapped:^{
        @strongify(self)
        [self selectAction];
    }];
    [self.prisonView.prisonButton bk_whenTapped:^{
        @strongify(self)
        [self selectAction];
    }];
    [_AppointmentScrollView addSubview:self.prisonView];
    self.prisonView.frame=CGRectMake(sidePadding, CGRectGetMaxY(topBgView.frame)+verticalPadding, hWidth, 200);
    
    
    UILabel *titleThreeLabel = [UILabel new];
    titleThreeLabel.frame=CGRectMake(verticalPadding, CGRectGetMaxY(self.prisonView.frame)+sidePadding, SCREEN_WIDTH-2*verticalPadding, 13);
    titleThreeLabel.font = textFont;
    titleThreeLabel.textColor = titleColor;
    //VI_relation
    NSString*VI_relation=NSLocalizedString(@"VI_relation", @"上传关系证明");
    titleThreeLabel.text = VI_relation;
    [_AppointmentScrollView addSubview:titleThreeLabel];
    
    self.relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.relationButton.frame=CGRectMake(CenterX, CGRectGetMaxY(titleThreeLabel.frame)+sidePadding, BUTTON_SCREEN_WIDTH, BUTTON_SCREEN_HEIGHT);
    [self.relationButton addTarget:self action:@selector(relationCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.relationButton setBackgroundImage:[UIImage imageNamed:@"vi_UploadingRelationshipBg"] forState:UIControlStateNormal];
    [self.relationButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [_AppointmentScrollView addSubview:self.relationButton];
    
    UIButton*OptionalButton=[UIButton buttonWithType:UIButtonTypeCustom];
    OptionalButton.frame=CGRectMake(CGRectGetMaxX(self.relationButton.frame)-40, CGRectGetMinY(self.relationButton.frame), 40, 32);
    [_AppointmentScrollView addSubview:OptionalButton];
    NSString*OptionalBg=NSLocalizedString(@"OptionalBg", nil);
    [OptionalButton setBackgroundImage:[UIImage imageNamed:OptionalBg] forState:UIControlStateNormal];
    [OptionalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.relationButton.mas_top);
        make.right.mas_equalTo(self.relationButton.mas_right);
        make.size.mas_equalTo(CGSizeMake(40, 32));
    }];
    
    UILabel *relationButtonLabel = [UILabel new];
    relationButtonLabel.frame=CGRectMake(CenterX, CGRectGetMaxY(_relationButton.frame)+5, BUTTON_SCREEN_WIDTH, 40);
    relationButtonLabel.font = AppBaseTextFont2;
    relationButtonLabel.textColor = AppBaseTextColor1;
    relationButtonLabel.textAlignment = NSTextAlignmentCenter;
    NSString*relation_title=NSLocalizedString(@"relation_title", @"点击上传关系证明图");
    relationButtonLabel.text = relation_title;
    relationButtonLabel.numberOfLines=0;
    //relationButtonLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [_AppointmentScrollView addSubview:relationButtonLabel];
    
//    UILabel *nextLabel = [UILabel new];
//    nextLabel.frame=CGRectMake(CenterX, CGRectGetMaxY(relationButtonLabel.frame)+5, BUTTON_SCREEN_WIDTH, 40);
//    nextLabel.font = AppBaseTextFont2;
//    nextLabel.textColor = [UIColor redColor];;
//    nextLabel.textAlignment = NSTextAlignmentCenter;
//    nextLabel.text = @"(Dân hạng, nhưng tiếp tục bước tiếp theo.)";
//    nextLabel.numberOfLines=0;
//    [_AppointmentScrollView addSubview:nextLabel];
    
    
    UIButton *bindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bindButton.frame=CGRectMake(SCREEN_WIDTH/2-45, CGRectGetMaxY(relationButtonLabel.frame)+verticalPadding+sidePadding, 90, 35);

    bindButton.titleLabel.font = AppBaseTextFont1;
    [bindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*binding=NSLocalizedString(@"binding", @"立即绑定");
    [bindButton setTitle:binding forState:UIControlStateNormal];
    [bindButton addTarget:self action:@selector(bindAction:) forControlEvents:UIControlEventTouchUpInside];
    [bindButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    [_AppointmentScrollView addSubview:bindButton];

    
}

#pragma mark -- 家属关系图上传
- (IBAction)relationCameraAction:(id)sender {
    
    NSString *cancel = NSLocalizedString(@"cancel", @"取消");
    NSString *Choose_from_album = NSLocalizedString(@"Choose from album", @"从相册选择");
    NSString *Take_a_photo = NSLocalizedString(@"Take a photo", @"拍照");
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:Take_a_photo style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
               [self handleRelationPickerImage:cropImage];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        } setBlock:nil isShow:YES];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:Choose_from_album style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectPhotoAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleRelationPickerImage:cropImage];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        } setBlock:nil isShow:YES];
    }];
    [alert addAction:cancelAction];
    [alert addAction:takePhotoAction];
    [alert addAction:albumAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)handleRelationPickerImage:(UIImage *)image {
    PSBindPrisonerViewModel *bindViewModel = (PSBindPrisonerViewModel *)self.viewModel;
    bindViewModel.relationImage = image;
    @weakify(self)
    [[PSLoadingView sharedInstance] show];
    [bindViewModel uploadRelationCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            [self.relationButton setImage:image forState:UIControlStateNormal];
        }else{
            [PSTipsView showTips:@"家属关系图上传失败"];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

#pragma mark - PSPendingDataSource,PSPendingDelegate
- (NSString *)titleForPendingView {
    NSString*meet_PENDING=NSLocalizedString(@"meet_PENDING", @"审核中");
    return meet_PENDING;
}

- (NSString *)subTitleForPendingView {
    NSString*Please_wait_review=NSLocalizedString(@"Please_wait_review", @"请等待监狱审核,通过后即可登入系统");
    NSString*Please_wait = NSLocalizedString(@"The binding application you submitted is under review, please be patient~", @"您提交的绑定申请正在审核中，请耐心等待～");
    return Please_wait;
}

//- (NSString *)titleForOperationButton {
//    NSString*goHome=NSLocalizedString(@"goHome", @"回到主页");
//    return goHome;
//}
//
//- (void)pendingViewOperation {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

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
