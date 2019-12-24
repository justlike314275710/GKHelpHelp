//
//  PSHRFaceAuthViewController.m
//  PrisonService
//
//  Created by kky on 2019/12/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSHRFaceAuthViewController.h"
#import "PSAuthorizationTool.h"
#import <ArcSoftFaceEngine/ArcSoftFaceEngine.h>
#import "ColorFormatUtil.h"
#import "Utility.h"
#import "ASFRManager.h"
#import "GLKitView.h"
#import "ASFCameraController.h"
#import "ASFVideoProcessor.h"
#import "PSPrisonerFamily.h"
#import "UIImage+Color.h"
#import "PSAlertView.h"
#import "HRFaceManager.h"
#import "PSAuthorizationTool.h"

//#define IMAGE_WIDTH     720
//#define IMAGE_HEIGHT    840

#define IMAGE_WIDTH     640
#define IMAGE_HEIGHT    480
typedef NS_ENUM(NSInteger, PSFaceDetectionType) {
    PSFaceDetectionTypeNone, //未检测到人了
    PSFaceDetectionTypeLoading, //人脸检测中
    PSFaceDetectionTypeFalut, //人脸检测失败
    PSFaceDetectionTypeOver, //人脸检测完成
};

@interface PSHRFaceAuthViewController ()<ASFCameraControllerDelegate, ASFVideoProcessorDelegate> {
    LPASF_FaceFeature _faceFacture; //虹软检测到人脸特征
    NSInteger _authIndex; //当前识别的人
    NSInteger _times;     //当前人脸识别错误次数
    BOOL _isFinish;       //全部人脸是否识别完毕
    BOOL _isSuspend;      //当前识别是否暂停(防止重复弹窗) YES 不会弹窗
    
}
@property (nonatomic, assign)PSFaceDetectionType detectionType; //当前检测的人脸状态
@property (nonatomic, strong)UIView  *topView;
@property (nonatomic, strong)UILabel *authStateLabl; //人脸检测中
@property (nonatomic, strong)UILabel *authName; //正在检测中人
@property (nonatomic, strong)UILabel *membersLabel; //正在检测中人
@property (nonatomic, strong)UILabel *membersTipLabel;
@property (nonatomic, strong)UILabel *iconLab;
@property (nonatomic, strong)UIImage *selectImage;
@property (nonatomic, strong)ArcSoftFaceEngine *engine; //人脸识别引擎
@property (nonatomic, strong)ASFRManager*       frManager;
@property (nonatomic, strong)ASFCameraController* cameraController;
@property (nonatomic, strong)ASFVideoProcessor* videoProcessor;
@property (nonatomic, strong)NSMutableArray* arrayAllFaceRectView;
@property (nonatomic, strong)GLKitView *glView;  //人脸识别界面
@property (nonatomic, strong)UIView *sacnView;


@end

@implementation PSHRFaceAuthViewController

