//
//  ASFVideoProcessor.h
//

#import <Foundation/Foundation.h>
#import <ArcSoftFaceEngine/ArcSoftFaceEngineDefine.h>
#import "Utility.h"

@class ASFRPerson;
@protocol ASFVideoProcessorDelegate <NSObject>


/**
 
 @param personName 识别到匹配的人
 @param personAry  摄像头的人
@param allmachAry  识别到匹配人的集合
 */
- (void)processRecognized:(NSString*)personName
                personAry:(NSMutableArray *)personAry
               allmachAry:(NSMutableArray *)allmachAry;

@end

@interface ASFFace3DAngle : NSObject
@property(nonatomic,assign) MFloat rollAngle;
@property(nonatomic,assign) MFloat yawAngle;
@property(nonatomic,assign) MFloat pitchAngle;
@property(nonatomic,assign) MInt32 status;
@end

@interface ASFVideoFaceInfo : NSObject
@property(nonatomic,assign) MRECT faceRect;
@property(nonatomic,assign) MInt32 age;
@property(nonatomic,assign) MInt32 gender;
@property(nonatomic,strong) ASFFace3DAngle *face3DAngle;
@end

@interface ASFVideoProcessor : NSObject

@property(nonatomic, assign) BOOL detectFaceUseFD;
@property(nonatomic, weak) id<ASFVideoProcessorDelegate> delegate;

- (void)initProcessor;
- (void)uninitProcessor;
- (NSArray*)process:(ASF_CAMERA_DATA*)offscreen;
- (BOOL)registerDetectedPerson:(NSString*)personName;
- (BOOL)image_registerDetectedPerson:(ASFRPerson *)registerPerson;

@end
