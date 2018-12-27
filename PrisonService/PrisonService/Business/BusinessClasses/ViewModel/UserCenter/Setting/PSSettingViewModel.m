//
//  PSSettingViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSSettingViewModel.h"
#import <SDWebImage/SDImageCache.h>


@implementation PSSettingViewModel
- (id)init {
    self = [super init];
    if (self) {
        NSMutableArray *items = [NSMutableArray array];
        /*
        NSMutableArray *firstSectionItems = [NSMutableArray array];
        PSSettingItem *alarmItem = [PSSettingItem new];
        alarmItem.itemName = @"闹钟提醒";
        alarmItem.itemIconName = @"userCenterSettingAlarm";
        [firstSectionItems addObject:alarmItem];
        
        PSSettingItem *passwordItem = [PSSettingItem new];
        passwordItem.itemName = @"独立密码设置";
        passwordItem.itemIconName = @"userCenterSettingPassword";
        [firstSectionItems addObject:passwordItem];
        
        [items addObject:firstSectionItems];
         */
        
        NSMutableArray *secondSectionItems = [NSMutableArray array];
        PSSettingItem *feedbackItem = [PSSettingItem new];
        feedbackItem.itemValue = @"";
        NSString*feedback=NSLocalizedString(@"feedback", @"意见反馈");
        feedbackItem.itemName = feedback;
        feedbackItem.itemIconName = @"userCenterSettingFeedback";
        [secondSectionItems addObject:feedbackItem];
        [items addObject:secondSectionItems];
        
        NSMutableArray *thirdSectionItems = [NSMutableArray array];
        PSSettingItem *storage_spaceItem = [PSSettingItem new];
        NSString *storage_spaceStr = NSLocalizedString(@"storage", @"存储空间");
        storage_spaceItem.itemName = storage_spaceStr;
        storage_spaceItem.itemIconName = @"userCenterSettingStorage";
        storage_spaceItem.itemValue = [NSString stringWithFormat:@"%.1fM",[self fileSizeWithIntergeWithM]+61.9];
        [thirdSectionItems addObject:storage_spaceItem];
        [items addObject:thirdSectionItems];
        
        NSMutableArray *fourSectionItems = [NSMutableArray array];
        PSSettingItem *current_versionItem = [PSSettingItem new];
        NSString *current_versionStr = NSLocalizedString(@"current_version", @"当前版本");
        current_versionItem.itemName = current_versionStr;
        current_versionItem.itemIconName = @"userCenterSettingCurrentversion";
        NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
        current_versionItem.itemValue = [NSString stringWithFormat:@"v%@",localVersion];
        
        [fourSectionItems addObject:current_versionItem];
        [items addObject:fourSectionItems];
        
        self.settingItems = items;
    }
    return self;
}

- (CGFloat)fileSizeWithIntergeWithM {
    NSUInteger size = [[SDImageCache sharedImageCache] getSize];
    return size/(1024 * 1024);
}

//计算缓存大小
- (NSString *)fileSizeWithInterge{
    
    NSUInteger size = [[SDImageCache sharedImageCache] getSize];
    // 1k = 1024, 1m = 1024k
    if (size < 1024) {// 小于1k
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = size/1024;
        return [NSString stringWithFormat:@"%.0fK",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = size/(1024 * 1024);
        return [NSString stringWithFormat:@"%.1fM",aFloat];
    }else{
        CGFloat aFloat = size/(1024*1024*1024);
        return [NSString stringWithFormat:@"%.1fG",aFloat];
    }
}

@end