#pragma mark ---------- LifeCycle
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //检测相机权限
    [PSAuthorizationTool checkAndRedirectCameraAuthorizationWithBlock:nil setBlock:nil isShow:NO];
    
    _detectionType = PSFaceDetectionTypeNone;
    _authIndex = 0;
    _isFinish = NO;
    _times = 0;
    _isSuspend = YES; //注册完成才开始提示
    self.frManager = [[ASFRManager alloc] init];
    if (self.meetViewModel.faceType == PSFaceAppointment) { //预约
        [self setupUI];
        [self registHR_race];
    } else {
        [self meetingFace];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cameraController startCaptureSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cameraController stopCaptureSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark ---------- Private Method
/** 视图初始化 */
- (void)setupUI {
    
    PSMeetingViewModel *viewModel = self.meetViewModel;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(11);
    }];
    
    //人脸识别镜头//适配不同手机
    CGFloat GLViewWidth = SCREEN_WIDTH*0.6; //6
    if (KScreenHeight==568) { //5
        GLViewWidth = SCREEN_WIDTH*0.53;
    }
    if (KScreenHeight>735&&KScreenHeight<812) {
        GLViewWidth = KScreenWidth*0.7;  //PLUS
    }
    if (KScreenHeight>811) {
        GLViewWidth = SCREEN_WIDTH-60;  //X
    }
    CGFloat GLViewHeight = 1.3*GLViewWidth;
    CGFloat GLViewLeft =  (KScreenWidth-GLViewWidth)/2;
    self.glView = [[GLKitView alloc] init];
    [self.view addSubview:self.glView];
    [self.glView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(GLViewLeft);
        make.top.mas_equalTo(45);
        make.width.mas_equalTo(GLViewWidth);
        make.height.mas_equalTo(GLViewHeight);
    }];
    
    [self.glView addSubview:self.sacnView];
    _sacnView.frame = CGRectMake(0, 0,self.glView.width, self.glView.height);
    
    //四个角
    NSArray *hornImageNames = @[@"scanning_left_top",@"scanning_right_top",@"scanning_left_bottom",@"scanning_right_bottom"];
    for (int i = 0; i<hornImageNames.count; i++) {
        CGFloat x = i%2;
        CGFloat y = i/2;
        CGFloat horn_left = GLViewLeft-5+x*(GLViewWidth);
        CGFloat horn_top = 40+y*(GLViewHeight);
        UIImageView *hornImageView = [[UIImageView alloc] init];
        hornImageView.image = IMAGE_NAMED(hornImageNames[i]);
        [self.view addSubview:hornImageView];
        [hornImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(horn_left);
            make.top.mas_equalTo(horn_top);
            make.width.height.mas_equalTo(10);
        }];
    }
    
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)uiOrientation;
    self.arrayAllFaceRectView = [NSMutableArray arrayWithCapacity:0];
    self.videoProcessor = [[ASFVideoProcessor alloc] init];
    self.videoProcessor.delegate = self;
    [self.videoProcessor initProcessor];
    self.cameraController = [[ASFCameraController alloc]init];
    self.cameraController.delegate = self;
    [self.cameraController setupCaptureSession:videoOrientation isFront:YES];
    [self.cameraController startCaptureSession];
    
    //stateLabl
    [self.view addSubview:self.authStateLabl];
    [self.authStateLabl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(21);
        make.centerX.mas_equalTo(self.glView);
    }];
    
    [self.view addSubview:self.authName];
    [self.authName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.glView.mas_bottom).offset(8);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(21);
        make.centerX.mas_equalTo(self.glView);
    }];
    
    [self.view addSubview:self.membersLabel];
    [self.membersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authName.mas_bottom).offset(17);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(31);
    }];
    
    [self.view addSubview:self.iconLab];
    [self.iconLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.membersLabel.mas_bottom).offset(15);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(10);
        make.left.mas_equalTo(12);
    }];
    
    [self.view addSubview:self.membersTipLabel];
    [self.membersTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.membersLabel.mas_bottom).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(30);
    }];
    
    for (int i = 0; i<viewModel.FamilyMembers.count; i++) {
        
        PSPrisonerFamily *prisonerFamily = viewModel.FamilyMembers[i];
        CGFloat x = 15+(((KScreenWidth-270)/2)+80)*i;
        UIImageView *headimageView = [[UIImageView alloc] init];
        headimageView.image = IMAGE_NAMED(@"meetingAuthIcon");
        headimageView.tag = 100+i;
        [self.view addSubview:headimageView];
        [headimageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(80);
            make.left.mas_equalTo(x);
            make.top.mas_equalTo(self.membersTipLabel.mas_bottom).offset(10);
        }];
        
        NSLog(@"%@",prisonerFamily.familyName);
        NSString *imageURL = [prisonerFamily.familyAvatarUrl copy];
        [headimageView sd_setImageWithURL:[NSURL URLWithString:PICURL(imageURL)] placeholderImage: IMAGE_NAMED(@"meetingAuthIcon") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                NSLog(@"----------%@----------",error);
            }
        }];
        UIImageView *coverImageView = [[UIImageView alloc] init];
        coverImageView.tag = 300+i;
        coverImageView.hidden = YES;
        UIImage *corverImage = [UIImage imageByApplyingAlpha:.8 image:IMAGE_NAMED(@"识别通过")];
        coverImageView.image = corverImage;
        [self.view addSubview:coverImageView];
        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.right.left.top.mas_equalTo(headimageView);
        }];
        UILabel *nameLabl = [self setNameLabel];
        nameLabl.tag = 200+i;
        [self.view addSubview:nameLabl];
        [nameLabl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(90);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(x-5);
            make.top.mas_equalTo(headimageView.mas_bottom).offset(5);
        }];
        [nameLabl setText:prisonerFamily.familyName];
    }
}


