//
//  PSPlatformArticleCell.h
//  PrisonService
//
//  Created by kky on 2019/8/2.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSArticleDetailModel.h"
#import "PSCollectArticleListModel.h"

typedef void (^PSPraiseResult)(BOOL action);
//YES 点赞,NO 取消点赞
typedef void (^PSCellPraiseBlock)(BOOL action,NSString *id,PSPraiseResult result);

NS_ASSUME_NONNULL_BEGIN
@interface PSPlatformArticleCell : UITableViewCell
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIImageView *headImg;
@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UIImageView *stateImageView;
@property(nonatomic,strong)UILabel *contentLab;
@property(nonatomic,strong)UIImageView *timeIconImg;
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)KpengDianZanBtn *likeBtn;
@property(nonatomic,strong)UILabel *likeLab;
@property(nonatomic,strong)UIImageView *hotIconImg;
@property(nonatomic,strong)UILabel *hotLab;

@property(nonatomic,strong)PSArticleDetailModel *model;
//收藏文章
@property(nonatomic,strong)PSCollectArticleListModel *collecModel;

@property(nonatomic,copy)PSCellPraiseBlock praiseBlock;

@end

NS_ASSUME_NONNULL_END
