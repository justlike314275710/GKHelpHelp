//
//  STAuthorizationTool.m
//  Start
//
//  Created by calvin on 17/2/17.
//  Copyright © 2017年 DingSNS. All rights reserved.
//

#import "PSAuthorizationTool.h"
#import <AVFoundation/AVFoundation.h>
#import "PSTipsView.h"
#import "UIAlertView+BlocksKit.h"
#import <Photos/Photos.h>
#import "UIViewController+Tool.h"
#import  <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"


@implementation PSAuthorizationTool

+ (void)checkAndRedirectAVAuthorizationWithBlock:(CheckAuthorizationBlock)block setBlock:(SetBlock)setblock isShow:(BOOL)isShow {
    __block BOOL videoResult = NO;
    __block BOOL audioResult = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        switch (videoAuthStatus) {
            case AVAuthorizationStatusNotDetermined:
                break;
            case AVAuthorizationStatusRestricted:
                break;
            case AVAuthorizationStatusDenied:
                break;
            case AVAuthorizationStatusAuthorized:
            {
                videoResult = YES;
            }
                break;
            default:
                break;
        }
        switch (audioAuthStatus) {
            case AVAuthorizationStatusNotDetermined:
                break;
            case AVAuthorizationStatusRestricted:
                break;
            case AVAuthorizationStatusDenied:
                break;
            case AVAuthorizationStatusAuthorized:
            {
                audioResult = YES;
            }
                break;
            default:
                break;
        }
        
        if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
            //没有询问相机开启权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                videoResult = granted;
                if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
                    //没有询问麦克风开启权限
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (granted) {
                                if (videoResult) {
                                    if (block) {
                                        block(granted && videoResult);
                                    }
                                }else {
                                    [self checkAndRedirectAVAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
                                }
                            }else {
                                [self checkAndRedirectAVAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
                            }
                        });
                    }];
                    return;
                }
            }];
            return;
        }else {
            if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
                //没有询问麦克风开启权限
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            if (videoResult) {
                                if (block) {
                                    block(granted && videoResult);
                                }
                            }else {
                                [self checkAndRedirectAVAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
                            }
                        }else {
                            [self checkAndRedirectAVAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
                        }
                    });
                }];
                return;
            }
        }
        
        NSString *title;
        NSString *message;
        if (!videoResult) {
            title = @"开启相机权限";
            message = @"请开启相机权限,开启后即可正常使用该功能";
        }
        if (!audioResult) {
            title = @"开启麦克风权限";
            message = @"请开启麦克风权限,开启后即可正常使用该功能";
        }
        if (!videoResult && !audioResult) {
            title = @"开启相机,麦克风权限";
            message = @"请开启相机和麦克风权限,开启后即可正常使用该功能";
        }
        if (!videoResult || !audioResult) {
            NSString *content = message;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
            if (isShow==YES) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            }
            [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *videoAuthURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:videoAuthURL]) {
                    [[UIApplication sharedApplication] openURL:videoAuthURL];
                }
                if (setblock) setblock();
                
            }]];
            UIViewController *VC = [UIViewController jsd_getCurrentViewController];
            [VC presentViewController:alertController animated:YES completion:nil];
        }
    }else {
        [PSTipsView showTips:NSLocalizedString(@"Current device has no camera function", @"当前设备无相机功能")];
    }
    if (block) {
        block(videoResult && audioResult);
    }
}
//相机
+ (void)checkAndRedirectCameraAuthorizationWithBlock:(CheckAuthorizationBlock)block setBlock:(SetBlock)setblock isShow:(BOOL)isShow {
    BOOL videoResult = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (videoAuthStatus) {
            case AVAuthorizationStatusNotDetermined:
                break;
            case AVAuthorizationStatusRestricted:
                break;
            case AVAuthorizationStatusDenied:
                break;
            case AVAuthorizationStatusAuthorized:
            {
                videoResult = YES;
            }
                break;
            default:
                break;
        }
        
        if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
            //没有询问相机开启权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self checkAndRedirectCameraAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
                });
            }];
            return;
        }
        
        NSString *title;
        NSString *message;
        if (!videoResult) {
            title = @"开启相机权限";
            message = @"请开启相机权限,开启后即可正常使用该功能";
            NSString *content = message;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
            if (isShow) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            }
            [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *videoAuthURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:videoAuthURL]) {
                    [[UIApplication sharedApplication] openURL:videoAuthURL];
                    if (setblock) setblock();
                        
                    
                }
            }]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }else {
        [PSTipsView showTips:NSLocalizedString(@"Current device has no camera function", @"当前设备无相机功能")];
    }
    if (block) {
        block(videoResult);
    }
}

