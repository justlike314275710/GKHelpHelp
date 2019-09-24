//
//  PSfamiliesAuthorResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSPublicArticleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSfamiliesAuthorResponse : PSResponse
@property (nonatomic, strong)PSPublicArticleModel *author;
@end

NS_ASSUME_NONNULL_END
