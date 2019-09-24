//
//  PSArtcleDetailResponse.h
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSArticleDetailModel.h"
#import <JSONModel/JSONModel.h>


NS_ASSUME_NONNULL_BEGIN

@interface PSArtcleDetailResponse : PSResponse
@property (nonatomic, strong) NSArray<PSArticleDetailModel,Optional> *articles;
@end

NS_ASSUME_NONNULL_END
