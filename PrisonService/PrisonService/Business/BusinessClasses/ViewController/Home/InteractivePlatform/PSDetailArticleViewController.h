//
//  PSDetailArticleViewController.h
//  PrisonService
//
//  Created by kky on 2019/9/16.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"

typedef void (^DetailPraiseBlock)(BOOL isPraise,NSString*id,BOOL result); //刷新
typedef void (^DetailHotChangeBlock)(NSString*clientNum); //热度刷新

typedef NS_ENUM(NSInteger, PSDetailArticleType) {
    articles_obtained,  //已下架
    articles_notpass,   //未通过
    articles_reviewing, //审核中
    articles_passed,    //已通过
};

@interface PSDetailArticleViewController : PSBusinessViewController
@property(nonatomic,assign)PSDetailArticleType type;
@property(nonatomic,copy)DetailPraiseBlock praiseBlock;
@property(nonatomic,copy)DetailHotChangeBlock hotChangeBlock;

@end

