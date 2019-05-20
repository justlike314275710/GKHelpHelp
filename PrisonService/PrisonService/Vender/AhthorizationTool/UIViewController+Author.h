//
//  UIViewController+Author.h
//  PrisonService
//
//  Created by kky on 2019/5/20.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef  void (^limitBlock)();

@interface UIViewController (Author)
- (NSDictionary *)getAuthorDict;
- (void)showPrisonLimits:(NSString *)key limitBlock:(limitBlock)block;
/***
 游客和未认证状态
 ***/
- (void)doNotLoginPassed;
@end

NS_ASSUME_NONNULL_END
