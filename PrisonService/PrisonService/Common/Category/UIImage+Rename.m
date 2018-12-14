//
//  UIImage+Rename.m
//  PrisonService
//
//  Created by kky on 2018/12/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "UIImage+Rename.h"

@implementation UIImage (Rename)

+(UIImage *)R_imageNamed:(NSString *)name {
    UIImage *image = nil;
    //越南版
    if ([NSObject judegeIsVietnamVersion]) {
        if ([name hasPrefix:@"v_"]) {
            image = [UIImage imageNamed:name];
        } else {
            NSString *rename = [NSString stringWithFormat:@"v_%@",name];
            image = [UIImage imageNamed:rename];
            if (!image) {
                image = [UIImage imageNamed:name];
            }
        }
    } else {
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end
