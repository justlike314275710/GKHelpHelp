//
//  PSFaceAuthViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "PSAppointmentViewController.h"
#import "PSAlertView.h"
#import "PSFaceAuthViewController.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import "PSThirdPartyConstants.h"
#import "PSBusinessConstants.h"
#import "PSSessionManager.h"
#import "CaptureManager.h"
#import "IFlyFaceImage.h"
#import "IFlyFaceResultKeys.h"
#import "CanvasView.h"
#import "CalculatorTools.h"
#import "UIImage+Extensions.h"
#import "PSTipsConstants.h"
#import "WXZTipView.h"
#import "PSMeetingViewModel.h"
#import "PSPrisonerFamily.h"
#import "PSFamilyFaceViewController.h"
#import "PSMeetingManager.h"
#import "PSAuthorizationTool.h"
#import "ZXCTimer.h"
#define MAX_VERIFY_TIMES 5
typedef void(^PhotoBlcok)();
typedef UIImage *(^ImageBlock)(UIImageView *showImageView);
@interface PSFaceAuthViewController ()<IFlyFaceRequestDelegate,CaptureManagerDelegate>

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) IFlyFaceDetector *faceDetector;
@property (nonatomic, strong) IFlyFaceRequest *faceRequest;
@property (nonatomic, strong) NSString *resultStrings;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) CaptureManager *captureManager;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) BOOL isLockTap;
@property (nonatomic, strong) CanvasView *viewCanvas;
@property (nonatomic, assign) BOOL isVerifying;
@property (nonatomic, assign) NSInteger times;

@property (nonatomic , strong) UILabel*statusTipsLable;
@property (nonatomic , strong) UILabel*FaceRecognitionLab;
@property (nonatomic , assign) int i;
@property (nonatomic , strong)   UILabel*FamliesOneLab ;

@end


@implementation PSFaceAuthViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.i=0;
        //self.gid=nil;
        self.times = 0;
        NSString*meet_face=NSLocalizedString(@"meet_face", @"会见人脸识别");
        self.title=meet_face;
        self.faceDetector = [IFlyFaceDetector sharedInstance];
        self.faceRequest = [IFlyFaceRequest sharedInstance];
        [self.faceRequest setDelegate:self];

    }
    return self;
}

- (void)registerFaceFailed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:REisterFaceFailed preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.completion) {
            self.completion(NO);
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)appointmentVerifyFaceFailed {
    _FaceRecognitionLab.text=@"人脸识别失败";
    _FamliesOneLab.text=@"人脸识别失败";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VerifyFaceFailed message:VerifyFaceFailedReson preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.times = 0;
        if (self.completion) {
            self.completion(NO);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"再试一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.times++;
        if (self.isVerifying) {
            self.isVerifying = NO;
        }
    }]];
    
    if (self.times>1) {
        [PSAlertView showWithTitle:nil message:@"人脸识别失败,请重新预约远程探视会见" messageAlignment:NSTextAlignmentCenter image:IMAGE_NAMED(@"识别失败")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.completion) {
                self.completion(NO);
            }
        });
    } else {
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}


- (void)meetingMentVerifyFaceFailed {
    _FaceRecognitionLab.text=@"人脸识别失败";
    _FamliesOneLab.text=@"人脸识别失败";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VerifyFaceFailed message:VerifyFaceFailedReson preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"再试一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.times = 0;
     
        if (self.isVerifying) {
            self.isVerifying = NO;
        }
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];

    
}


- (void)beginFaceAuthData:(NSData *)data {
    self.resultStrings = [[NSString alloc] init];
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    PSPrisonerFamily*model=viewModel.FamilyMembers[_i];
    NSString*uuid=model.familyUuid;
    [self.faceRequest setParameter:[IFlySpeechConstant FACE_REG] forKey:[IFlySpeechConstant FACE_SST]];
    [self.faceRequest setParameter:KEDAXUNFEI_APPID forKey:[IFlySpeechConstant APPID]];
    [self.faceRequest setParameter:uuid forKey:@"auth_id"];
    [self.faceRequest setParameter:@"del" forKey:@"property"];
    [self.faceRequest sendRequest:data];
}

