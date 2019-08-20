//
//  PSPlatformHeadView.h
//  PrisonService
//
//  Created by kky on 2019/8/5.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef  void (^PSPlatformHeadViewBlock)(NSString *title);

@interface PSPlatformHeadView : UIView
@property(nonatomic,copy)PSPlatformHeadViewBlock block;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
