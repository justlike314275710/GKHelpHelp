//
//  PSInteractiveMessageViewController.h
//  PrisonService
//
//  Created by kky on 2019/9/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSMessageViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSInteractiveMessageViewController : PSBusinessViewController
@property(nonatomic,assign)NSInteger dotIndex;
-(void)reloadDataReddot;
-(void)refreshData;

@end

NS_ASSUME_NONNULL_END
