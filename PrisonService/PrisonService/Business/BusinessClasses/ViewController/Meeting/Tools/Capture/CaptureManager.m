//
//  CaptureManager.m
//  IFlyFaceDemo
//
//  Created by 张剑 on 15/7/10.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "CaptureManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <OpenGLES/EAGL.h>
#import <Endian.h>
#import "UIImage+Extensions.h"
#import "PermissionDetector.h"
#import "IFlyFaceImage.h"

//custom Context
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


@interface CaptureManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@end


@implementation CaptureManager

@synthesize session;
@synthesize previewLayer;

#pragma mark - Capture Session Configuration

- (id)init {
    if ((self = [super init])) {
        self.session=[[AVCaptureSession alloc] init];
        self.lockInterfaceRotation=NO;
        self.previewLayer=[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    }
    return self;
}

- (void)dealloc {
    [self teardown];
}

#pragma mark -
- (void)setup{
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    
    // 这里使用CoreMotion来获取设备方向以兼容iOS7.0设备
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 if (!error) {
                                                     [self updateAccelertionData:accelerometerData.acceleration];
                                                 }
                                                 else{
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    // session
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        [self.session beginConfiguration];
        
        if([session canSetSessionPreset:AVCaptureSessionPreset640x480]){
            [session setSessionPreset:AVCaptureSessionPreset640x480];
        }
        
        NSError *error = nil;
        AVCaptureDevice *videoDevice = [CaptureManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        
        //input device
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (error){
            NSLog(@"%@", error);
        }
        if ([session canAddInput:videoDeviceInput]){
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        
        /*
         //初始化设备输出对象，用于获得输出数据
         AVCaptureStillImageOutput *stillImageOutput=[[AVCaptureStillImageOutput alloc]init];
         NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
         [stillImageOutput setOutputSettings:outputSettings];//输出设置
         //将设备输出添加到会话中
         if ([session canAddOutput:stillImageOutput]) {
         [session addOutput:stillImageOutput];
         }
         */
        
        //output device
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        if ([session canAddOutput:videoDataOutput]){
            [session addOutput:videoDataOutput];
            AVCaptureConnection *connection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]){
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            }
            
            if ([connection isVideoOrientationSupported]){
                connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            }
            
            
            // Configure your output.
            
            self.videoDataOutputQueue = dispatch_queue_create("videoDataOutput", NULL);
            [videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
            // Specify the pixel format
            
            //获取灰度图像数据
            videoDataOutput.videoSettings =[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]forKey:(id)kCVPixelBufferPixelFormatTypeKey];
            [self setVideoDataOutput:videoDataOutput];
        }
        
        [self.session commitConfiguration];
        
    });
    
}

- (void)teardown{
    [self.session stopRunning];
    self.videoDeviceInput=nil;
    self.videoDataOutput=nil;
    self.videoDataOutputQueue=nil;
    self.sessionQueue=nil;
    [self.previewLayer removeFromSuperlayer];
    self.session=nil;
    self.previewLayer=nil;
    
    [self.motionManager stopAccelerometerUpdates];
    self.motionManager=nil;
}

- (void)addObserver{
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        
        __weak CaptureManager *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:self.session queue:nil usingBlock:^(NSNotification *note) {
            CaptureManager *strongSelf = weakSelf;
            dispatch_async(strongSelf.sessionQueue, ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [strongSelf.session startRunning];
            });
        }]];
        [self.session startRunning];
    });
}

- (void)removeObserver{
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
    });
}

