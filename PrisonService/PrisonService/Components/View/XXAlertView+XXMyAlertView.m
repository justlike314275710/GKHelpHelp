//
//  XXAlertView+XXMyAlertView.m
//  PrisonService
//
//  Created by kky on 2019/11/19.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "XXAlertView+XXMyAlertView.h"
#import <objc/message.h>
#import "AppDelegate.h"
#import "AlertViewRecorder.h"

@implementation XXAlertView (XXMyAlertView)

+ (void)load
{
    // 获取将要交换的两个方法
    Method showMethod = class_getInstanceMethod(self, @selector(show));
    Method myShowMethod = class_getInstanceMethod(self, @selector(myShow));
    // 将两个方法互换
    method_exchangeImplementations(showMethod, myShowMethod);
    
}

- (void)myShow
{
    // 将之前所有的alertView取出来消失掉
    NSMutableArray *array =  [AlertViewRecorder shareAlertViewRecorder].alertViewArray;
    for (XXAlertView *alertView in array) {
        if ([alertView isKindOfClass:[XXAlertView class]]) {
            UIButton *new = [[UIButton alloc] init];
            new.tag = 1;
            [alertView buttonEvent:new];
        }
    }
    [array removeAllObjects];
    // 调用自身的方法
    [self myShow];
    [array addObject:self];
}

@end
