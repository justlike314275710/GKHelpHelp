//
//  UIButton+BEEnLargeEdge.h
//  PrisonService
//
//  Created by kky on 2019/6/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (BEEnLargeEdge)

- (void)be_setEnlargeEdge:(CGFloat)size;
- (void)be_setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end

NS_ASSUME_NONNULL_END
