//
//  PSPublishFamilyArticleRequest.h
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPublishFamilyArticleRequest : PSBusinessRequest
@property (nonatomic, copy)NSString *id;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, copy)NSString *articleType; //articleType 文章类型(1为互动文章，2为连载小说)
@property (nonatomic, copy)NSString *penName;
@end

NS_ASSUME_NONNULL_END
