//
//  PSFaceAuthViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

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

@end


@implementation PSFaceAuthViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.i=0;
        //self.gid=nil;
        NSString*meet_face=NSLocalizedString(@"meet_face", @"会见人脸识别");
        self.title=meet_face;
        self.faceDetector = [IFlyFaceDetector sharedInstance];
        self.faceRequest = [IFlyFaceRequest sharedInstance];
        [self.faceRequest setDelegate:self];
        
        [self requestFamilesMeeting];
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

- (void)verifyFaceFailed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:VerifyFaceFailed preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.times = 0;
        if (self.isVerifying) {
            self.isVerifying = NO;
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.completion) {
            self.completion(NO);
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
    if(viewModel.familymeetingID.length!=0){
        @weakify(self)
        PSPrisonerFamily*model=viewModel.FamilyMembers[_i];
        NSString*avatarUrl=model.familyAvatarUrl;
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:PICURL(avatarUrl)] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            @strongify(self)
            if (error) {
                [self registerFaceFailed];
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
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:PICURL([PSSessionManager sharedInstance].session.families.avatarUrl)] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            //@strongify(self)
            if (error) {
                [self registerFaceFailed];
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
            if([ret integerValue] == 0){
                if([rst isEqualToString:KCIFlyFaceResultSuccess]){
                    NSString *verf = [dic objectForKey:KCIFlyFaceResultVerf];
                    if([verf boolValue]){
                         NSString*face_success=NSLocalizedString(@"face_success", @"人脸识别成功");
                        [SDTrackTool logEvent:FACE_RECOGNITION attributes:@{STATUS:MobSUCCESS}];
                        
                         _statusTipsLable.text=face_success;
                        //验证成功
                        PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
                        @weakify(self)
                        if (viewModel.FamilyMembers.count==1) {
                            @strongify(self)
                            if (self.completion) {
                                self.completion(YES);
                            }
                            return;
                        }
                        else if (viewModel.FamilyMembers.count==0){
                            @strongify(self)
                            if (self.completion) {
                                self.completion(YES);
                            }
                            return;
                        }
                        else {
                            PSFamilyFaceViewController *authViewController = [[PSFamilyFaceViewController alloc] initWithViewModel:viewModel];
                            [authViewController setCompletion:^(BOOL successful) {
                                @strongify(self)
                                if (successful) {
                                    if (self.completion) {
                                        self.completion(YES);
                                    }
                                    return;
                                }
                            }];
                            [[PSMeetingManager sharedInstance].meetingNavigationController pushViewController:authViewController animated:NO];
                        }

                   }
                    else{
                      @weakify(self)
                        [WXZTipView showBottomWithText:@"人脸识别失败" duration:1.0f];
                        [SDTrackTool logEvent:FACE_RECOGNITION attributes:@{STATUS:MobFAILURE}];
                        @strongify(self)
                        if (self.completion) {
                            self.completion(NO);
                        }
                        return;
                    }
                }
            }

            if (self.isVerifying) {
                self.isVerifying = NO;
            }
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
             NSString*no_face=NSLocalizedString(@"no_face", @"未检测到人脸");
            _statusTipsLable.text=no_face;
            //[WXZTipView showBottomWithText:@"未监测到人脸,请调整摄像头" duration:2.0f];
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



-(void)dealloc{
    self.captureManager=nil;
    self.viewCanvas=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   self.faceDetector = [IFlyFaceDetector sharedInstance];
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
     PSLog(@"---%@",strResult);
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
#pragma mark -- 网络请求
-(void)requestFamilesMeeting{
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    if (viewModel.familymeetingID.length==0) {
        [self renderContents];
        [self registerFaceGid];
    } else {
        [viewModel requestFamilyMembersCompleted:^(PSResponse *response) {
            // [[PSLoadingView sharedInstance] dismiss];
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


- (void)renderContents {
    CGFloat sidePadding = 15;
    CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(25);
    PSMeetingViewModel *viewModel = (PSMeetingViewModel*)self.viewModel;
    
    _FaceRecognitionLab=[[UILabel alloc]init];
    [self.view addSubview:_FaceRecognitionLab];
    NSString*face_ing=NSLocalizedString(@"face_ing", @"[我]人脸识别中");
    _FaceRecognitionLab.text=face_ing;
    _FaceRecognitionLab.font=AppBaseTextFont1;
    _FaceRecognitionLab.textColor=AppBaseTextColor1;
    _FaceRecognitionLab.textAlignment=NSTextAlignmentCenter;
    [_FaceRecognitionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);//15
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
     NSString*face_ing_tips=NSLocalizedString(@"face_ing_tips", @"识别提示:正在识别中");
    _statusTipsLable.text=face_ing_tips;
    _statusTipsLable.font=AppBaseTextFont3;
    _statusTipsLable.textColor=AppBaseTextColor3;
    [_statusTipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.viewCanvas.mas_bottom).offset(5);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
        make.height.mas_equalTo(18);
        make.left.mas_equalTo(sidePadding);
    }];
    
    
    
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
    
    if (viewModel.FamilyMembers.count==1) {
        UIImage*images=[UIImage imageNamed:@"meetingAuthIcon"];
        UIImageView*FamliesOneButton=[[UIImageView alloc]init];
        PSPrisonerFamily*modelOne=viewModel.FamilyMembers[0];
        [FamliesOneButton sd_setImageWithURL:[NSURL URLWithString:PICURL(modelOne.familyAvatarUrl)] placeholderImage:images];
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
    else if (viewModel.FamilyMembers.count==2){
        PSPrisonerFamily*modelOne=viewModel.FamilyMembers[0];
        CGFloat iconSidePadding = (SCREEN_WIDTH-2*sidePadding-240)/2;
        UIImage*images=[UIImage imageNamed:@"meetingAuthIcon"];
        UIImageView*FamliesOneButton=[[UIImageView alloc]init];
        //[FamliesOneButton setImage:images forState:UIControlStateNormal];
        [FamliesOneButton sd_setImageWithURL:[NSURL URLWithString:PICURL(modelOne.familyAvatarUrl)] placeholderImage:images];
        [faceBgView addSubview:FamliesOneButton];
        [FamliesOneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        UILabel*FamliesOneLab=[UILabel new];
        [faceBgView addSubview:FamliesOneLab];
        FamliesOneLab.text=modelOne.familyName;
        FamliesOneLab.textAlignment=NSTextAlignmentCenter;
        FamliesOneLab.font=AppBaseTextFont1;
        FamliesOneLab.textColor=AppBaseTextColor1;
        [FamliesOneLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(FamliesOneButton.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(20);
            make.left.mas_equalTo(faceBgView.mas_left);
        }];
        
        
        PSPrisonerFamily*modelTwo=viewModel.FamilyMembers[1];
        UIImageView*FamliesTwoButton=[[UIImageView alloc]init];
        [FamliesTwoButton sd_setImageWithURL:[NSURL URLWithString:PICURL(modelTwo.familyAvatarUrl)] placeholderImage:images];
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
        FamliesTwoLab.font=AppBaseTextFont1;
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
        //[FamliesOneButton setImage:images forState:UIControlStateNormal];
        [FamliesOneButton sd_setImageWithURL:[NSURL URLWithString:PICURL(modelOne.familyAvatarUrl)] placeholderImage:images];
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
        
        PSPrisonerFamily*modelTwo=viewModel.FamilyMembers[1];
        UIImageView*FamliesTwoButton=[[UIImageView alloc]init];
        [FamliesTwoButton sd_setImageWithURL:[NSURL URLWithString:PICURL(modelTwo.familyAvatarUrl)] placeholderImage:images];
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
        FamliesTwoLab.font=AppBaseTextFont1;
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
        [FamliesThreeButton sd_setImageWithURL:[NSURL URLWithString:PICURL(modelThress.familyAvatarUrl)] placeholderImage:images];
        [faceBgView addSubview:FamliesThreeButton];
        [FamliesThreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentLable.mas_bottom).offset(5);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.left.mas_equalTo(FamliesTwoButton.mas_right).offset(iconSidePadding);
        }];
        UILabel*FamliesThreeLab=[UILabel new];
        [faceBgView addSubview:FamliesThreeLab];
        FamliesThreeLab.text=modelThress.familyName;
        FamliesThreeLab.font=AppBaseTextFont1;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
