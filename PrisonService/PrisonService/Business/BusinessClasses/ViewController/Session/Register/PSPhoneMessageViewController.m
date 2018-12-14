//
//  PSPhoneMessageViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPhoneMessageViewController.h"
#import "PSRoundRectTextField.h"
#import "PSRegisterViewModel.h"
#import <YYText/YYText.h>
#import "PSProtocolViewController.h"
#import "PSContentManager.h"
#import "PSCountdownManager.h"
#import "PSAuthorizationTool.h"
#import "PSImagePickerController.h"
#import "PSAlertView.h"
@interface PSPhoneMessageViewController ()<PSCountdownObserver,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, strong) YYLabel *protocolLabel;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, strong) PSRoundRectTextField *phoneTextField;
@property (nonatomic, strong) UIButton *cameraButton;
@end

@implementation PSPhoneMessageViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[PSCountdownManager sharedInstance] removeObserver:self];
}


- (IBAction)cameraAction:(id)sender {
    
    
    NSString*determine=NSLocalizedString(@"determine", @"确定");
    NSString*cancel=NSLocalizedString(@"cancel", @"取消");
    NSString*be_careful=NSLocalizedString(@"be_careful", @"注意");
    NSString*upload_head=NSLocalizedString(@"upload_head", @"请上传本人真实.清晰头像!否则注册无法通过!");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:be_careful message:upload_head preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:determine style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self containFace:cropImage];

            }];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }];
    }];
//    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [PSAuthorizationTool checkAndRedirectPhotoAuthorizationWithBlock:^(BOOL result) {
//            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
//                @strongify(self)
//               // [self handlePickerImage:cropImage];
//                [self containFace:cropImage];
//            }];
//            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//            picker.delegate = self;
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
//        }];
//    }];
    [alert addAction:cancelAction];
    [alert addAction:takePhotoAction];
    //[alert addAction:albumAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}


-(void)containFace:(UIImage*)faceImage{
    CIContext * context = [CIContext contextWithOptions:nil];
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    CIImage * image = [CIImage imageWithCGImage:faceImage.CGImage];
    
    NSArray * detectResult = [faceDetector featuresInImage:image];
    
    
    if (detectResult.count>0) {
        //有脸
        [self handlePickerImage:faceImage];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *faceError = NSLocalizedString(@"faceError", @"您上传的头像未能通过人脸识别,请重新上传");
            [PSTipsView showTips:faceError];
        });
        
    }
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
        [self showNetError];
    }];
}




- (IBAction)codeAction:(id)sender {
    @weakify(self)
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    [registerViewModel requestCodeCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            [PSTipsView showTips:@"已发送"];
            self.seconds = 60;
        }else{
            [PSTipsView showTips:response.msg ? response.msg : @"获取验证码失败"];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [self showNetError];
    }];
}

- (void)updateProtocolText {
    NSMutableAttributedString *protocolText = [NSMutableAttributedString new];
    UIFont *textFont = FontOfSize(12);
    [protocolText appendAttributedString:[[NSAttributedString alloc] initWithString:@"我已阅读并同意" attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor2}]];
    [protocolText appendAttributedString:[[NSAttributedString  alloc] initWithString:@"《狱务通软件使用协议》" attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor3}]];
    [protocolText appendAttributedString:[[NSAttributedString  alloc] initWithString:@" " attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:AppBaseTextColor3}]];
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    UIImage *statusImage = registerViewModel.agreeProtocol ? [UIImage imageNamed:@"sessionProtocolSelected"] : [UIImage imageNamed:@"sessionProtocolNormal"];
    [protocolText appendAttributedString:[NSAttributedString yy_attachmentStringWithContent:statusImage contentMode:UIViewContentModeCenter attachmentSize:statusImage.size alignToFont:textFont alignment:YYTextVerticalAlignmentCenter]];
    protocolText.yy_alignment = NSTextAlignmentCenter;
    self.protocolLabel.attributedText = protocolText;
}

- (void)openProtocol {
  
    PSProtocolViewController *protocolViewController = [[PSProtocolViewController alloc] init];
   // [[PSContentManager sharedInstance].currentNavigationController pushViewController:protocolViewController animated:YES];
  //  [self.navigationController pushViewController:protocolViewController animated:YES];
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:protocolViewController animated:YES completion:nil];
    
}



- (void)updateProtocolStatus {
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    registerViewModel.agreeProtocol = !registerViewModel.agreeProtocol;
    [self updateProtocolText];
}

- (void)renderContents {
    CGFloat sidePadding = 40;
    CGFloat vHeight = 44;
    CGFloat cameraHeight = 57;
    CGFloat horPadding = 40;
    CGFloat verPadding = 25;
    UIFont *textFont = AppBaseTextFont2;
    UIColor *textColor = AppBaseTextColor1;
    
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
    
    
    PSRoundRectTextField *relationTextField = [[PSRoundRectTextField alloc] init];
    relationTextField.font = textFont;
    relationTextField.placeholder = @"请输入验证码";
    relationTextField.textColor = textColor;
    [self.view addSubview:relationTextField];
    [relationTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(vHeight);
        // make.top.mas_equalTo(0);
        make.top.mas_equalTo(self.phoneTextField.mas_bottom).offset(verPadding);
    }];
    //  PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    [relationTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        registerViewModel.messageCode = textField.text;
    }];
    
    _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeButton.frame = CGRectMake(0, 0, 95, vHeight);
    [_codeButton addTarget:self action:@selector(codeAction:) forControlEvents:UIControlEventTouchUpInside];
    _codeButton.titleLabel.font = AppBaseTextFont2;
    [_codeButton setTitleColor:AppBaseTextColor3 forState:UIControlStateNormal];
    [_codeButton setTitleColor:AppBaseTextColor2 forState:UIControlStateDisabled];
    [_codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    _codeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    relationTextField.rightView = _codeButton;
    relationTextField.rightViewMode = UITextFieldViewModeAlways;
    
    CGFloat protocolSidePadding = RELATIVE_WIDTH_VALUE(30);
    self.protocolLabel = [YYLabel new];
    @weakify(self)
    [self.protocolLabel setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        @strongify(self)
        NSString *tapString = [text yy_plainTextForRange:range];
        NSString *protocolString = @"《狱务通软件使用协议》";
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
    [self.protocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(protocolSidePadding);
        make.right.mas_equalTo(-protocolSidePadding);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(15);
    }];
    [self updateProtocolText];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

#pragma mark - PSCountdownObserver
- (void)countdown {
    _codeButton.enabled = _seconds == 0;
    if (_seconds > 0) {
        [_codeButton setTitle:[NSString stringWithFormat:@"重发(%ld)",(long)_seconds] forState:UIControlStateDisabled];
        _seconds --;
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
