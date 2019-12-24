//
//  VIPhoneMessageViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIPhoneMessageViewController.h"
#import "PSRoundRectTextField.h"
#import "VIRegisterViewModel.h"
#import <YYText/YYText.h>
#import "PSProtocolViewController.h"
#import "PSContentManager.h"
#import "PSCountdownManager.h"
#import "PSAuthorizationTool.h"
#import "PSImagePickerController.h"
#import "PSAlertView.h"
#import "HRFaceManager.h"

@interface VIPhoneMessageViewController ()<PSCountdownObserver,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, strong) YYLabel *protocolLabel;
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, strong) PSRoundRectTextField *phoneTextField;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic , strong) UIButton*sexbutton ;
@end

@implementation VIPhoneMessageViewController

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
        } setBlock:nil isShow:YES];
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
    NSString *faceError = NSLocalizedString(@"faceError", @"您上传的头像未能通过人脸识别,请重新上传");
    [[HRFaceManager sharedInstance] registHRSDK:^(PSHRFaceBackResultType result) {
        if (result==PSFaceBackSDKRegistFail) {
            [PSTipsView showTips:@"人脸识别SDK注册失败"];
        } else if(result==PSFaceBackSDKInitFail) {
            [PSTipsView showTips:@"人脸识别SDK初始化失败"];
        } else if (result==PSFaceBackSDKInitSuccess) {
            //检测图片是否能用
            [[HRFaceManager sharedInstance] hrsdkCheckFace:faceImage sdkblock:^(PSHRFaceBackResultType result) {
                if (result==PSFaceBackSDKcheckImageNoFace) { //没有识别到人脸
                    [PSTipsView showTips:faceError dismissAfterDelay:0.5];
                } else if(result==PSFaceBackSDKcheckImageFail) { //提取人脸信息失败
                    [PSTipsView showTips:faceError dismissAfterDelay:0.5];
                }
            } checkBlock:^(LPASF_FaceFeature  _Nonnull faceFacture) {
                if (faceFacture) { //通过虹软检测
                    [self handlePickerImage:faceImage];
                } else { //没有通过虹软检测
                    [PSTipsView showTips:faceError dismissAfterDelay:0.5];
                }
            }];
        }
    }];
    /*
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
            NSString*faceError=NSLocalizedString(@"faceError", @"您上传的头像未能通过人脸识别,请重新上传");
            [PSTipsView showTips:faceError];
        });
        
    }
     */
}

- (void)handlePickerImage:(UIImage *)image {
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
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




//- (IBAction)codeAction:(id)sender {
//    @weakify(self)
//    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
//    [registerViewModel requestCodeCompleted:^(PSResponse *response) {
//        @strongify(self)
//        if (response.code == 200) {
//            [PSTipsView showTips:@"已发送"];
//            self.seconds = 60;
//        }else{
//            [PSTipsView showTips:response.msg ? response.msg : @"获取验证码失败"];
//        }
//    } failed:^(NSError *error) {
//        @strongify(self)
//        [self showNetError];
//    }];
//}

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

- (void)openProtocol {
    
    PSProtocolViewController *protocolViewController = [[PSProtocolViewController alloc] init];
    // [[PSContentManager sharedInstance].currentNavigationController pushViewController:protocolViewController animated:YES];
    //  [self.navigationController pushViewController:protocolViewController animated:YES];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:protocolViewController animated:YES completion:nil];
    
}



- (void)updateProtocolStatus {
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    registerViewModel.agreeProtocol = !registerViewModel.agreeProtocol;
    [self updateProtocolText];
}

- (void)renderContents {
    CGFloat sidePadding = 40;
    CGFloat vHeight = 44;
    CGFloat cameraHeight = 57;
    CGFloat horPadding = 40;
    CGFloat verPadding = 15;
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
    
    
    PSRoundRectTextField *nameTextField = [[PSRoundRectTextField alloc] init];
    nameTextField.font = textFont;
    nameTextField.placeholder = @"Xin vui lòng nhập tên";
    nameTextField.textColor = textColor;
    [self.view addSubview:nameTextField];
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(vHeight);
        make.top.mas_equalTo(self.cameraButton.mas_bottom).offset(verPadding);
    }];
      VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    [nameTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        registerViewModel.name = textField.text;
    }];

    PSRoundRectTextField *uuidTextField = [[PSRoundRectTextField alloc] init];
    uuidTextField.font = textFont;
    uuidTextField.placeholder = @"Số thẻ ID";
    uuidTextField.textColor = textColor;
    [self.view addSubview:uuidTextField];
    [uuidTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(vHeight);
        // make.top.mas_equalTo(0);
        make.top.mas_equalTo(nameTextField.mas_bottom).offset(verPadding);
    }];

    [uuidTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        registerViewModel.cardID = textField.text;
    }];
    

    
