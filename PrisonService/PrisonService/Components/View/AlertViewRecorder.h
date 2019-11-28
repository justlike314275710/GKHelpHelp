//
//  AlertViewRecorder.h
//  PrisonService
//
//  Created by kky on 2019/11/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertViewRecorder : NSObject
@property (nonatomic, strong)NSMutableArray * alertViewArray;

+ (AlertViewRecorder *)shareAlertViewRecorder;

@end

NS_ASSUME_NONNULL_END
