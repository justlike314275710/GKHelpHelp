//
//  PSDeleteRequest.h
//  PrisonService
//
//  Created by kky on 2018/12/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSDeleteRequest : PSRequest

+ (void)requestPUTWithURLStr:(NSString *)urlStr paramDic:(NSDictionary *)paramDic  finish:(void(^)(id responseObject))finish enError:(void(^)(NSError *error))enError;

@end

NS_ASSUME_NONNULL_END
