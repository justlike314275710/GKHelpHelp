//
//  PSPhotoBrowser.h
//  PrisonService
//
//  Created by kky on 2018/12/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ __nullable DismissBlock)(UIImage * __nullable image, NSInteger index);

@interface PSPhotoBrowser : UIView

+(instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images atIndex:(NSInteger)index;
 

@end


