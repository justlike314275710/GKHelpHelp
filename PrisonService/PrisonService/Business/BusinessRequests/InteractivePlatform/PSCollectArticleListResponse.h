//
//  PSCollectArticleListResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSCollectArticleListModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol PSCollectArticleListResponse<NSObject>

@end

@interface PSCollectArticleListResponse : PSResponse
@property (nonatomic, strong) NSArray<PSCollectArticleListModel,Optional> *collectList;

@end

NS_ASSUME_NONNULL_END
