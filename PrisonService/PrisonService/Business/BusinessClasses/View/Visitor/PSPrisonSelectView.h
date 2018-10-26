//
//  PSPrisonSelectView.h
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSPrisonSelectView : UIView

@property (nonatomic, strong, readonly) UIButton *proviceButton;
@property (nonatomic, strong, readonly) UILabel *proviceLabel;
@property (nonatomic, strong, readonly) UIButton *cityButton;
@property (nonatomic, strong, readonly) UILabel *cityLabel;
@property (nonatomic, strong, readonly) UIButton *prisonButton;
@property (nonatomic, strong, readonly) UILabel *prisonLabel;

@end
