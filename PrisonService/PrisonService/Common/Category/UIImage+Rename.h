//
//  UIImage+Rename.h
//  PrisonService
//
//  Created by kky on 2018/12/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Rename)
/***
///<越南版名字默认前面字符串为@"v_"
 ***/
+(UIImage *)R_imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
