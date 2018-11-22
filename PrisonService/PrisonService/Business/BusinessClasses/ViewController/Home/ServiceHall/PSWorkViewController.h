//
//  PSWorkViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSWorkViewModel.h"
#import "SDCycleScrollView.h"

@interface PSWorkViewController : PSBusinessViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *workTableView;
@property (nonatomic, strong, readonly) SDCycleScrollView *advView;
@property (nonatomic , strong) NSString *jailId;
@property (nonatomic , strong) NSString *jailName;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
//是否显示广告
- (BOOL)showAdv;

@end