#pragma mark ---------- 识别时候UI更新
-(void)upDataUI{
    PSPrisonerFamily *prisonerFamily = [self.meetViewModel.FamilyMembers objectAtIndex:_authIndex];
    NSString *name = [NSString stringWithFormat:@"%@",prisonerFamily.familyName];
    self.authName.text = [NSString stringWithFormat:@"[%@]",name];
    switch (self.detectionType) {
        case PSFaceDetectionTypeNone:
        {
            _authStateLabl.text = @"未识别到人脸";
        }
            break;
        case PSFaceDetectionTypeLoading:
        {
            _authStateLabl.text = @"人脸检测中";
        }
            break;
        case PSFaceDetectionTypeFalut:
        {
            _authStateLabl.text = @"人脸识别失败";
        }
            break;
        case PSFaceDetectionTypeOver:
        {
            _authStateLabl.text = @"人脸识别成功";
        }
            break;
        default:
            break;
    }
    [self.meetViewModel.FamilyMembers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PSPrisonerFamily *prisonerInfo = (PSPrisonerFamily *)obj;
        NSString *infoName = [NSString stringWithFormat:@"%@",prisonerInfo.familyName];
        UIImageView *coverImageView = (UIImageView *)[self.view viewWithTag:idx+300];
        UILabel *label = (UILabel *)[self.view viewWithTag:idx+200];
        if (idx==_authIndex) {
            label.text = [NSString stringWithFormat:@"%@...",_authStateLabl.text];
        } else {
            label.text = [NSString stringWithFormat:@"%@",infoName];
        }
        if (_isFinish) label.text = [NSString stringWithFormat:@"%@",infoName];
        if (idx<_authIndex) {
            coverImageView.hidden = NO;
        } else if(idx==_authIndex&&_isFinish) {
            coverImageView.hidden = NO;
            _authStateLabl.text = @"人脸识别成功";
        }
    }];
    
}
//会见获取需要识别的家属
-(void)meetingFace{
    [[PSLoadingView sharedInstance] show];
    [self.meetViewModel requestFamilyMembersCompleted:^(PSResponse *response) {
        if (response.code==200) {
            [self setupUI];
            [self registHR_race];
        }
        else{
            [PSTipsView showTips:response.msg?response.msg:@"获取会见列表失败"];
        }
        [[PSLoadingView sharedInstance] dismiss];
    } failed:^(NSError *error) {
        [self showNetError:error];
        [[PSLoadingView sharedInstance] dismiss];
    }];
}
- (void)verifyFaceScuess {
    [PSAlertView showWithTitle:nil message:@"人脸识别成功" messageAlignment:NSTextAlignmentCenter image:IMAGE_NAMED(@"识别成功") handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==0) {
            [self.cameraController startCaptureSession];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isSuspend = NO;
            });
        }
    } buttonTitles:@"识别下一位", nil];
}

