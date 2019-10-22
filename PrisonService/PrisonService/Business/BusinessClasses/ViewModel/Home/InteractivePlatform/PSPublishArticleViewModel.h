//
//  PSPublishArticleViewModel.h
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSPublishArticleViewModel.h"
#import "PSArticleFindPenNameRequest.h"
#import "PSPublicArticleModel.h"
typedef NS_ENUM(NSInteger,PSPublishArticleType) {
    PSPublishArticle, //发布文章
    PSEditArticle, //编辑文章
};

@interface PSPublishArticleViewModel : PSViewModel
@property(nonatomic,strong)PSPublicArticleModel *model;
@property(nonatomic,assign)PSPublishArticleType type;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *articleType;
@property(nonatomic,strong)NSString *penName;
@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSArray *words;
@property(nonatomic,assign)BOOL editPenName;



//查找笔名
- (void)findPenNameCompleted:(RequestDataCompleted)completedCallback
                         failed:(RequestDataFailed)failedCallback;

//发布文章
- (void)publishArticleCompleted:(RequestDataCompleted)completedCallback
                      failed:(RequestDataFailed)failedCallback;


- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText;

@end

