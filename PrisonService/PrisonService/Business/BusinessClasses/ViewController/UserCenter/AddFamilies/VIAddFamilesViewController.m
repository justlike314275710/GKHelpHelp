//
//  PSAddFamiliesViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/9/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIAddFamilesViewController.h"
#import "PSRoundRectTextField.h"
#import "PSRegisterViewModel.h"
#import <AipOcrSdk/AipOcrSdk.h>
#import "PSThirdPartyConstants.h"
#import "PSAuthorizationTool.h"
#import "PSImagePickerController.h"
#import "VIRegisterViewModel.h"
#import "PSHomeViewModel.h"
#import "PSSessionManager.h"
#import "HRFaceManager.h"
@interface VIAddFamilesViewController ()<UIScrollViewDelegate>
@property (nonatomic , strong) UIScrollView *addScrollView;
@property (nonatomic, strong) UIButton *frontCardButton;
@property (nonatomic, strong) UIButton *backCardButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic ,strong) UIButton *relationButton;
@property (nonatomic , strong) UIButton *sexbutton;
@end

@implementation VIAddFamilesViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"Tăng gia đình.";
    }
    return self;
}

#pragma mark -- 头像上传
- (IBAction)cameraAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Chú ý." message:@"Xin hãy tải lên trực tiếp, thật rõ ràng là Avatar!Nếu không đăng ký không thể vượt qua!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Hủy bỏ" style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Chắc chắn." style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self containFace:cropImage];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.delegate =self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        } setBlock:nil isShow:YES];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:takePhotoAction];
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
            [PSTipsView showTips:@"Ông không thể qua mặt người tải lên là Avatar được công nhận, làm ơn để tải lên."];
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
            [PSTipsView showTips:@"Avatar tải lên thành công."];
            [self.cameraButton setImage:image forState:UIControlStateNormal];
        }else{
            [PSTipsView showTips:@"Avatar táº£i vá»"];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}
#pragma mark -- 身份证上传
- (IBAction)frontCardCameraAction:(id)sender {
    
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
                [self handleFrontPickerImage:cropImage ];
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
                [self handleFrontPickerImage:cropImage];
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

- (IBAction)backCardCameraAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Hủy bỏ" style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Chụp ảnh." style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleBackPickerImage:cropImage ];
            }];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        } setBlock:nil isShow:YES];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Lựa chọn từ tập ảnh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PSAuthorizationTool checkAndRedirectPhotoAuthorizationWithBlock:^(BOOL result) {
            PSImagePickerController *picker = [[PSImagePickerController alloc] initWithCropHeaderImageCallback:^(UIImage *cropImage) {
                @strongify(self)
                [self handleBackPickerImage:cropImage];
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
        [self showNetError:error];
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
        [self showNetError:error];
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

#pragma mark -- 家属关系图上传
- (IBAction)relationCameraAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Hủy bỏ" style:UIAlertActionStyleCancel handler:nil];
    @weakify(self)
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Chụp ảnh." style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
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
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Lựa chọn từ tập ảnh" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
            [PSTipsView showTips:@"Mối quan hệ gia đình bản tải lên thất bại."];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}

#pragma mark -- 添加附属家属
-(void)checkFamilesDataAction{
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    @weakify(self)
    [registerViewModel checkAddFamilesDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            [self addFamilesAction];
        } else {
            [PSTipsView showTips:tips];
        }
    }];
}
-(void)addFamilesAction{
    [[PSLoadingView sharedInstance]show];
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    registerViewModel.type=@"1";
    [registerViewModel addFamilesCompleted :^(PSResponse *response) {
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            [PSTipsView showTips:@"Gia đình gửi thêm thành công."];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [PSTipsView showTips:@"Thêm vào các gia đình chấp nhận thất bại."];
        }
        
    } failed:^(NSError *error) {
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AipOcrService shardService] authWithAK:OCR_API_KEY andSK:OCR_SECRET_KEY];
    [self renderContents];
    // Do any additional setup after loading the view.
}


