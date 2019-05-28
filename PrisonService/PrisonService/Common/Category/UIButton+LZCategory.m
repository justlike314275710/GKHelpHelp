//
//  UIButton+LZCategory.m
//  LZButtonCategory
//
//  Created by Artron_LQQ on 16/5/5.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import "UIButton+LZCategory.h"

@implementation UIButton (LZCategory)

- (void)setbuttonType:(LZCategoryType)type {
    
    [self layoutIfNeeded];
    
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    
    CGFloat space = titleFrame.origin.x - imageFrame.origin.x - imageFrame.size.width;
    
    if (type == LZCategoryTypeLeft) {

        [self setImageEdgeInsets:UIEdgeInsetsMake(0,titleFrame.size.width + space, 0, -(titleFrame.size.width + space))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -(titleFrame.origin.x - imageFrame.origin.x), 0, titleFrame.origin.x - imageFrame.origin.x)];

    } else if(type == LZCategoryTypeBottom) {
        
        int imageleft = IS_iPhone_5?8:0;
        int titleLeft = IS_iPhone_5?5:0;
        [self setImageEdgeInsets:UIEdgeInsetsMake(10,imageleft, titleFrame.size.height + space, -(titleFrame.size.width))];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(imageFrame.size.height + space+25, -(imageFrame.size.width)+titleLeft, 0, 0)];
    }
}

- (void)setbuttonType:(LZCategoryType)type spaceHeght:(int)spaceHeght  {
    
    [self layoutIfNeeded];
    
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    
    CGFloat space = titleFrame.origin.x - imageFrame.origin.x - imageFrame.size.width;
    
    if (type == LZCategoryTypeLeft) {
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0,titleFrame.size.width + space, 0, -(titleFrame.size.width + space))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -(titleFrame.origin.x - imageFrame.origin.x), 0, titleFrame.origin.x - imageFrame.origin.x)];
        
    } else if(type == LZCategoryTypeBottom) {
        
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(spaceHeght,0, titleFrame.size.height + space, -(titleFrame.size.width))];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(imageFrame.size.height + spaceHeght+30, -(imageFrame.size.width), 0, 0)];
    }
}

-(void)lz_initButton:(UIButton*)btn{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height + 20 ,-btn.imageView.frame.size.width, 0.0,0.0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0,btn.imageView.x-2,10, -btn.titleLabel.bounds.size.width)];
    
    if ([NSObject judegeIsVietnamVersion]) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0,(btn.width- btn.imageView.width)/2,10, -btn.titleLabel.bounds.size.width)];
    }
}




@end
