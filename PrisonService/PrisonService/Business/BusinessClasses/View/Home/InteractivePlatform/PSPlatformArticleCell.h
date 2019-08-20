//
//  PSPlatformArticleCell.h
//  PrisonService
//
//  Created by kky on 2019/8/2.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSPlatformArticleCell : UITableViewCell
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIImageView *headImg;
@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UILabel *contentLab;
@property(nonatomic,strong)UIImageView *timeIconImg;
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)UIButton *likeBtn;
@property(nonatomic,strong)UILabel *likeLab;
@property(nonatomic,strong)UIImageView *hotIconImg;
@property(nonatomic,strong)UILabel *hotLab;

@end

NS_ASSUME_NONNULL_END
