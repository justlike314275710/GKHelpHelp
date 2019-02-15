//
//  PSSettingViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSSettingItem.h"

@interface PSSettingViewModel : PSViewModel

@property (nonatomic, strong) NSArray *settingItems;

@property (nonatomic, strong) NSString *allstorage;

@end
