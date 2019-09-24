//
//  PSArticleGetMyArticleResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSArticleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN
//articles
@interface PSArticleGetMyArticleResponse : PSResponse
@property (nonatomic, strong) NSArray<PSArticleDetailModel,Optional> *articles;
@end

NS_ASSUME_NONNULL_END
