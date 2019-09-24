//
//  PSImageDisplayViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "SDCycleScrollView.h"

typedef NSArray *(^ImageNamesGroup)();
typedef NSArray *(^ImageURLStringsGroup)();
typedef void(^DidScrollToIndex)(NSInteger index);

@interface PSImageDisplayViewController : PSBusinessViewController

@property (nonatomic, strong, readonly) SDCycleScrollView *displayScrollView;
@property (nonatomic, copy) ImageNamesGroup namesGroup;
@property (nonatomic, copy) ImageURLStringsGroup urlsGroup;
@property (nonatomic, copy) DidScrollToIndex didScroll;

@end
