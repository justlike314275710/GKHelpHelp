//
//  PSAdvisoryMesssageViewController.h
//  PrisonService
//
//  Created by kky on 2019/9/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSMessageViewModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ReloadDot)();
@interface PSAdvisoryMesssageViewController : PSBusinessViewController
@property(nonatomic,assign)NSInteger dotIndex;
@property(nonatomic,copy)ReloadDot reloaDot;

-(void)reloadDataReddot;
-(void)refreshData;

@end

NS_ASSUME_NONNULL_END
