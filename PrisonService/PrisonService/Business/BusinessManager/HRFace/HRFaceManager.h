//
//  HRFaceManager.h
//  PrisonService
//
//  Created by kky on 2019/12/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcSoftFaceEngine/ArcSoftFaceEngine.h>
typedef NS_ENUM(NSInteger, PSHRFaceBackResultType) {
    PSFaceBackSDKRegistFail,         //SDK激活注册失败
    PSFaceBackSDKInitFail,           //SDK初始化失败
    PSFaceBackSDKInitSuccess,        //SDK初始化成功
    PSFaceBackSDKcheckImageSuccess,  //SDK提取图片信息成功
    PSFaceBackSDKcheckImageFail,     //SDK提取图片信息失败
    PSFaceBackSDKcheckImageNoFace,   //SDK提取图片没有识别到人脸
};

NS_ASSUME_NONNULL_BEGIN
typedef void (^HRSDKblock)(PSHRFaceBackResultType result);
typedef void (^HRSDKCheckBlock)(LPASF_FaceFeature faceFacture);
@interface HRFaceManager : NSObject

+ (HRFaceManager *)sharedInstance;
//注册虹软SDK
-(void)registHRSDK:(HRSDKblock)block;

#pragma mark ---------- 从图片检测人脸&&提取信息
-(void)hrsdkCheckFace:(UIImage*)faceimage sdkblock:(HRSDKblock)sdkblock checkBlock:(HRSDKCheckBlock)checkBlock;

@end

NS_ASSUME_NONNULL_END