#pragma mark -
-(BOOL)isSessionRunningAndDeviceAuthorized{
    return [self.session isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context == SessionRunningAndDeviceAuthorizedContext){
        BOOL boolValue = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            CaptureContextType type=CaptureContextTypeRunningAndDeviceAuthorized;
            if(self.delegate && [self.delegate respondsToSelector:@selector(observerContext:Changed:)]){
                [self.delegate observerContext:type Changed:boolValue];
            }
        });
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    UIImage *result = [[UIImage alloc] initWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    CGImageRelease(videoImage);
    return result;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// Create a IFlyFaceImage from sample buffer data

- (IFlyFaceImage *) faceImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    
    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *lumaBuffer  = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
    size_t width  = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context=CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace,0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    IFlyFaceDirectionType faceOrientation=[self faceImageOrientation];
    
    IFlyFaceImage* faceImage=[[IFlyFaceImage alloc] init];
    if(!faceImage){
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    
    faceImage.data= (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width=width;
    faceImage.height=height;
    faceImage.direction=faceOrientation;
    faceImage.image = [self fixOrientation:[self imageFromSampleBuffer:sampleBuffer]];
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    return faceImage;
}

+ (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    NSLog(@"Warning - Didn't recognise interface orientation (%ld)",(long)orientation);
    return AVCaptureVideoOrientationPortrait;
}

#pragma mark - Actions

- (IBAction)cameraToggle{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CaptureContextType type=CaptureContextTypeCameraFrontOrBackToggle;
        if(self.delegate && [self.delegate respondsToSelector:@selector(observerContext:Changed:)]){
            [self.delegate observerContext:type Changed:NO];
        }
    });
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition){
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [CaptureManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        
        [self.session beginConfiguration];
        
        [self.session removeInput:self.videoDeviceInput];
        if ([self.session canAddInput:videoDeviceInput]){
            [self.session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else{
            [self.session addInput:self.videoDeviceInput];
        }
        
        if([self.session canSetSessionPreset:AVAssetExportPreset640x480]){
            [self.session setSessionPreset:AVAssetExportPreset640x480];
        }
        
        [self.session commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CaptureContextType type=CaptureContextTypeCameraFrontOrBackToggle;
            if(self.delegate && [self.delegate respondsToSelector:@selector(observerContext:Changed:)]){
                [self.delegate observerContext:type Changed:YES];
            }
        });
    });
}

#pragma mark - VideoData OutputSampleBuffer Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onOutputFaceImage:)]){
        IFlyFaceImage* faceImage=[self faceImageFromSampleBuffer:sampleBuffer];
        [self.delegate onOutputFaceImage:faceImage];
        faceImage=nil;
    }
}

#pragma mark - Device Configuration

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position{
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices){
        if ([device position] == position){
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - UI

-(void)showAlert:(NSString*)info{
    NSString*Tips=NSLocalizedString(@"Tips", @"提示");
     NSString*determine=NSLocalizedString(@"determine", @"确定");
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:Tips message:info delegate:self cancelButtonTitle:determine otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

- (void)checkDeviceAuthorizationStatus{
    
    if([PermissionDetector isCapturePermissionGranted]){
        [self setDeviceAuthorized:YES];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            NSString* info= NSLocalizedString(@"No camera permissions", @"没有相机权限");
//            [self showAlert:info];
//            [self setDeviceAuthorized:NO];
        
            [PSAuthorizationTool showAuthTitle:@"开启相机权限" message:@"请开启相机权限,开启后即可正常使用该功能" btnTitle:@"去设置"];
            
        });
    }
}


#pragma mark - tool

- (void)updateAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == self.interfaceOrientation)
        return;
    
    self.interfaceOrientation = orientationNew;
}

-(IFlyFaceDirectionType)faceImageOrientation{
    
    IFlyFaceDirectionType faceOrientation=IFlyFaceDirectionTypeLeft;
    BOOL isFrontCamera=self.videoDeviceInput.device.position==AVCaptureDevicePositionFront;
    switch (self.interfaceOrientation) {
        case UIDeviceOrientationPortrait:{//
            faceOrientation=IFlyFaceDirectionTypeLeft;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            faceOrientation=IFlyFaceDirectionTypeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeUp:IFlyFaceDirectionTypeDown;
        }
            break;
        default:{//
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeDown:IFlyFaceDirectionTypeUp;
        }
            
            break;
    }
    
    return faceOrientation;
}

@end