- (void)regisFaceFailed:(NSString *)familyName {
    _isSuspend = YES;
    NSString *message = [NSString stringWithFormat:@"检测不到家属%@的认证头像,请联系监狱管理人员，重新上传认证头像",familyName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)verifyFaceFailed {
    NSString * title = @"人脸识别失败";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:VerifyFaceFailedReson preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        _times = 0;
        //不延时退出可能导致退出还会弹一次框
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isSuspend = NO;
        });
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"再试一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.cameraController startCaptureSession];
        _detectionType = PSFaceDetectionTypeLoading;
        [self upDataUI];
        //预约
        if (self.meetViewModel.faceType == PSFaceAppointment) {
            _times++;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isSuspend = NO;
        });
    }]];
    if (_times>1) {
        [PSAlertView showWithTitle:nil message:@"人脸识别失败,请重新预约远程探视会见" messageAlignment:NSTextAlignmentCenter image:IMAGE_NAMED(@"识别失败")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
#pragma mark ---------- 摄像头人脸识别
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    ASF_CAMERA_DATA* cameraData = [Utility getCameraDataFromSampleBuffer:sampleBuffer];
    NSArray *arrayFaceInfo = [self.videoProcessor process:cameraData];
    dispatch_sync(dispatch_get_main_queue(), ^{

        [self.glView renderWithCVPixelBuffer:cameraFrame orientation:0 mirror:NO];
        
        if(self.arrayAllFaceRectView.count >= arrayFaceInfo.count)
        {
            for (NSUInteger face=arrayFaceInfo.count; face<self.arrayAllFaceRectView.count; face++) {
                UIView *faceRectView = [self.arrayAllFaceRectView objectAtIndex:face];
                faceRectView.hidden = YES;
            }
        }
        else
        {
            for (NSUInteger face=self.arrayAllFaceRectView.count; face<arrayFaceInfo.count; face++) {
                UIStoryboard *faceRectStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIView *faceRectView = [faceRectStoryboard instantiateViewControllerWithIdentifier:@"FaceRectVideoController"].view;
                [self.view addSubview:faceRectView];
                [self.arrayAllFaceRectView addObject:faceRectView];
            }
        }
        
        for (NSUInteger face = 0; face < arrayFaceInfo.count; face++) {
            UIView *faceRectView = [self.arrayAllFaceRectView objectAtIndex:face];
            ASFVideoFaceInfo *faceInfo = [arrayFaceInfo objectAtIndex:face];
            faceRectView.hidden = NO;
            faceRectView.frame = [self dataFaceRect2ViewFaceRect:faceInfo.faceRect];
//            UILabel* labelInfo = (UILabel*)[faceRectView viewWithTag:1];
//            [labelInfo setTextColor:[UIColor yellowColor]];
//            labelInfo.font = [UIFont boldSystemFontOfSize:15];
//            MInt32 gender = faceInfo.gender;
//            NSString *genderInfo = gender == 0 ? @"男" : (gender == 1 ? @"女" : @"不确定");
//            labelInfo.text = [NSString stringWithFormat:@"age:%d gender:%@", faceInfo.age, genderInfo];
//            UILabel* labelFaceAngle = (UILabel*)[faceRectView viewWithTag:6];
//            labelFaceAngle.font = [UIFont boldSystemFontOfSize:15];
//            [labelFaceAngle setTextColor:[UIColor yellowColor]];
            if(faceInfo.face3DAngle.status == 0) {
//                labelFaceAngle.text = [NSString stringWithFormat:@"r=%.2f y=%.2f p=%.2f", faceInfo.face3DAngle.rollAngle, faceInfo.face3DAngle.yawAngle, faceInfo.face3DAngle.pitchAngle];
            } else {
//                labelFaceAngle.text = @"Failed face 3D Angle";
            }
        }
    });
    
    [Utility freeCameraData:cameraData];
}
#pragma mark ---------- 激活虹软人脸识别SDK
-(void)registHR_race{
    [[HRFaceManager sharedInstance] registHRSDK:^(PSHRFaceBackResultType result) {
        if (result==PSFaceBackSDKRegistFail) {
            [PSTipsView showTips:@"人脸识别SDK注册失败"];
        } else if(result==PSFaceBackSDKInitFail) {
            [PSTipsView showTips:@"人脸识别SDK初始化失败"];
        } else if (result==PSFaceBackSDKInitSuccess) {
            [self getAuthFace];
        }
    }];
}
#pragma mark ---------- 获取需要注册的人脸
-(void)getAuthFace{
    //注册人脸本地有不需要就不需要注册
    NSArray* persons = self.frManager.allPersons;
    __block BOOL isRegisFail = NO;
    [self.meetViewModel.FamilyMembers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PSPrisonerFamily *prisonerFamily = (PSPrisonerFamily *)obj;
        BOOL isContail = NO;
        for (ASFRPerson* person in persons){
            if ([person.name isEqualToString:prisonerFamily.familyAvatarUrl]) { //图片地址作为唯一ID
                isContail = YES;
                //放在SD加载失败image再次赋值
                UIImageView *imageV = (UIImageView *)[self.view viewWithTag:100+idx];
                imageV.image = person.faceThumb;
                break;
            }
        }
        if (!isContail) {
            //提取图片特征
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:PICURL(prisonerFamily.familyAvatarUrl)]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    UIImageView *imageV = (UIImageView *)[self.view viewWithTag:100+idx];
                    imageV.image = image;
                    [self HR_checkFace:image name:prisonerFamily.familyAvatarUrl familyName:prisonerFamily.familyName block:^(PSHRFaceBackResultType result) {
                        if (result==PSFaceBackSDKcheckImageFail) {
                            isRegisFail = YES;
                        } else if (result == PSFaceBackSDKcheckImageNoFace) {
                            isRegisFail = YES;
                        }
                    }];
                });
            });
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isRegisFail==YES) {
            _isSuspend=YES; //不能弹提示
        } else {
            _isSuspend = NO; //可以弹提示
        }
    });
}
#pragma mark ---------- 检测人脸提取信息
-(void)HR_checkFace:(UIImage*)faceimage name:(NSString *)name familyName:(NSString *)familyName block:(HRSDKblock)block  {
    
    [[HRFaceManager sharedInstance] hrsdkCheckFace:faceimage sdkblock:^(PSHRFaceBackResultType result) {
        if (result==PSFaceBackSDKcheckImageFail) {
           //人脸检测失败
            if (block) block(PSFaceBackSDKcheckImageFail);
            [self regisFaceFailed:familyName];
        } else if (result==PSFaceBackSDKcheckImageNoFace) {
           //没有人脸
            if (block) block(PSFaceBackSDKcheckImageNoFace);
            [self regisFaceFailed:familyName];
        }
    } checkBlock:^(LPASF_FaceFeature  _Nonnull faceFacture) {
        if (faceFacture) {
            _faceFacture = faceFacture;
            BOOL result = [self registerPersonImage:faceimage personName:name];
            if (result) {
                NSLog(@"注册成功");
            } else {
                NSLog(@"注册失败");
                if (block) block(PSFaceBackSDKcheckImageFail);
                [self regisFaceFailed:familyName];
            }
        }
    }];
}


