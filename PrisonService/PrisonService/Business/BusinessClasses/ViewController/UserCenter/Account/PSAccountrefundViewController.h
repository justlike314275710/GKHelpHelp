//
//  PSAccountrefundViewController.h
//  PrisonService
//
//  Created by kky on 2018/11/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
typedef void (^RefundBlock)(NSString *balanceSting);

NS_ASSUME_NONNULL_BEGIN

@interface PSAccountrefundViewController : PSBusinessViewController
@property (nonatomic,copy) RefundBlock refundBlock;

@end

NS_ASSUME_NONNULL_END
