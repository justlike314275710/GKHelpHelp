//
//  PSHomeFunctionView.h
//  PrisonService
//
//  Created by kky on 2019/6/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HomeFunctionBlock)(NSInteger index);
NS_ASSUME_NONNULL_BEGIN

@interface PSHomeFunctionView : UIView
@property (nonatomic,copy)HomeFunctionBlock homeFunctionBlock;
/**
 @param titles 标题
 @param imageIcons 图标
 @return
 */
- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
         imageIcons:(NSArray *)imageIcons;



@end

NS_ASSUME_NONNULL_END