#pragma mark ---------- 注册人脸
//注册人脸
- (BOOL)registerPersonImage:(UIImage *)image personName:(NSString *)personName
{
    ASFRPerson *registerPerson = [[ASFRPerson alloc] init];
    registerPerson.faceFeatureData = [NSData dataWithBytes:_faceFacture->feature length:_faceFacture->featureSize];
    if(registerPerson == nil || registerPerson.registered)
        return NO;
    registerPerson.name = personName;
    registerPerson.faceThumb = image;
    registerPerson.Id = [self.frManager getNewPersonID];
//    registerPerson.registered = [self.frManager addPerson:registerPerson];
//    return registerPerson.registered;
    BOOL result = [self.videoProcessor image_registerDetectedPerson:registerPerson];
    return result;
}
#pragma mark ---------- AFVideoProcessorDelegate
- (void)processRecognized:(NSString *)personName personAry:(NSMutableArray *)personAry allmachAry:(NSMutableArray *)allmachAry
{
//    NSArray *ary = [self.frManager allPersons];
//    NSLog(@"%@",ary);
//    for (NSString *url in allmachAry) {
//        NSString *urlstring = PICURL(url);
//        NSLog(@"%@",urlstring);
//
//    }
    PSPrisonerFamily *prisonerFamily = [self.meetViewModel.FamilyMembers objectAtIndex:_authIndex];
    if ([allmachAry containsObject:prisonerFamily.familyAvatarUrl]) {  
        if (_authIndex<self.meetViewModel.FamilyMembers.count-1&&!_isSuspend) {
            //识别成功
            [self.cameraController stopCaptureSession];
            _detectionType = PSFaceDetectionTypeOver;
            [self upDataUI];
            _authIndex++;
            _times = 0;
            _isSuspend = YES;
            [self verifyFaceScuess];
        } else if (_authIndex==self.meetViewModel.FamilyMembers.count-1&&!_isFinish) {
            [self.cameraController stopCaptureSession];
            _detectionType = PSFaceDetectionTypeOver;
            _isFinish = YES;
            _times = 0;
            [self upDataUI];
            //识别完毕
            [PSAlertView showWithTitle:nil message:@"人脸识别成功" messageAlignment:NSTextAlignmentCenter image:IMAGE_NAMED(@"识别成功")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.completion) self.completion(YES);
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } else {
        if (personAry.count<0||!personAry) {
            _detectionType = PSFaceDetectionTypeNone;
            [self upDataUI];
        } else {
            //识别到错误的人
            if (personAry.count>0) {
                ASFVideoFaceInfo *faceInfo = personAry[0];
                if (faceInfo.face3DAngle&&_isSuspend==NO&&!_isFinish) {
                    [self.cameraController stopCaptureSession];
                    _isSuspend = YES;
                    _detectionType = PSFaceDetectionTypeFalut;
                    [self upDataUI];
                    [self verifyFaceFailed];
                } else {
                    _detectionType = PSFaceDetectionTypeLoading;
                    [self upDataUI];
                }
            }
        }
    }
}
- (CGRect)dataFaceRect2ViewFaceRect:(MRECT)faceRect
{
    CGRect frameFaceRect = {0};
    CGRect frameGLView = self.glView.frame;
    frameFaceRect.size.width = CGRectGetWidth(frameGLView)*(faceRect.right-faceRect.left)/IMAGE_WIDTH;
    frameFaceRect.size.height = CGRectGetHeight(frameGLView)*(faceRect.bottom-faceRect.top)/IMAGE_HEIGHT;
    frameFaceRect.origin.x = CGRectGetWidth(frameGLView)*faceRect.left/IMAGE_WIDTH;
    frameFaceRect.origin.y = CGRectGetHeight(frameGLView)*faceRect.top/IMAGE_HEIGHT;
    return frameFaceRect;
}

#pragma mark ---------- Setter & Getter
-(UILabel *)authStateLabl{
    if(_authStateLabl==nil){
        _authStateLabl = [[UILabel alloc] init];
        _authStateLabl.text = @"人脸检测中";
        _authStateLabl.font = FontOfSize(14);
        _authStateLabl.textAlignment = NSTextAlignmentCenter;
        _authStateLabl.textColor = UIColorFromRGB(38, 76, 144);
    }
    return _authStateLabl;
}

-(UILabel *)authName{
    if(_authName==nil){
        _authName = [[UILabel alloc] init];
        _authName.text = @"";
        _authName.font = FontOfSize(12);
        _authName.textAlignment = NSTextAlignmentCenter;
        _authName.textColor = UIColorFromRGB(51, 51, 51);
    }
    return _authName;
}
-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorFromRGB(249,248,254);
    }
    return _topView;
}

