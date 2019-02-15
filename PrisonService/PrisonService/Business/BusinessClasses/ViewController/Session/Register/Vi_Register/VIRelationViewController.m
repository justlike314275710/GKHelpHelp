//
//  VIRelationViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIRelationViewController.h"
#import "PSImagePickerController.h"
#import "PSAuthorizationTool.h"
#import "PSRegisterViewModel.h"
#import <YYText/YYText.h>
#import "PSProtocolViewController.h"
#import "VIRegisterViewModel.h"
@interface VIRelationViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIButton *relationButton;
@property (nonatomic, strong) YYLabel *protocolLabel;
@end

@implementation VIRelationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    // Do any additional setup after loading the view.
}
- (void)renderContents {
    // CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(10);
    CGSize buttonSize = CGSizeMake(RELATIVE_HEIGHT_VALUE(193), RELATIVE_HEIGHT_VALUE(134));
    CGFloat labelHeight = 40;
    // UIFont *labelFont = AppBaseTextFont1;
    UIColor *labelColor = AppBaseTextColor1;
    
    self.relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.relationButton addTarget:self action:@selector(relationCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.relationButton setBackgroundImage:[UIImage imageNamed:@"vi_UploadingRelationshipBg"] forState:UIControlStateNormal];
    [self.relationButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [self.view addSubview:self.relationButton];
    [self.relationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(buttonSize);
    }];
    
    UIButton*OptionalButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:OptionalButton];
    [OptionalButton setBackgroundImage:[UIImage imageNamed:@"vi_OptionalBg"] forState:UIControlStateNormal];
    [OptionalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.relationButton.mas_top);
        make.right.mas_equalTo(self.relationButton.mas_right);
        make.size.mas_equalTo(CGSizeMake(40, 32));
    }];
    
    
    
    UILabel *frontLabel = [UILabel new];
    frontLabel.font = AppBaseTextFont2;
    frontLabel.textColor = labelColor;
    frontLabel.textAlignment = NSTextAlignmentCenter;
    frontLabel.text = @"Nhấp chuột vào bản đồ gia đình(Có thể chọn)";
    [self.view addSubview:frontLabel];
    frontLabel.numberOfLines=0;
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
    nextLabel.text = @"(Không cần phải nhồi nhét, tiếp tục bước tiếp theo)";
    [self.view addSubview:nextLabel];
    nextLabel.numberOfLines=0;
    [nextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.relationButton.mas_left);
        make.right.mas_equalTo(self.relationButton.mas_right);
        make.top.mas_equalTo(frontLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(labelHeight);
    }];
    
    CGFloat protocolSidePadding = RELATIVE_WIDTH_VALUE(30);
    self.protocolLabel = [YYLabel new];
    @weakify(self)
    [self.protocolLabel setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        @strongify(self)
        NSString *tapString = [text yy_plainTextForRange:range];
        NSString *protocolString = @"《Sử dụng các thỏa thuận》";
        if (tapString) {
            if ([protocolString containsString:tapString]) {
                [self openProtocol];
            }else{
                [self updateProtocolStatus];
            }
        }
        // [self openProtocol];
    }];
    [self.view addSubview:self.protocolLabel];
    self.protocolLabel.numberOfLines=0;
    [self.protocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(protocolSidePadding);
        make.right.mas_equalTo(-protocolSidePadding);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(30);
    }];
    [self updateProtocolText];
    
}
- (void)updateProtocolStatus {
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    registerViewModel.agreeProtocol = !registerViewModel.agreeProtocol;
    [self updateProtocolText];
}

- (void)openProtocol {
    
    PSProtocolViewController *protocolViewController = [[PSProtocolViewController alloc] init];
    // [[PSContentManager sharedInstance].currentNavigationController pushViewController:protocolViewController animated:YES];
    //  [self.navigationController pushViewController:protocolViewController animated:YES];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:protocolViewController animated:YES completion:nil];
    
}

- (void)updateProtocolText {
    NSMutableAttributedString *protocolText = [NSMutableAttributedString new];
    UIFont *textFont = FontOfSize(12);
    [protocolText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Tôi đã đọc và đồng ý" attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor2}]];
    [protocolText appendAttributedString:[[NSAttributedString  alloc] initWithString:@"《Thỏa thuận sử dụng phần mềm dịch vụ trại giam》" attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor3}]];
    [protocolText appendAttributedString:[[NSAttributedString  alloc] initWithString:@" " attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor3}]];
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    UIImage *statusImage = registerViewModel.agreeProtocol ? [UIImage imageNamed:@"sessionProtocolSelected"] : [UIImage imageNamed:@"sessionProtocolNormal"];
    [protocolText appendAttributedString:[NSAttributedString yy_attachmentStringWithContent:statusImage contentMode:UIViewContentModeCenter attachmentSize:statusImage.size alignToFont:textFont alignment:YYTextVerticalAlignmentCenter]];
    protocolText.yy_alignment = NSTextAlignmentCenter;
    self.protocolLabel.attributedText = protocolText;
}


- (IBAction)relationCameraAction:(id)sender {
    
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
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
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
