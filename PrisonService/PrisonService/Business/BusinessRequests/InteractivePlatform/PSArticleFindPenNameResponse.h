//
//  PSArticleFindPenNameResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSPublicArticleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSArticleFindPenNameResponse : PSResponse
@property (nonatomic, strong)PSPublicArticleModel *publicArticleModel;
@end

NS_ASSUME_NONNULL_END