- (void)beginFaceVerifyWithData:(NSData *)data {
    self.resultStrings = [[NSString alloc] init];
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    PSPrisonerFamily*model=viewModel.FamilyMembers[_i];
    NSString*uuid=model.familyUuid;
    [self.faceRequest setParameter:[IFlySpeechConstant FACE_VERIFY] forKey:[IFlySpeechConstant FACE_SST]];
    [self.faceRequest setParameter:KEDAXUNFEI_APPID forKey:[IFlySpeechConstant APPID]];
    [self.faceRequest setParameter:uuid forKey:@"auth_id"];
    [self.faceRequest setParameter:self.gid forKey:[IFlySpeechConstant FACE_GID]];
    [self.faceRequest setParameter:@"2000" forKey:@"wait_time"];
    [self.faceRequest sendRequest:data];
}

- (void)registerFaceGid {
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    PSPrisonerFamily*model=viewModel.FamilyMembers[_i];
    NSString*avatarUrl=model.familyAvatarUrl;
    if(viewModel.faceType==0){
        @weakify(self)
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:PICURL(avatarUrl)] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                @strongify(self)
                if (error) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:PICURL(avatarUrl)]];
                        __block UIImage *loadimage = [UIImage imageWithData:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (loadimage) {
                                CGSize maxSize = CGSizeMake(200, 200);
                                if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
                                    loadimage = [loadimage imageByScalingProportionallyToSize:maxSize];
                                }
                                NSData *compressData = [loadimage compressedData];
                                [self beginFaceAuthData:compressData];
                            } else {
                                NSLog(@"%@",@"图片下载失败");
                                [self registerFaceFailed];
                            }
                        });
                    });
                  
                }else{
                    CGSize maxSize = CGSizeMake(200, 200);
                    if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
                        image = [image imageByScalingProportionallyToSize:maxSize];
                    }
                    NSData *compressData = [image compressedData];
                    [self beginFaceAuthData:compressData];
                }
            }];

        
        
    }
    else {
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:PICURL(avatarUrl)] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            //@strongify(self)
            if (error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:PICURL(avatarUrl)]];
                    __block UIImage *loadimage = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (loadimage) {
                            CGSize maxSize = CGSizeMake(200, 200);
                            if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
                                loadimage = [loadimage imageByScalingProportionallyToSize:maxSize];
                            }
                            NSData *compressData = [loadimage compressedData];
                            [self beginFaceAuthData:compressData];
                        } else {
                            NSLog(@"%@",@"图片下载失败");
                            [self registerFaceFailed];
                        }
                    });
                });
            }else{
                CGSize maxSize = CGSizeMake(200, 200);
                if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
                    image = [image imageByScalingProportionallyToSize:maxSize];
                }
                NSData *compressData = [image compressedData];
                [self beginFaceAuthData:compressData];
            }
        }];
    }

}

