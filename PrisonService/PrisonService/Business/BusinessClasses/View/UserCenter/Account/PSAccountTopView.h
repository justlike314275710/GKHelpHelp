//
//  PSAccountTopView.h
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYPhotoBrowser.h"

@interface PSAccountTopView : UIView

@property (nonatomic, strong, readonly) UIImageView *avatarImageView;
//@property (nonatomic, strong, readonly) PYPhotosView *avatarView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong, readonly) UILabel *nicknameLabel;
@property (nonatomic, assign, readonly) CGFloat topRate;
@property (nonatomic, assign, readonly) CGFloat infoRate;

@end
