//
//  PSLocalMeetCancelRequest.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSLocalMeetCancelRequest : PSBusinessRequest
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *cause;
@end

NS_ASSUME_NONNULL_END