- (void)handleFaceResult {
    NSError *error = nil;
    NSData *resultData=[self.resultStrings dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
    if(dic){
        NSString *strSessionType = [dic objectForKey:KCIFlyFaceResultSST];
        //注册
        if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
            NSString *ret = dic[KCIFlyFaceResultRet];
            NSString *rst = dic[KCIFlyFaceResultRST];
            if (ret.integerValue == 0) {
                if ([rst isEqualToString:KCIFlyFaceResultSuccess]) {
                    NSString *gid = dic[KCIFlyFaceResultGID];
                    self.gid = gid;
                }else{
                    [self registerFaceFailed];
                }
            }else{
                [self registerFaceFailed];
            }
        }
        //验证
        if([strSessionType isEqualToString:KCIFlyFaceResultVerify]) {
            NSString *rst = [dic objectForKey:KCIFlyFaceResultRST];
            NSString *ret = [dic objectForKey:KCIFlyFaceResultRet];
             _FaceRecognitionLab.text=@"人脸识别中";
             _FamliesOneLab.text=@"人脸识别中";
            if([ret integerValue] == 0){
                if([rst isEqualToString:KCIFlyFaceResultSuccess]){
                    NSString *verf = [dic objectForKey:KCIFlyFaceResultVerf];
                    if([verf boolValue]){
                        [SDTrackTool logEvent:FACE_RECOGNITION attributes:@{STATUS:MobSUCCESS}];
                        //验证成功
                        PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
                       // @weakify(self)
                        if (viewModel.FamilyMembers.count==1) {
                            if (self.completion) {
                                _FamliesOneLab.text=@"人脸识别成功";
                                _FaceRecognitionLab.text=@"人脸识别成功";
                                [PSAlertView showWithTitle:nil message:@"人脸识别成功" messageAlignment:NSTextAlignmentCenter image:IMAGE_NAMED(@"识别成功")];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    self.completion(YES);
                                   
                                });
                                
                            }
                            return;
                           
                        }
//                        else if (viewModel.FamilyMembers.count==0){
//                            @strongify(self)
//                            if (self.completion) {
//                                self.completion(YES);
//                            }
//                            return;
//                        }
                        else {
                                _FamliesOneLab.text=@"人脸识别成功";
                            _FaceRecognitionLab.text=@"人脸识别成功";
                                [PSAlertView showWithTitle:nil message:@"人脸识别成功" messageAlignment:NSTextAlignmentCenter image:IMAGE_NAMED(@"识别成功") handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
                                    if (buttonIndex==0) {
                                        
                                        PSFamilyFaceViewController *authViewController = [[PSFamilyFaceViewController alloc] initWithViewModel:viewModel];
                                        [authViewController setCompletion:^(BOOL successful) {
                                            if (successful) {
                                                if (self.completion) {
                                                    self.completion(YES);
                                                }
                                                [self popToAppointViewController];
                                            }
                                            else{
                                                [self popToAppointViewController];
                                            }
                                          
                                        }];

                                        [self.navigationController pushViewController:authViewController animated:NO];
                                    }
                                } buttonTitles:@"识别下一位", nil];
                            return;

                        }

                   }
                    else{
                       // [WXZTipView showBottomWithText:@"人脸识别失败" duration:1.0f];
                       
                        [SDTrackTool logEvent:FACE_RECOGNITION attributes:@{STATUS:MobFAILURE}];
                        [self verifyFaceFailedType];
                      
                    }
                }
            }
        }
    }
}


