//
//  PSCollectArticleRequest.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCollectArticleRequest : PSBusinessRequest
@property (nonatomic, copy)NSString *articleId;
@property (nonatomic, copy)NSString *type;
@end

NS_ASSUME_NONNULL_END