- (void)renderContents {
    _addScrollView=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    _addScrollView.delegate=self;
    _addScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*1.7);
    _addScrollView.scrollEnabled=YES;
    _addScrollView.userInteractionEnabled=YES;
    _addScrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_addScrollView];
    
    CGFloat sidePadding = 15;
    CGFloat vHeight = 88;
    CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(25);
    UIFont  *textFont = FontOfSize(12);
    UIColor *titleColor = UIColorFromHexadecimalRGB(0x7d8da2);
    UIColor *textColor = AppBaseTextColor1;
    CGFloat cameraHeight = 57;
    CGFloat  BUTTON_SCREEN_WIDTH=RELATIVE_HEIGHT_VALUE(193);
    CGFloat  BUTTON_SCREEN_HEIGHT=RELATIVE_HEIGHT_VALUE(134);
    CGFloat  CenterX=CGRectGetMidX(self.addScrollView.frame)-BUTTON_SCREEN_HEIGHT/2-verticalPadding;
    
    
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    NSString*name=prisonerDetail ? prisonerDetail.name : @"";
    
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    UILabel *titleOneLabel = [UILabel new];
    titleOneLabel.frame=CGRectMake(verticalPadding, sidePadding, SCREEN_WIDTH-2*verticalPadding, 13);
    titleOneLabel.font = textFont;
    titleOneLabel.textColor = titleColor;
    titleOneLabel.text = [NSString stringWithFormat: @"■ Số tù nhân thông tin(%@)",name];
    [_addScrollView addSubview:titleOneLabel];
    
    
    
    
    
    UITextField *relationTextField = [[PSRoundRectTextField alloc] init];
    relationTextField.frame=CGRectMake(2*verticalPadding, CGRectGetMaxY(titleOneLabel.frame)+sidePadding, SCREEN_WIDTH-4*verticalPadding, vHeight/2);
    relationTextField.font = textFont;
    NSString*enter_Relationship=NSLocalizedString(@"enter_Relationship", @"请输入与服刑人员关系");
    relationTextField.placeholder = enter_Relationship;
    relationTextField.textColor = textColor;
    relationTextField.textColor = AppBaseTextColor1;
    [_addScrollView addSubview:relationTextField];
    
    [relationTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        
        registerViewModel.relationShip=textField.text;
    }];
    

    
    
    
    
    UILabel *titleTwoLabel = [UILabel new];
    titleTwoLabel.frame=CGRectMake(verticalPadding, CGRectGetMaxY(relationTextField.frame)+sidePadding, SCREEN_WIDTH-2*verticalPadding, 13);
    titleTwoLabel.font = textFont;
    titleTwoLabel.textColor = titleColor;
    titleTwoLabel.text = @"■ Thông tin về gia đình.";
    [_addScrollView addSubview:titleTwoLabel];
    

    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton.frame=CGRectMake(CGRectGetMidX(_addScrollView.frame)-verticalPadding, CGRectGetMaxY(titleTwoLabel.frame)+sidePadding, cameraHeight, cameraHeight);
    [self.cameraButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setImage:[UIImage imageNamed:@"sessionCameraIcon"] forState:UIControlStateNormal];
    self.cameraButton.layer.cornerRadius = cameraHeight / 2;
    self.cameraButton.layer.masksToBounds = YES;
    [_addScrollView addSubview:self.cameraButton];
    
    
    
    
    
    UITextField *IdCardField = [[PSRoundRectTextField alloc] init];
    IdCardField.frame=CGRectMake(2*verticalPadding, CGRectGetMaxY(self.cameraButton.frame)+sidePadding, SCREEN_WIDTH-4*verticalPadding, vHeight/2);
    IdCardField.font = textFont;
    IdCardField.placeholder = @"Số thẻ ID";
    IdCardField.textColor = textColor;
    IdCardField.textColor = AppBaseTextColor1;
    [_addScrollView addSubview:IdCardField];
    
    [IdCardField setBk_didEndEditingBlock:^(UITextField *textField) {
        
        registerViewModel.cardID=textField.text;
    }];
    
    
    _sexbutton = [[UIButton alloc] init];
    _sexbutton.titleLabel.font = textFont;
    _sexbutton.frame=CGRectMake(2*verticalPadding, CGRectGetMaxY(IdCardField.frame)+sidePadding, SCREEN_WIDTH-4*verticalPadding, vHeight/2);
    [_sexbutton setTitleColor:AppBaseTextColor2 forState:UIControlStateNormal];
    [_sexbutton setBackgroundColor:[UIColor clearColor]];
    [_sexbutton.layer setBorderWidth:1.0];
    _sexbutton.layer.borderColor=AppBaseLineColor.CGColor;
    [_sexbutton setTitle:@"       Vui lòng nhập giới tính" forState:UIControlStateNormal];
    _sexbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_addScrollView addSubview:_sexbutton];
    [_sexbutton.layer setCornerRadius:22 ];
    [_sexbutton addTarget:self action:@selector(alterSexPortrait) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *nameTextField = [[PSRoundRectTextField alloc] init];
    nameTextField.frame=CGRectMake(2*verticalPadding, CGRectGetMaxY(_sexbutton.frame)+sidePadding, SCREEN_WIDTH-4*verticalPadding, vHeight/2);
    nameTextField.font = textFont;
    nameTextField.placeholder = @"Xin vui lòng nhập tên";
    nameTextField.textColor = textColor;
    nameTextField.textColor = AppBaseTextColor1;
    [_addScrollView addSubview:nameTextField];
    
    [nameTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        
        registerViewModel.name=textField.text;
    }];
    
   
    self.frontCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _frontCardButton.frame=CGRectMake(CenterX, CGRectGetMaxY(nameTextField.frame)+sidePadding, BUTTON_SCREEN_WIDTH, BUTTON_SCREEN_HEIGHT);
    [self.frontCardButton addTarget:self action:@selector(frontCardCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.frontCardButton setBackgroundImage:[UIImage imageNamed:@"sessionIDCardFrontBg"] forState:UIControlStateNormal];
    [self.frontCardButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [_addScrollView addSubview:self.frontCardButton];
    
    UILabel *frontLabel = [UILabel new];
    frontLabel.frame=CGRectMake(CenterX, CGRectGetMaxY(_frontCardButton.frame)+5, BUTTON_SCREEN_WIDTH, 13);
    frontLabel.font = AppBaseTextFont2;
    frontLabel.textColor = AppBaseTextColor1;
    frontLabel.textAlignment = NSTextAlignmentCenter;
    frontLabel.text = @"Lượt tải lên dẫn đầu.";
    [_addScrollView addSubview:frontLabel];
    
    
    
    self.backCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backCardButton.frame=CGRectMake(CenterX, CGRectGetMaxY(frontLabel.frame)+sidePadding, BUTTON_SCREEN_WIDTH, BUTTON_SCREEN_HEIGHT);
    [self.backCardButton addTarget:self action:@selector(backCardCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backCardButton setBackgroundImage:[UIImage imageNamed:@"上传背面身份证底"] forState:UIControlStateNormal];
    [self.backCardButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [_addScrollView addSubview:self.backCardButton];
    
    UILabel *backLabel = [UILabel new];
    backLabel.font = AppBaseTextFont2;
    backLabel.textColor = AppBaseTextColor1;
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.text = @"Lượt tải đưa quốc huy.";
    [_addScrollView addSubview:backLabel];
    backLabel.frame=CGRectMake(CenterX, CGRectGetMaxY(_backCardButton.frame)+5, BUTTON_SCREEN_WIDTH, 13);
    
    UILabel *titleThreeLabel = [UILabel new];
    titleThreeLabel.frame=CGRectMake(verticalPadding, CGRectGetMaxY(backLabel.frame)+sidePadding, SCREEN_WIDTH-2*verticalPadding, 13);
    titleThreeLabel.font = textFont;
    titleThreeLabel.textColor = titleColor;
    titleThreeLabel.text = @"■ Tải lên quan trọng chứng minh";
    [_addScrollView addSubview:titleThreeLabel];
    
    self.relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.relationButton.frame=CGRectMake(CenterX, CGRectGetMaxY(titleThreeLabel.frame)+sidePadding, BUTTON_SCREEN_WIDTH, BUTTON_SCREEN_HEIGHT);
    [self.relationButton addTarget:self action:@selector(relationCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.relationButton setBackgroundImage:[UIImage imageNamed:@"vi_UploadingRelationshipBg"] forState:UIControlStateNormal];
    [self.relationButton setImage:[UIImage imageNamed:@"sessionIDCardCameraIcon"] forState:UIControlStateNormal];
    [_addScrollView addSubview:self.relationButton];
    
    UIButton*OptionalButton=[UIButton buttonWithType:UIButtonTypeCustom];
    OptionalButton.frame=CGRectMake(CGRectGetMaxX(self.relationButton.frame)-40, CGRectGetMinY(self.relationButton.frame), 40, 32);
    [_addScrollView addSubview:OptionalButton];
    [OptionalButton setBackgroundImage:[UIImage imageNamed:@"vi_OptionalBg"] forState:UIControlStateNormal];
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
    relationButtonLabel.text = @"Lượt tải lên bản đồ chứng  minh mối quan hệ";
    relationButtonLabel.numberOfLines=0;
    //relationButtonLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [_addScrollView addSubview:relationButtonLabel];
    
    UILabel *nextLabel = [UILabel new];
    nextLabel.frame=CGRectMake(CenterX, CGRectGetMaxY(relationButtonLabel.frame)+5, BUTTON_SCREEN_WIDTH, 40);
    nextLabel.font = AppBaseTextFont2;
    nextLabel.textColor = [UIColor redColor];;
    nextLabel.textAlignment = NSTextAlignmentCenter;
    nextLabel.text = @"(Dân hạng, nhưng tiếp tục bước tiếp theo.)";
    nextLabel.numberOfLines=0;
    [_addScrollView addSubview:nextLabel];
    
    
    UIButton *bindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bindButton.frame=CGRectMake(SCREEN_WIDTH/2-45, CGRectGetMaxY(nextLabel.frame)+verticalPadding+sidePadding, 90, 35);
    [bindButton addTarget:self action:@selector(checkFamilesDataAction) forControlEvents:UIControlEventTouchUpInside];
    bindButton.titleLabel.font = AppBaseTextFont1;
    [bindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bindButton setTitle:@"Ngay lập tức thêm" forState:UIControlStateNormal];
    [bindButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    bindButton.titleLabel.numberOfLines=0;
    [_addScrollView addSubview:bindButton];
    
    
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
