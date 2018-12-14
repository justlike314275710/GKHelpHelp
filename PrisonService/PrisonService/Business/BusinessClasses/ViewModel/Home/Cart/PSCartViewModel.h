//
//  PSCartViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/5/14.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPhoneCardViewModel.h"

@interface PSCartViewModel : PSPhoneCardViewModel

@property (nonatomic, strong, readonly) NSArray *products;
@property (nonatomic, assign,) CGFloat amount;
@property (nonatomic, assign,) NSInteger totalQuantity;
@property (nonatomic, assign, readonly) BOOL totalSelected;

- (void)selectedAllProducts:(BOOL)selected;
- (void)selectOperationAtIndex:(NSInteger)index;
- (void)reduceOperationAtIndex:(NSInteger)index;
- (void)increaseOperationAtIndex:(NSInteger)index;

@end
