//
//  PSPersonalViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPersonalViewController.h"
#import "PSRoundRectTextField.h"
#import "PSRegisterViewModel.h"
#import "PSImagePickerController.h"
#import "PSAuthorizationTool.h"

@interface PSPersonalViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) PSRoundRectTextField *phoneTextField;
@property (nonatomic, strong) UIButton *cameraButton;

@end

@implementation PSPersonalViewController

- (IBAction)cameraAction:(id)sender {
    
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
                [self handlePickerImage:cropImage];
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
                [self handlePickerImage:cropImage];
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

- (void)handlePickerImage:(UIImage *)image {
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    registerViewModel.avatarImage = image;
    @weakify(self)
    [[PSLoadingView sharedInstance] show];
    [registerViewModel uploadAvatarCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            [self.cameraButton setImage:image forState:UIControlStateNormal];
        }else{
            [PSTipsView showTips:NSLocalizedString(@"Avatar upload failed", @"头像上传失败")];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}

- (void)renderContents {
    CGFloat cameraHeight = 57;
    CGFloat horPadding = 40;
    CGFloat verPadding = 25;
    CGFloat vHeight = 44;
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cameraButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setImage:[UIImage imageNamed:@"sessionCameraIcon"] forState:UIControlStateNormal];
    self.cameraButton.layer.cornerRadius = cameraHeight / 2;
    self.cameraButton.layer.masksToBounds = YES;
    [self.view addSubview:self.cameraButton];
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(cameraHeight, cameraHeight));
    }];
    self.phoneTextField = [[PSRoundRectTextField alloc] init];
    self.phoneTextField.font = AppBaseTextFont2;
    self.phoneTextField.placeholder = @"手机号码";
    self.phoneTextField.textColor = AppBaseTextColor1;
    [self.view addSubview:self.phoneTextField];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horPadding);
        make.right.mas_equalTo(-horPadding);
        make.height.mas_equalTo(vHeight);
        make.top.mas_equalTo(self.cameraButton.mas_bottom).offset(verPadding);
    }];
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    [self.phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        registerViewModel.phoneNumber = textField.text;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

#pragma mark -
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