-(void)popToAppointViewController{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[PSAppointmentViewController class]]) {
        PSAppointmentViewController*appointViewController=(PSAppointmentViewController*)controller;
            [self.navigationController popToViewController:appointViewController animated:NO];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    [self.captureManager observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (NSString *)praseDetect:(NSDictionary* )positionDic OrignImage:(IFlyFaceImage*)faceImg{
    if(!positionDic){
        return nil;
    }
    // 判断摄像头方向
    BOOL isFrontCamera = self.captureManager.videoDeviceInput.device.position == AVCaptureDevicePositionFront;
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.previewLayer.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.previewLayer.frame.size.height / faceImg.width;
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    float cx = (left+right)/2;
    float cy = (top + bottom)/2;
    float w = right - left;
    float h = bottom - top;
    
    float ncx = cy ;
    float ncy = cx ;
    
    CGRect rectFace = CGRectMake(ncx-w/2 ,ncy-w/2 , w, h);
    
    if(!isFrontCamera){
        rectFace = rSwap(rectFace);
        rectFace = rRotate90(rectFace, faceImg.height, faceImg.width);
    }
    rectFace = rScale(rectFace, widthScaleBy, heightScaleBy);
    return NSStringFromCGRect(rectFace);
    
}

- (NSMutableArray *)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg{
    if(!landmarkDic){
        return nil;
    }
    
    // 判断摄像头方向
    BOOL isFrontCamera=self.captureManager.videoDeviceInput.device.position == AVCaptureDevicePositionFront;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.previewLayer.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.previewLayer.frame.size.height / faceImg.width;
    
    NSMutableArray *arrStrPoints = [NSMutableArray array] ;
    NSEnumerator* keys=[landmarkDic keyEnumerator];
    for(id key in keys){
        id attr=[landmarkDic objectForKey:key];
        if(attr && [attr isKindOfClass:[NSDictionary class]]){
            
            id attr=[landmarkDic objectForKey:key];
            CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y,x);
            
            if(!isFrontCamera){
                p=pSwap(p);
                p=pRotate90(p, faceImg.height, faceImg.width);
            }
            
            p=pScale(p, widthScaleBy, heightScaleBy);
            
            [arrStrPoints addObject:NSStringFromCGPoint(p)];
            
        }
    }
    return arrStrPoints;
}





- (void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg {
    if(!result){
        return;
    }
    @try {
        NSError *error;
        NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *faceDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        if(!faceDic){
            return;
        }
        NSString *faceRet = [faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray *faceArray = [faceDic objectForKey:KCIFlyFaceResultFace];
        int ret = 0;
        if(faceRet){
            ret = [faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret||!faceArray ||[faceArray count] < 1) {
            [self hideFace];
            _FaceRecognitionLab.text=@"未检测到人脸,请露出正脸";
            _FamliesOneLab.text=@"请露出正脸";
        return;
        }
        
        //检测到人脸
        NSMutableArray *arrPersons = [NSMutableArray array];
        for(id faceInArr in faceArray){
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                NSDictionary *positionDic = [faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString *rectString = [self praseDetect:positionDic OrignImage: faceImg];
                
                NSDictionary *landmarkDic = [faceInArr objectForKey:KCIFlyFaceResultLandmark];
                NSMutableArray *strPoints = [self praseAlign:landmarkDic OrignImage:faceImg];
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }
                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson] ;
                [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
            }
        }
        if (!self.isVerifying && self.gid.length > 0) {
            self.isVerifying = YES;
            [self beginFaceVerifyWithData:[faceImg.image compressedData]];
            _FaceRecognitionLab.text=@"人脸识别中";
             _FamliesOneLab.text=@"人脸识别中";
            //faceImg.image = nil;
        }
//        else{
//              NSString*no_face=NSLocalizedString(@"face_fail", @"人脸识别失败");
//              _statusTipsLable.text=no_face;
//        }
    }@catch (NSException *exception) {
        PSLog(@"prase exception:%@",exception.name);
    }@finally {
    }
    
}

- (void)hideFace {
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
}

- (void)showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons{
    if (self.viewCanvas.hidden) {
        self.viewCanvas.hidden = NO ;
    }
    self.viewCanvas.arrPersons = arrPersons ;
    [self.viewCanvas setNeedsDisplay] ;
}


- (BOOL)hiddenNavigationBar {
    return NO;
}

- (BOOL)fd_interactivePopDisabled {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureManager removeObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(void)dealloc{
    self.captureManager=nil;
    self.viewCanvas=nil;
    self.faceRequest.delegate=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   self.faceDetector = [IFlyFaceDetector sharedInstance];
   [self JudgeFaceRecognitionType];
}

#pragma mark - IFlyFaceRequestDelegate
- (void)onEvent:(int) eventType WithBundle:(NSString*) params {
    
}

- (void)onData:(NSData *)data {
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"onData:||%@",result);
    if (result) {
        self.resultStrings = [self.resultStrings stringByAppendingString:result];
    }
}

- (void)onCompleted:(IFlySpeechError*) error {
     NSLog(@"onCompleted||%@",error);
    if (error.errorCode == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleFaceResult];
        });
    }else{
        if (self.isVerifying) {
            self.isVerifying = NO;
        }
    }
}

#pragma mark - CaptureManagerDelegate
- (void)onOutputFaceImage:(IFlyFaceImage *)faceImg {
    NSString*strResult=[[NSString alloc]init];
    strResult = [self.faceDetector trackFrame:faceImg.data withWidth:faceImg.width height:faceImg.height direction:(int)faceImg.direction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self praseTrackResult:strResult OrignImage:faceImg];
    });
}




