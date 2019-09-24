//
//  PSArticleDetailViewModel.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSArticleDetailModel.h"
#import "PSPublicArticleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSArticleDetailViewModel : PSViewModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) PSArticleDetailModel *detailModel;
@property (nonatomic, strong) PSPublicArticleModel *authorModel;


//加载详情
- (void)loadArticleDetailCompleted:(RequestDataCompleted)completedCallback
                            failed:(RequestDataFailed)failedCallback;
//收藏
- (void)collectArticleCompleted:(RequestDataCompleted)completedCallback
                            failed:(RequestDataFailed)failedCallback;

//取消收藏
- (void)cancelCollectArticleCompleted:(RequestDataCompleted)completedCallback
                         failed:(RequestDataFailed)failedCallback;

//点赞
- (void)praiseArticleCompleted:(RequestDataCompleted)completedCallback
                         failed:(RequestDataFailed)failedCallback;


//取消点赞
- (void)deletePraiseArticleCompleted:(RequestDataCompleted)completedCallback
                        failed:(RequestDataFailed)failedCallback;

//获取是否能发文章权限
- (void)authorArticleCompleted:(RequestDataCompleted)completedCallback
                        failed:(RequestDataFailed)failedCallback;

//计算高度
-(CGFloat)calculationTextViewHeight:(UITextView*)textView;


- (float)heightForString:(NSString *)value andWidth:(float)width;


@end

NS_ASSUME_NONNULL_END
