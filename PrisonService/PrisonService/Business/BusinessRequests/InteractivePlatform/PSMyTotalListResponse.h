//
//  PSMyTotalListResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/16.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSArticleDetailModel.h"

//0,"articles_notpublished":[],"articles_notpass":[],"articles_published":[]}}

NS_ASSUME_NONNULL_BEGIN

@interface PSMyTotalListResponse : PSResponse
@property (nonatomic, strong) NSArray<PSArticleDetailModel,Optional> *articles_notpublished;
@property (nonatomic, strong) NSArray<PSArticleDetailModel,Optional> *articles_notpass;
@property (nonatomic, strong) NSArray<PSArticleDetailModel,Optional> *articles_published;
@end

NS_ASSUME_NONNULL_END
