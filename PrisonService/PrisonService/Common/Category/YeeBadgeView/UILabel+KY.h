//
//  UILabel+KY.h
//  DAudiobook
//
//  Created by kky on 2019/10/12.
//  Copyright © 2019年 liujiliu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (KY)

// 字间距 自定义属性
@property (nonatomic, copy) NSString*characterSpace;

// 行间距 自定义属性
@property (nonatomic, copy) NSString*lineSpace;

// 获取lab的高度
- (CGFloat)getLableHeightWithMaxWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