- (void)observerContext:(CaptureContextType)type Changed:(BOOL)boolValue {
    switch(type){
        case CaptureContextTypeRunningAndDeviceAuthorized:{
            if (boolValue){
                self.isLockTap=NO;
            }
            else{
                self.isLockTap=YES;
            }
        }
            break;
        case CaptureContextTypeCameraFrontOrBackToggle:{
            if (boolValue){
                self.isLockTap=NO;
            }
            else{
                self.isLockTap=YES;
            }
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)verifyFaceFailedType{
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    switch (viewModel.faceType) {
        case PSFaceMeeting:{
            [self meetingMentVerifyFaceFailed];
        }
            break;
        case PSFaceAppointment:{
            [self appointmentVerifyFaceFailed];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 判断人脸识别类型
-(void)JudgeFaceRecognitionType{
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    switch (viewModel.faceType) {
        case PSFaceMeeting:{
            [self meetingFace];
        }
            break;
        case PSFaceAppointment:{
            [self appointmentFace];
        }
            break;
            
        default:
            break;
    }
    
}
-(void)meetingFace{
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    if (viewModel.familymeetingID.length==0) {
        [self renderContents];
        [self registerFaceGid];
    } else {
        [viewModel requestFamilyMembersCompleted:^(PSResponse *response) {
            if (response.code==200) {
                [self registerFaceGid];
                [self renderContents];
            }
            else{
                [PSTipsView showTips:response.msg?response.msg:@"获取会见列表失败"];
            }
        } failed:^(NSError *error) {
            // [[PSLoadingView sharedInstance] dismiss];
            [self showNetError:error];
        }];
    }
}
-(void)appointmentFace{
    [self renderContents];
    [self registerFaceGid];
}


- (void)renderContents {
    CGFloat sidePadding = 15;
    CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(25);
    _FaceRecognitionLab=[[UILabel alloc]init];
    [self.view addSubview:_FaceRecognitionLab];
    _FaceRecognitionLab.text=@"人脸检测中";
    _FaceRecognitionLab.font=AppBaseTextFont1;
    _FaceRecognitionLab.textColor=AppBaseTextColor3;
    _FaceRecognitionLab.textAlignment=NSTextAlignmentCenter;
    [_FaceRecognitionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);//15
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(sidePadding);
    }];
    
    //初始化 CaptureSessionManager
    self.captureManager = [[CaptureManager alloc] init];
    self.captureManager.delegate = self;
   
    self.previewLayer = self.captureManager.previewLayer;
    self.captureManager.previewLayer.frame =CGRectMake(30, 45, SCREEN_WIDTH-60, SCREEN_WIDTH-60);
    //self.captureManager.previewLayer.position = self.view.center;
    self.captureManager.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.captureManager.previewLayer];
    [self.captureManager setup];
    [self.captureManager addObserver];
    [self.faceDetector setParameter:@"1" forKey:@"detect"];
    [self.faceDetector setParameter:@"1" forKey:@"align"];
 
    self.viewCanvas = [[CanvasView alloc] initWithFrame:self.captureManager.previewLayer.frame] ;
    [self.view addSubview:self.viewCanvas] ;
    self.viewCanvas.center=self.captureManager.previewLayer.position;
    self.viewCanvas.backgroundColor = [UIColor clearColor] ;
    
    
     PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    
    UIImageView*leftTopImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scanning_left_top"]];
    [self.view addSubview:leftTopImageView];
    leftTopImageView.frame=CGRectMake(20, 40, 10, 10);
    
    UIImageView*leftBoomImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scanning_left_bottom"]];
    [self.view addSubview:leftBoomImageView];
    leftBoomImageView.frame=CGRectMake(20, 40+SCREEN_WIDTH-2*verticalPadding, 10, 10);
    
    UIImageView*rightTopImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scanning_right_top"]];
    [self.view addSubview:rightTopImageView];
    rightTopImageView.frame=CGRectMake(20+SCREEN_WIDTH-2*verticalPadding, 40, 10, 10);
    
    UIImageView*rightBoomImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scanning_right_bottom"]];
    [self.view addSubview:rightBoomImageView];
    rightBoomImageView.frame=CGRectMake(20+SCREEN_WIDTH-2*verticalPadding, 40+SCREEN_WIDTH-2*verticalPadding, 10, 10);
    

    
    _statusTipsLable=[UILabel new];
    [self.view addSubview:_statusTipsLable];
    _statusTipsLable.textAlignment=NSTextAlignmentCenter;
    _statusTipsLable.font=FontOfSize(13);
    _statusTipsLable.textColor=AppBaseTextColor1;
    [_statusTipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.viewCanvas.mas_bottom).offset(5);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
        make.height.mas_equalTo(18);
        make.left.mas_equalTo(sidePadding);
    }];
    PSPrisonerFamily*familyModel=viewModel.FamilyMembers[0];
    _statusTipsLable.text=NSStringFormat(@"[%@]",familyModel.familyName);
    
    
    
    UIView*faceBgView=[UIView new];
    [self.view addSubview:faceBgView];
    [faceBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_statusTipsLable.mas_bottom).offset(sidePadding);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
        make.height.mas_equalTo(SCREEN_HEIGHT/2+sidePadding);
        make.left.mas_equalTo(sidePadding);
    }];
    UILabel*titleLab=[[UILabel alloc]init];
    NSString*face_familes=NSLocalizedString(@"face_familes", @"本次会见家属");
    titleLab.text=face_familes;
    titleLab.textColor=AppBaseTextColor1;
    titleLab.font=AppBaseTextFont1;
    [faceBgView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(faceBgView.mas_top).offset(5);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
        make.height.mas_equalTo(18);
        make.left.mas_equalTo(faceBgView.mas_left);
    }];
    
    UILabel*contentLable=[[UILabel alloc]init];
    NSString*face_familes_tips=NSLocalizedString(@"face_familes_tips", nil);
    contentLable.text=face_familes_tips;
    //@"*本次会见必须全部通过人脸识别；\n 请依次选择亲属进行人脸识别。";
    contentLable.numberOfLines=0;
    contentLable.font=AppBaseTextFont2;
    contentLable.textColor=AppBaseTextColor2;
    [faceBgView addSubview:contentLable];
    [contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLab.mas_bottom).offset(5);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(faceBgView.mas_left);
    }];
   
    NSLog(@"%lu",(unsigned long)viewModel.FamilyMembers.count);
    if (viewModel.FamilyMembers.count==1) {
        UIImage*images=[UIImage imageNamed:@"meetingAuthIcon"];
        UIImageView*FamliesOneButton=[[UIImageView alloc]init];
        PSPrisonerFamily*modelOne=viewModel.FamilyMembers[0];
        [self setimage:FamliesOneButton imageUrl:PICURL(modelOne.familyAvatarUrl) placeholderImage:images];
        [faceBgView addSubview:FamliesOneButton];
        [FamliesOneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        _FamliesOneLab=[UILabel new];
        [faceBgView addSubview:_FamliesOneLab];
        _FamliesOneLab.textAlignment=NSTextAlignmentCenter;
        _FamliesOneLab.font=FontOfSize(12);
        _FamliesOneLab.textColor=AppBaseTextColor1;
        [_FamliesOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesOneButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
         _FamliesOneLab.text=@"人脸检测中";
    }
    else if (viewModel.FamilyMembers.count==2){
        PSPrisonerFamily*modelOne=viewModel.FamilyMembers[0];
        CGFloat iconSidePadding = (SCREEN_WIDTH-2*sidePadding-240)/2;
        UIImage*images=[UIImage imageNamed:@"meetingAuthIcon"];
        UIImageView*FamliesOneButton=[[UIImageView alloc]init];
  
        
        [faceBgView addSubview:FamliesOneButton];
        [FamliesOneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        _FamliesOneLab=[UILabel new];
        [faceBgView addSubview:_FamliesOneLab];
        _FamliesOneLab.textAlignment=NSTextAlignmentCenter;
        _FamliesOneLab.font=FontOfSize(12);
        _FamliesOneLab.textColor=AppBaseTextColor1;
        [_FamliesOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesOneButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
         _FamliesOneLab.text=@"人脸检测中";
        
        
        PSPrisonerFamily*modelTwo=viewModel.FamilyMembers[1];
        UIImageView*FamliesTwoButton=[[UIImageView alloc]init];
        [self setimage:FamliesOneButton imageUrl:PICURL(modelOne.familyAvatarUrl) placeholderImage:images];
        [self setimage:FamliesTwoButton imageUrl:PICURL(modelTwo.familyAvatarUrl) placeholderImage:images];
        
        [faceBgView addSubview:FamliesOneButton];
        [faceBgView addSubview:FamliesTwoButton];
        [FamliesTwoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(FamliesOneButton.mas_right).offset(iconSidePadding);
        }];
        UILabel*FamliesTwoLab=[UILabel new];
        [faceBgView addSubview:FamliesTwoLab];
        FamliesTwoLab.text=modelTwo.familyName;
        FamliesTwoLab.font=FontOfSize(12);
        FamliesTwoLab.textColor=AppBaseTextColor1;
        FamliesTwoLab.textAlignment=NSTextAlignmentCenter;
        [FamliesTwoLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesTwoButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(FamliesOneButton.mas_right).offset(iconSidePadding);
        }];
    }
    else if (viewModel.FamilyMembers.count==3){
        PSPrisonerFamily*modelOne=viewModel.FamilyMembers[0];
        CGFloat iconSidePadding = (SCREEN_WIDTH-2*sidePadding-240)/2;
        UIImage*images=[UIImage imageNamed:@"meetingAuthIcon"];
        UIImageView*FamliesOneButton=[[UIImageView alloc]init];

       
        [faceBgView addSubview:FamliesOneButton];
        [FamliesOneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        _FamliesOneLab=[UILabel new];
        [faceBgView addSubview:_FamliesOneLab];
        _FamliesOneLab.textAlignment=NSTextAlignmentCenter;
        _FamliesOneLab.font=FontOfSize(12);
        _FamliesOneLab.textColor=AppBaseTextColor1;
        [_FamliesOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesOneButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        _FamliesOneLab.text=@"人脸检测中";
        
        PSPrisonerFamily*modelTwo=viewModel.FamilyMembers[1];
        UIImageView*FamliesTwoButton=[[UIImageView alloc]init];
        
        [faceBgView addSubview:FamliesOneButton];
        [faceBgView addSubview:FamliesTwoButton];
        [FamliesTwoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(FamliesOneButton.mas_right).offset(iconSidePadding);
        }];
        UILabel*FamliesTwoLab=[UILabel new];
        [faceBgView addSubview:FamliesTwoLab];
        FamliesTwoLab.text=modelTwo.familyName;
        FamliesTwoLab.font=FontOfSize(12);
        FamliesTwoLab.textColor=AppBaseTextColor1;
        FamliesTwoLab.textAlignment=NSTextAlignmentCenter;
        [FamliesTwoLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesTwoButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(FamliesOneButton.mas_right).offset(iconSidePadding);
        }];
        
        PSPrisonerFamily*modelThress=viewModel.FamilyMembers[2];
        UIImageView*FamliesThreeButton=[[UIImageView alloc]init];
        [faceBgView addSubview:FamliesThreeButton];
        [FamliesThreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(FamliesTwoButton.mas_right).offset(iconSidePadding);
        }];
        
        [self setimage:FamliesOneButton imageUrl:PICURL(modelOne.familyAvatarUrl) placeholderImage:images];
        [self setimage:FamliesTwoButton imageUrl:PICURL(modelTwo.familyAvatarUrl) placeholderImage:images];
        [self setimage:FamliesThreeButton imageUrl:PICURL(modelThress.familyAvatarUrl) placeholderImage:images];
        
        UILabel*FamliesThreeLab=[UILabel new];
        [faceBgView addSubview:FamliesThreeLab];
        FamliesThreeLab.text=modelThress.familyName;
        FamliesThreeLab.font=FontOfSize(12);
        FamliesThreeLab.textColor=AppBaseTextColor1;
        FamliesThreeLab.textAlignment=NSTextAlignmentCenter;
        [FamliesThreeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesThreeButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(FamliesTwoButton.mas_right).offset(iconSidePadding);
        }];
    }
    else {
        UIImage*images=[UIImage imageNamed:@"meetingAuthIcon"];
        UIImageView*FamliesOneButton=[[UIImageView alloc]init];
        [FamliesOneButton sd_setImageWithURL:[NSURL URLWithString:PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)] placeholderImage:images];
        [faceBgView addSubview:FamliesOneButton];
        [FamliesOneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        UILabel*FamliesOneLab=[UILabel new];
        [faceBgView addSubview:FamliesOneLab];
        NSString*me=NSLocalizedString(@"me", @"我");
        FamliesOneLab.text=me;
        FamliesOneLab.textAlignment=NSTextAlignmentCenter;
        FamliesOneLab.font=AppBaseTextFont1;
        FamliesOneLab.textColor=AppBaseTextColor1;
        [FamliesOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesOneButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
    }
    
}


//加载图片
-(void)setimage:(UIImageView *)imageView imageUrl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage {
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeholderImage  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                UIImage *LoadImage = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (LoadImage) {
                        imageView.image = LoadImage;
                        //注册....
                    } else {
                        NSLog(@"%@",@"图片下载失败");
                    }
                });
            });
        }
    }];
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