//    PSRoundRectTextField *sexTextField = [[PSRoundRectTextField alloc] init];
//    sexTextField.font = textFont;
//    sexTextField.placeholder = @"Vui lòng nhập giới tính";
//    sexTextField.textColor = textColor;
//    [self.view addSubview:sexTextField];
//    [sexTextField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(sidePadding);
//        make.right.mas_equalTo(-sidePadding);
//        make.height.mas_equalTo(vHeight);
//        // make.top.mas_equalTo(0);
//        make.top.mas_equalTo(uuidTextField.mas_bottom).offset(verPadding);
//    }];
//    [sexTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//        registerViewModel.gender = textField.text;
//    }];
    
    _sexbutton = [[UIButton alloc] init];
    _sexbutton.titleLabel.font = textFont;
    [_sexbutton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    [_sexbutton setBackgroundColor:[UIColor clearColor]];
    [_sexbutton.layer setBorderWidth:1.0];
    _sexbutton.layer.borderColor=AppBaseLineColor.CGColor;
    [_sexbutton setTitle:@"       Vui lòng nhập giới tính" forState:UIControlStateNormal];
    _sexbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:_sexbutton];
    [_sexbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(vHeight);
        // make.top.mas_equalTo(0);
        make.top.mas_equalTo(uuidTextField.mas_bottom).offset(verPadding);
    }];
    [_sexbutton.layer setCornerRadius:22 ];

    [_sexbutton addTarget:self action:@selector(alterSexPortrait) forControlEvents:UIControlEventTouchUpInside];
    

//    self.phoneTextField = [[PSRoundRectTextField alloc] init];
//    self.phoneTextField.font = AppBaseTextFont2;
//    self.phoneTextField.placeholder = @"Số điện thoại";
//    self.phoneTextField.textColor = AppBaseTextColor1;
//    [self.view addSubview:self.phoneTextField];
//    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(horPadding);
//        make.right.mas_equalTo(-horPadding);
//        make.height.mas_equalTo(vHeight);
//        //make.top.mas_equalTo(sexTextField.mas_bottom).offset(verPadding);
//        make.top.mas_equalTo(_sexbutton.mas_bottom).offset(verPadding);
//    }];
//
//    [self.phoneTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//        registerViewModel.phoneNumber = textField.text;
//    }];
//
//
//    PSRoundRectTextField *relationTextField = [[PSRoundRectTextField alloc] init];
//    relationTextField.font = textFont;
//    relationTextField.placeholder = @"Mật khẩu";
//    relationTextField.textColor = textColor;
//    [self.view addSubview:relationTextField];
//    [relationTextField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(sidePadding);
//        make.right.mas_equalTo(-sidePadding);
//        make.height.mas_equalTo(vHeight);
//        // make.top.mas_equalTo(0);
//        make.top.mas_equalTo(self.phoneTextField.mas_bottom).offset(verPadding);
//    }];
//    //  PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
//    [relationTextField setBk_didEndEditingBlock:^(UITextField *textField) {
//        registerViewModel.loginPwd = textField.text;
//    }];
    
  


 
//    CGFloat protocolSidePadding = RELATIVE_WIDTH_VALUE(30);
//    self.protocolLabel = [YYLabel new];
//    @weakify(self)
//    [self.protocolLabel setTextTapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//        @strongify(self)
//        NSString *tapString = [text yy_plainTextForRange:range];
//        NSString *protocolString = @"《Sử dụng các thỏa thuận》";
//        if (tapString) {
//            if ([protocolString containsString:tapString]) {
//                [self openProtocol];
//            }else{
//                [self updateProtocolStatus];
//            }
//        }
//        // [self openProtocol];
//    }];
//    [self.view addSubview:self.protocolLabel];
//    self.protocolLabel.numberOfLines=0;
//    [self.protocolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(protocolSidePadding);
//        make.right.mas_equalTo(-protocolSidePadding);
//        make.bottom.mas_equalTo(-20);
//        make.height.mas_equalTo(30);
//    }];
//    [self updateProtocolText];
}
-(void)alterSexPortrait{
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet]; //按钮：男
    [alert addAction:[UIAlertAction actionWithTitle:@"Nam" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        registerViewModel.gender=@"Nam";
         [_sexbutton setTitle:@"       Nam" forState:UIControlStateNormal];
       
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Nữ" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
       registerViewModel.gender=@"Nữ";
        //_sexbutton.titleLabel.text=@"Nữ";
        [_sexbutton setTitle:@"       Nữ" forState:UIControlStateNormal];
        
        
    }]];
    NSString*cancel=NSLocalizedString(@"cancel", @"取消");
   [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
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
