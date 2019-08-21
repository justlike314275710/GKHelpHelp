//
//  PSPlatformMenuView.h
//  PrisonService
//
//  Created by kky on 2019/8/1.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLButton;
@protocol PSPlatfromMenuViewDelegate <NSObject>

/// 点击item
- (void)pagescrollMenuViewItemOnClick:(YLButton *)button index:(NSInteger)index;

@end


@interface PSPlatformMenuView : UIView


- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
       normalImages:(NSArray *)normalImages
     selectedImages:(NSArray *)selectedImages
           delegate:(id<PSPlatfromMenuViewDelegate>)delegate
       currentIndex:(NSInteger)currentIndex;

@end


