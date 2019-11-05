//
//  PSLoginMiddleView.h
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSUnderlineTextField.h"

@interface PSLoginMiddleView : UIView

@property (nonatomic, strong) UILabel*codeLable;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong, readonly) UIButton *codeButton;
@property (nonatomic, strong, readonly) PSUnderlineTextField *phoneTextField;
@property (nonatomic, strong, readonly) PSUnderlineTextField *cardTextField;
@property (nonatomic, strong, readonly) PSUnderlineTextField *codeTextField;



@end
