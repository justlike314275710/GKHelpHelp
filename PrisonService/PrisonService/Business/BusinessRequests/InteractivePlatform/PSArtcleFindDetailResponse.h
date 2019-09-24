//
//  PSArtcleFindDetailResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSArticleDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSArtcleFindDetailResponse : PSResponse
@property (nonatomic, strong)PSArticleDetailModel *detailModel;
@end

NS_ASSUME_NONNULL_END
