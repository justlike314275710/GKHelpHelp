//
//  PSServiceCentreViewController.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "SDCycleScrollView.h"
@interface PSServiceCentreViewController : PSBusinessViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong, readonly) UITableView *serviceCentreTableView;
@property (nonatomic, strong) SDCycleScrollView *advView;
//是否显示广告
- (BOOL)showAdv;

@end
