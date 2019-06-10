//
//  PSHomeMoreFunctionView.h
//  PrisonService
//
//  Created by kky on 2019/6/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^HomeMoreFunctionViewBlock)(NSInteger index);
NS_ASSUME_NONNULL_BEGIN

@interface PSHomeMoreFunctionView : UIView

@property(nonatomic,copy)HomeMoreFunctionViewBlock moreFunctionBlock;

@end

NS_ASSUME_NONNULL_END
