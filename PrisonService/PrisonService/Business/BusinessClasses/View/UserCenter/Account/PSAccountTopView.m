//
//  PSAccountTopView.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAccountTopView.h"
#import "UIImageView+CornerRadius.h"

@implementation PSAccountTopView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImage *bgImage = [UIImage imageNamed:@"userCenterAccountTopBg"];
        CGFloat bgRate = bgImage.size.height/bgImage.size.width;
        _topRate = bgRate;
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        bgImageView.image = bgImage;
        [self addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.mas_equalTo(bgImageView.mas_width).multipliedBy(bgRate);
        }];
        UIImage *infoBgImage = [UIImage imageNamed:@"userCenterAccountInfoBg"];
        CGFloat infoBgRate = infoBgImage.size.height/infoBgImage.size.width;
        _infoRate = infoBgRate;
        UIImageView *infoBgImageView = [UIImageView new];
        infoBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        infoBgImageView.image = infoBgImage;
        [self addSubview:infoBgImageView];
        [infoBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(25);
            make.right.mas_equalTo(-25);
            make.top.mas_equalTo(bgImageView.mas_bottom).offset(-45);
            make.height.mas_equalTo(infoBgImageView.mas_width).multipliedBy(infoBgRate);
        }];
        
        /*
        _avatarImageView = [[UIImageView alloc] initWithRoundingRectImageView];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_avatarImageView zy_attachBorderWidth:1.0 color:[UIColor whiteColor]];
        [infoBgImageView addSubview:_avatarImageView];
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(infoBgImageView.mas_centerY);
            make.centerX.mas_equalTo(infoBgImageView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(54, 54));
        }];
         */
        CGFloat radius = 27;
//        _avatarView = [PYPhotosView photosView];
        _avatarView = [UIImageView new];
        _avatarView.layer.cornerRadius = radius;
        _avatarView.layer.borderWidth = 1.0;
        _avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
//        _avatarView.photoWidth = radius * 2;
//        _avatarView.photoHeight = radius * 2;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        
//        _avatarView.placeholderImage = [UIImage imageNamed:@"userCenterDefaultAvatar"];
        [self addSubview:_avatarView];
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(infoBgImageView.mas_centerY);
            make.centerX.mas_equalTo(infoBgImageView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(2 * radius, 2 * radius));
        }];
        
        _nicknameLabel = [UILabel new];
        _nicknameLabel.font = FontOfSize(14);
        _nicknameLabel.textColor = AppBaseTextColor1;
        _nicknameLabel.textAlignment = NSTextAlignmentCenter;
        [infoBgImageView addSubview:_nicknameLabel];
        [_nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(50);
            make.right.mas_equalTo(-50);
            make.top.mas_equalTo(infoBgImageView.mas_centerY).offset(15);
            make.height.mas_equalTo(16);
        }];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
