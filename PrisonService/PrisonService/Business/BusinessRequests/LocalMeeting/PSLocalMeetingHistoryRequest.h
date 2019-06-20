//
//  PSLocalMeetingHistoryRequest.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSLocalMeetingHistoryRequest : PSBusinessRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, strong) NSString *familyId;

@end

NS_ASSUME_NONNULL_END
