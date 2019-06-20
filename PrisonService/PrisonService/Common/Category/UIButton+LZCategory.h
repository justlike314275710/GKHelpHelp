//
//  UIButton+LZCategory.h
//  LZButtonCategory
//
//  Created by Artron_LQQ on 16/5/5.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LZCategoryType) {
    LZCategoryTypeLeft = 0,
    LZCategoryTypeBottom,
};
@interface UIButton (LZCategory)

- (void)setbuttonType:(LZCategoryType)type;
- (void)setbuttonType:(LZCategoryType)type spaceHeght:(int)spaceHeght;
-(void)lz_initButton:(UIButton*)btn;
@end
