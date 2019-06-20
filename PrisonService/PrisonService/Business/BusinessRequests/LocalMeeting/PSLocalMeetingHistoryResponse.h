//
//  PSLocalMeetingHistoryResponse.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSResponse.h"
#import "PSMeettingHistory.h"
NS_ASSUME_NONNULL_BEGIN

@interface PSLocalMeetingHistoryResponse : PSResponse
@property(nonatomic, strong) NSArray<PSMeettingHistory,Optional> *history;
@end

NS_ASSUME_NONNULL_END
