//
//  PSMessageViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSMessageViewModel.h"
typedef void (^ReloadDot)();

@interface PSMessageViewController : PSBusinessViewController
@property(nonatomic,assign)NSInteger dotIndex;
@property(nonatomic,copy)ReloadDot reloaDot;

-(void)reloadDataReddot;
-(void)refreshData;


@end
