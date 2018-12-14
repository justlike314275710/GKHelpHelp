//
//  VIIDCardViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIIDCardViewController.h"
#import "PSImagePickerController.h"
#import "VIRegisterViewModel.h"
#import <AipOcrSdk/AipOcrSdk.h>
#import "PSThirdPartyConstants.h"
#import "PSAuthorizationTool.h"
@interface VIIDCardViewController ()
@property (nonatomic, strong) UIButton *frontCardButton;
@property (nonatomic, strong) UIButton *backCardButton;
@end

@implementation VIIDCardViewController

- (IBAction)frontCardCameraAction:(id)sender {
 
    NSString *cancer = NSLocalizedString(@"cancel", @"取消");
    NSString *Choose_from_album = NSLocalizedString(@"Choose from album", @"从相册选择");
    NSString *Take_a_photo = NSLocalizedString(@"Take a photo", @"拍照");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancer style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:Take_a_photo style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleFrontPickerImage:cropImage ];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:Choose_from_album style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectPhotoAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleFrontPickerImage:cropImage];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }];
    }];
    [alert addAction:cancelAction];
    [alert addAction:takePhotoAction];
    [alert addAction:albumAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)backCardCameraAction:(id)sender {
    
    NSString *cancer = NSLocalizedString(@"cancel", @"取消");
    NSString *Choose_from_album = NSLocalizedString(@"Choose from album", @"从相册选择");
    NSString *Take_a_photo = NSLocalizedString(@"Take a photo", @"拍照");
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancer style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:Take_a_photo style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleBackPickerImage:cropImage ];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:Choose_from_album style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectPhotoAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleBackPickerImage:cropImage];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }];
    }];
    [alert addAction:cancelAction];
    [alert addAction:takePhotoAction];
    [alert addAction:albumAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)closeCamera:(id)sender {
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleFrontPickerImage:(UIImage *)image  {
    
        VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
        registerViewModel.frontCardImage = image;

        @weakify(self)
        [[PSLoadingView sharedInstance] show];
        [registerViewModel uploadIDCardCompleted:^(PSResponse *response) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            if (response.code == 200) {
                [self.frontCardButton setImage:image forState:UIControlStateNormal];
            }else{
                NSString*card_fail=NSLocalizedString(@"card_fail", @"身份证上传失败");
                [PSTipsView showTips:card_fail];
            }
        } failed:^(NSError *error) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self showNetError];
        } frontOrBack:YES];
    
}

- (void)handleBackPickerImage:(UIImage *)image  {
    [self closeCamera:nil];
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    registerViewModel.backCardImage = image;
    @weakify(self)
    [[PSLoadingView sharedInstance] show];
    [registerViewModel uploadIDCardCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            [self.backCardButton setImage:image forState:UIControlStateNormal];
        }else{
            NSString*card_fail=NSLocalizedString(@"card_fail", @"身份证上传失败");
            [PSTipsView showTips:card_fail];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError];
    } frontOrBack:NO];
}

- (UIBarButtonItem *)cameraBackItem {
    UIButton *lButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect leftFrame = CGRectMake(0, 0, 40, 44);
    [lButton setImage:[self leftItemImage] forState:UIControlStateNormal];
    lButton.frame = leftFrame;
    lButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [lButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    return leftItem;
}

- (void)renderContents {
    CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(10);
    CGSize buttonSize = CGSizeMake(RELATIVE_HEIGHT_VALUE(193), RELATIVE_HEIGHT_VALUE(134));
    CGFloat labelHeight = 15;
    UIFont *labelFont = AppBaseTextFont1;
    UIColor *labelColor = AppBaseTextColor1;
    
    self.frontCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.frontCardButton addTarget:self action:@selector(frontCardCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.frontCardButton setBackgroundImage:[UIImage imageNamed:@"上传正面身份证底"] forState:UIControlStateNormal];
    [self.frontCardButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [self.view addSubview:self.frontCardButton];
    [self.frontCardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(buttonSize);
    }];
    UILabel *frontLabel = [UILabel new];
    frontLabel.font = labelFont;
    frontLabel.textColor = labelColor;
    frontLabel.textAlignment = NSTextAlignmentCenter;
    frontLabel.text = @"Nhấn vào để dẫn đầu";
    [self.view addSubview:frontLabel];
    [frontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.frontCardButton.mas_left);
        make.right.mas_equalTo(self.frontCardButton.mas_right);
        make.top.mas_equalTo(self.frontCardButton.mas_bottom).offset(5);
        make.height.mas_equalTo(labelHeight);
    }];
    
    self.backCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backCardButton addTarget:self action:@selector(backCardCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backCardButton setBackgroundImage:[UIImage imageNamed:@"上传背面身份证底"] forState:UIControlStateNormal];
    [self.backCardButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [self.view addSubview:self.backCardButton];
    [self.backCardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(frontLabel.mas_bottom).offset(verticalPadding);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(buttonSize);
    }];
    UILabel *backLabel = [UILabel new];
    backLabel.font = labelFont;
    backLabel.textColor = labelColor;
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.text = @"Nhấn vào để tải lên biểu tượng quốc gia";
    backLabel.numberOfLines=0;
    [self.view addSubview:backLabel];
    [backLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backCardButton.mas_left);
        make.right.mas_equalTo(self.backCardButton.mas_right);
        make.top.mas_equalTo(self.backCardButton.mas_bottom).offset(5);
        //make.height.mas_equalTo(labelHeight);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[AipOcrService shardService] authWithAK:OCR_API_KEY andSK:OCR_SECRET_KEY];
    [self renderContents];
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
