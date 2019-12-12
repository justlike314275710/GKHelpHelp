//
//  PSRelationViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/31.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRelationViewController.h"
#import "PSImagePickerController.h"
#import "PSAuthorizationTool.h"
#import "PSRegisterViewModel.h"
@interface PSRelationViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIButton *relationButton;
@end

@implementation PSRelationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    // Do any additional setup after loading the view.
}
- (void)renderContents {
   // CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(10);
    CGSize buttonSize = CGSizeMake(RELATIVE_HEIGHT_VALUE(193), RELATIVE_HEIGHT_VALUE(134));
    CGFloat labelHeight = 15;
   // UIFont *labelFont = AppBaseTextFont1;
    UIColor *labelColor = AppBaseTextColor1;
    
    self.relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.relationButton addTarget:self action:@selector(relationCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.relationButton setBackgroundImage:[UIImage imageNamed:@"sessionRelationBackgroud"] forState:UIControlStateNormal];
    [self.relationButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [self.view addSubview:self.relationButton];
    [self.relationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(buttonSize);
    }];
    
    UIButton*OptionalButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:OptionalButton];
    [OptionalButton setBackgroundImage:[UIImage imageNamed:@"OptionalBg"] forState:UIControlStateNormal];
    [OptionalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.relationButton.mas_top);
        make.right.mas_equalTo(self.relationButton.mas_right);
        make.size.mas_equalTo(CGSizeMake(40, 32));
    }];

    
    
    UILabel *frontLabel = [UILabel new];
    frontLabel.font = AppBaseTextFont2;
    frontLabel.textColor = labelColor;
    frontLabel.textAlignment = NSTextAlignmentCenter;
    frontLabel.text = @"点击上传家属关系图(可选)";
    [self.view addSubview:frontLabel];
    [frontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.relationButton.mas_left);
        make.right.mas_equalTo(self.relationButton.mas_right);
        make.top.mas_equalTo(self.relationButton.mas_bottom).offset(5);
        make.height.mas_equalTo(labelHeight);
    }];
    
    
    UILabel *nextLabel = [UILabel new];
    nextLabel.font = AppBaseTextFont2;
    nextLabel.textColor = [UIColor redColor];;
    nextLabel.textAlignment = NSTextAlignmentCenter;
    nextLabel.text = @"(非必填项,可继续下一步)";
    [self.view addSubview:nextLabel];
    [nextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.relationButton.mas_left);
        make.right.mas_equalTo(self.relationButton.mas_right);
        make.top.mas_equalTo(frontLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(labelHeight);
    }];
    
}

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
                [self handlePickerImage:cropImage];
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
                [self handlePickerImage:cropImage];
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

- (void)handlePickerImage:(UIImage *)image {
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    registerViewModel.relationImage = image;
    @weakify(self)
    [[PSLoadingView sharedInstance] show];
    [registerViewModel uploadRelationCompleted:^(PSResponse *response) {
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
