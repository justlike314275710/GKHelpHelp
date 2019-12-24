//
//  HRFaceManager.m
//  PrisonService
//
//  Created by kky on 2019/12/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "HRFaceManager.h"
#import "ColorFormatUtil.h"
#import "Utility.h"
#import "ASFRManager.h"
#import "GLKitView.h"

#define HRAPPID   @"2rmJSJjww8kpvNwmHjbkZfPo1UxxgPRe6EyeZWMZxwnT"
#define HRSDKKEY  @"FSCYeDdXi2yH97asM7z267TzxpwYiB97PqowKrYJ8gSe"

@interface HRFaceManager ()
@property (nonatomic, strong)ArcSoftFaceEngine *engine; //人脸识别引擎

@end

@implementation HRFaceManager

+ (HRFaceManager *)sharedInstance {
    static HRFaceManager *manager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

//MARK:注册人脸虹软SDK
#pragma mark ---------- 激活虹软人脸识别SDK
-(void)registHRSDK:(HRSDKblock)block{
    
    if (TARGET_IPHONE_SIMULATOR) {
       
    }else{
        _engine = [[ArcSoftFaceEngine alloc] init];
        MRESULT mr = [_engine activeWithAppId:HRAPPID SDKKey:HRSDKKEY];
        if (mr == ASF_MOK) {
            NSLog(@"SDK激活成功");
            [self initHRSDK:block];
        } else if(mr == MERR_ASF_ALREADY_ACTIVATED){
            NSLog(@"SDK已激活");
            [self initHRSDK:block];
        } else {
            NSLog(@"SDK激活失败");
            if (block) block(PSFaceBackSDKRegistFail);
        }
    }
}

#pragma mark ---------- 虹软引擎初始化
-(void)initHRSDK:(HRSDKblock)block; {
    MRESULT mr = [_engine initFaceEngineWithDetectMode:ASF_DETECT_MODE_IMAGE
                                        orientPriority:ASF_OP_0_HIGHER_EXT
                                                 scale:16
                                            maxFaceNum:10
                                          combinedMask:ASF_FACE_DETECT | ASF_FACERECOGNITION | ASF_AGE | ASF_GENDER | ASF_FACE3DANGLE];
       //初始化成功
    if (mr == ASF_MOK) {
        if (block) block(PSFaceBackSDKInitSuccess);
    } else {
        //始化初始化失败
        if (block) block(PSFaceBackSDKInitFail);
    }
}
#pragma mark ---------- 从图片检测人脸提取信息
-(void)hrsdkCheckFace:(UIImage*)faceimage sdkblock:(HRSDKblock)sdkblock checkBlock:(HRSDKCheckBlock)checkBlock{
    //对图片宽高进行对齐处理
    UIImage *_selectImage = faceimage;
    int imageWidth = _selectImage.size.width;
    int imageHeight = _selectImage.size.width;
    if (imageWidth % 4 != 0) {
        imageWidth = imageWidth - (imageWidth % 4);
    }
    if (imageHeight % 2 != 0) {
        imageHeight = imageHeight - (imageHeight % 2);
    }
    CGRect rect = CGRectMake(0, 0, imageWidth, imageHeight);
    _selectImage = [Utility clipWithImageRect:rect clipImage:_selectImage];
    unsigned char* pRGBA = [ColorFormatUtil bitmapFromImage:_selectImage];
    MInt32 dataWidth = _selectImage.size.width;
    MInt32 dataHeight = _selectImage.size.height;
    MUInt32 format = ASVL_PAF_NV12;
    MInt32 pitch0 = dataWidth;
    MInt32 pitch1 = dataWidth;
    MUInt8* plane0 = (MUInt8*)malloc(dataHeight * dataWidth * 3/2);
    MUInt8* plane1 = plane0 + dataWidth * dataHeight;
    unsigned char* pBGR = (unsigned char*)malloc(dataHeight * LINE_BYTES(dataWidth, 24));
    RGBA8888ToBGR(pRGBA, dataWidth, dataHeight, dataWidth * 4, pBGR);
    BGRToNV12(pBGR, dataWidth, dataHeight, plane0, pitch0, plane1, pitch1);
    
    ASF_MultiFaceInfo* fdResult = (ASF_MultiFaceInfo*)malloc(sizeof(ASF_MultiFaceInfo));
    fdResult->faceRect = (MRECT*)malloc(sizeof(fdResult->faceRect));
    fdResult->faceOrient = (MInt32*)malloc(sizeof(fdResult->faceOrient));
    //FD  //人脸检测
    MRESULT mr = [_engine detectFacesWithWidth:dataWidth
                                        height:dataHeight
                                          data:plane0
                                        format:format
                                       faceRes:fdResult];
    
    NSString* fdResultStr = @"";
    if (mr == ASF_MOK) {
        if (fdResult->faceNum == 0) {
            fdResultStr = @"未检测到人脸";
            //没检测到人脸
            if (sdkblock) sdkblock(PSFaceBackSDKcheckImageNoFace);
            return;
        } else {
            fdResultStr = [NSString stringWithFormat:@"detectFaces检测成功,人脸框：rect[%d,%d,%d,%d]",
                           fdResult->faceRect->left, fdResult->faceRect->top,
                           fdResult->faceRect->right, fdResult->faceRect->bottom];
            if (sdkblock) sdkblock(PSFaceBackSDKcheckImageSuccess);
        }
    } else {
        fdResultStr = [NSString stringWithFormat:@"detectFaces检测失败：%ld，请重新选择", mr];
        if (sdkblock) sdkblock(PSFaceBackSDKcheckImageFail);
        return;
    }
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGSize targetSize = CGSizeMake(_selectImage.size.width, _selectImage.size.height);
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, targetSize.width, targetSize.height,
                                                       8, targetSize.width * 4, rgb,
                                                       kCGImageAlphaPremultipliedFirst);
    CGRect imageRect;
    imageRect.origin = CGPointMake(0, 0);
    imageRect.size = targetSize;
    CGContextDrawImage(bitmapContext, imageRect, _selectImage.CGImage);
    for (int i = 0; i < fdResult->faceNum; i ++) {
        MRECT rect = fdResult->faceRect[i];
        CGRect cgRect = CGRectMake(rect.left, targetSize.height - rect.bottom, rect.right - rect.left, rect.bottom - rect.top);
        CGContextAddRect(bitmapContext, cgRect);
    }
    CGContextSetRGBStrokeColor(bitmapContext, 255, 0, 0, 1);
    CGContextSetLineWidth(bitmapContext, 4.0);
    CGContextStrokePath(bitmapContext);
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage * image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(rgb);
    //人脸信息分析
    if (mr == ASF_MOK) {
        NSTimeInterval begin = [[NSDate date] timeIntervalSince1970];
        mr = [_engine processWithWidth:dataWidth
                                height:dataHeight
                                  data:plane0
                                format:format
                               faceRes:fdResult
                                  mask:ASF_AGE | ASF_GENDER | ASF_FACE3DANGLE];
        NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - begin;
        NSLog(@"processTime=%d", (int)(cost * 1000));
        NSLog(@"process:%ld", mr);
        if (mr == ASF_MOK) {
            //age
            ASF_AgeInfo ageInfo = {0};
            mr = [_engine getAge:&ageInfo];
            if (mr == ASF_MOK) {
                NSLog(@"age:%d", (int)ageInfo.ageArray[0]);
            }
            
            //gender
            ASF_GenderInfo genderInfo = {0};
            mr = [_engine getGender:&genderInfo];
            if (mr == ASF_MOK) {
                NSString *strGender = [NSString stringWithFormat:@"性别为：%@", genderInfo.genderArray[0] == 1 ? @"女" : @"男"];
                NSLog(@"gender:%d", (int)ageInfo.ageArray[0]);
            }
            //3DAngle
            ASF_Face3DAngle angleInfo = {0};
            mr = [_engine getFace3DAngle:&angleInfo];
            if (mr == ASF_MOK) {
                NSString *strAngle = [NSString stringWithFormat:@"3DAngle:[yaw:%f,roll:%f,pitch:%f]", angleInfo.yaw[0], angleInfo.roll[0], angleInfo.pitch[0]];
            }
            //FR
            ASF_SingleFaceInfo frInputFace = {0};
            frInputFace.rcFace.left = fdResult->faceRect[0].left;
            frInputFace.rcFace.top = fdResult->faceRect[0].top;
            frInputFace.rcFace.right = fdResult->faceRect[0].right;
            frInputFace.rcFace.bottom = fdResult->faceRect[0].bottom;
            frInputFace.orient = fdResult->faceOrient[0];
            ASF_FaceFeature feature1 = {0};
            NSTimeInterval begin = [[NSDate date] timeIntervalSince1970];
            //人脸特征提取
            mr = [_engine extractFaceFeatureWithWidth:dataWidth
                                               height:dataHeight
                                                 data:plane0
                                               format:format
                                             faceInfo:&frInputFace
                                              feature:&feature1];
            NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - begin;
            if (mr == ASF_MOK) {
                NSString *strFR1 = [NSString stringWithFormat:@"人脸特征长度为:%d", feature1.featureSize];
            }
            if (mr==ASF_MOK) {
                LPASF_FaceFeature copyFeature1 = (LPASF_FaceFeature)malloc(sizeof(ASF_FaceFeature));
                copyFeature1->featureSize = feature1.featureSize;
                copyFeature1->feature = (MByte*)malloc(feature1.featureSize);
                memcpy(copyFeature1->feature, feature1.feature, copyFeature1->featureSize);
//                _faceFacture = copyFeature1;
                //注册人脸
//                BOOL result1 = [self registerPersonImage:image personName:name];
                    if (checkBlock) {
                        checkBlock(copyFeature1);
                    }
                    
//                if (result1) {
//                    NSLog(@"注册成功");
//                } else {
//                    NSLog(@"注册失败");
//                }
            }
        }
    }
    SafeArrayFree(pBGR);
    SafeArrayFree(pRGBA);
}

@end
