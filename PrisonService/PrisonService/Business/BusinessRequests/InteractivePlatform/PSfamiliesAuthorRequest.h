//
//  PSfamiliesAuthorRequest.h
//  PrisonService
//
//  Created by kky on 2019/9/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSfamiliesAuthorRequest : PSBusinessRequest
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, copy)NSString *type; //账户类型[1代表家属 2代表狱警]

@end

NS_ASSUME_NONNULL_END