+ (void)checkAndRedirectPhotoAuthorizationWithBlock:(CheckAuthorizationBlock)block setBlock:(SetBlock)setblock isShow:(BOOL)isShow {
    BOOL photoResult = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
        switch (photoAuthStatus) {
            case PHAuthorizationStatusNotDetermined:
                break;
            case PHAuthorizationStatusRestricted:
                break;
            case PHAuthorizationStatusDenied:
                break;
            case PHAuthorizationStatusAuthorized:
            {
                photoResult = YES;
            }
                break;
            default:
                break;
        }
        if (photoAuthStatus == AVAuthorizationStatusNotDetermined) {
            //没有询问相册开启权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self checkAndRedirectPhotoAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
                });
            }];
            return;
        }
        
        NSString *title;
        NSString *message;
        if (!photoResult) {
            title = @"开启相册权限";
            message = @"请开启相册权限,开启后即可正常使用该功能";
            NSString *content = message;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
            if (isShow) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            }
            [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *videoAuthURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:videoAuthURL]) {
                    [[UIApplication sharedApplication] openURL:videoAuthURL];
                }
                if (setblock) setblock();
            }]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }else {
        [PSTipsView showTips:@"当前设备无相册功能"];
    }
    if (block) {
        block(photoResult);
    }
}

+ (void)checkAndRedirectAudioAuthorizationWithBlock:(CheckAuthorizationBlock)block setBlock:(SetBlock)setblock isShow:(BOOL)isShow {
    BOOL videoResult = NO;
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (audioAuthStatus) {
        case AVAuthorizationStatusNotDetermined:
            break;
        case AVAuthorizationStatusRestricted:
            break;
        case AVAuthorizationStatusDenied:
            break;
        case AVAuthorizationStatusAuthorized:
        {
            videoResult = YES;
        }
            break;
        default:
            break;
    }
    
    if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
        //没有询问麦克风开启权限
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkAndRedirectAudioAuthorizationWithBlock:block setBlock:setblock isShow:isShow];
            });
        }];
        return;
    }
    
    NSString *title;
    NSString *message;
    if (!videoResult) {
        title = @"开启麦克风权限";
        message = @"请开启麦克风权限,开启后即可正常使用该功能";
        NSString *content = message;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
        if (isShow) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *videoAuthURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:videoAuthURL]) {
                [[UIApplication sharedApplication] openURL:videoAuthURL];
            }
            if (setblock) setblock();
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    if (block) {
        block(videoResult);
    }
}

+ (BOOL)isAudioAvailable {
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return audioAuthStatus == AVAuthorizationStatusAuthorized;
}

#pragma mark ---------- 定位权限判断
+(BOOL)checkAuthorizationWithType:(PSAuthorizationType)type {
    BOOL result = NO;
    if (type == PSLocation) { //定位权限
        if (![CLLocationManager locationServicesEnabled]) {
            return NO;
        }
        CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
        if (CLstatus == kCLAuthorizationStatusDenied || CLstatus == kCLAuthorizationStatusRestricted) {
            return NO;
        }
        return YES;
    }
    return result;
}

+(void)showAuthTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle{

    AppDelegate *appDelegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *content = message;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *SetAuthURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:SetAuthURL]) {
            [[UIApplication sharedApplication] openURL:SetAuthURL];
        }
        [alertController dismissViewControllerAnimated:YES completion:nil];
        appDelegate.showLocaAlert = NO;
    }]];
    //获取当前显示的控制器
    UIViewController *VC = [UIViewController jsd_getCurrentViewController];
    if (appDelegate.showLocaAlert==NO) {
        appDelegate.showLocaAlert = YES;
        [VC presentViewController:alertController animated:YES completion:nil];
    }
}

@end