-(UILabel *)membersLabel{
    if(_membersLabel==nil){
        _membersLabel = [[UILabel alloc] init];
        _membersLabel.text = @"     本次会见家属";
        _membersLabel.font = FontOfSize(12);
        _membersLabel.textAlignment = NSTextAlignmentLeft;
        _membersLabel.textColor = UIColorFromRGB(51, 51, 51);
        _membersLabel.backgroundColor = UIColorFromRGB(249,248,254);
    }
    return _membersLabel;
}
-(UILabel *)iconLab{
    if(_iconLab==nil){
        _iconLab = [[UILabel alloc] init];
        _iconLab.text = @"*";
        _iconLab.font = FontOfSize(12);
        _iconLab.textAlignment = NSTextAlignmentLeft;
        _iconLab.textColor = UIColorFromRGB(40,77,145);
    }
    return _iconLab;
}

-(UILabel *)membersTipLabel{
    if(_membersTipLabel==nil){
        _membersTipLabel = [[UILabel alloc] init];
        _membersTipLabel.text = @"本次参与会见家属必须全部通过人脸识别;\n请家属依次进行人脸识别.";
        _membersTipLabel.font = FontOfSize(12);
        _membersTipLabel.numberOfLines = 0;
        _membersTipLabel.textAlignment = NSTextAlignmentLeft;
        _membersTipLabel.textColor = UIColorFromRGB(102,102,102);
    }
    return _membersTipLabel;
}

-(UILabel *)setNameLabel{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"尼古拉斯凯奇";
    label.textColor = UIColorFromRGB(51, 51, 51);
    label.font = FontOfSize(12);
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
-(UIView *)sacnView{
    if (!_sacnView) {
        _sacnView = [[UIView alloc] init];
        _sacnView.backgroundColor = [UIColor colorWithWhite:1 alpha:.5];
    }
    return _sacnView;
}

- (BOOL)fd_interactivePopDisabled {
    return YES;
}




@end
