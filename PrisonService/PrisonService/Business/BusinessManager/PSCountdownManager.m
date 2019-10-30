//
//  STCountdownManager.m
//  Common
//
//  Created by calvin on 14-5-9.
//  Copyright (c) 2014年 BuBuGao. All rights reserved.
//

#import "PSCountdownManager.h"
#import "PSObserverVector.h"

@interface PSCountdownManager ()

@property (nonatomic, strong) PSObserverVector *observerVector;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation PSCountdownManager

+ (PSCountdownManager *)sharedInstance {
    static PSCountdownManager *countdownManager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken,^{
        if (!countdownManager) {
            countdownManager = [[self alloc] init];
        }
    });
    return countdownManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _observerVector = [[PSObserverVector alloc] init];
    }
    return self;
}


- (void)addObserver:(id<PSCountdownObserver>)observer {
    [_observerVector addObserver:observer];
}

- (void)removeObserver:(id<PSCountdownObserver>)observer {
    [_observerVector removeObserver:observer];
}

- (void)notifyObserver {
    [_observerVector notifyObserver:@selector(countdown)];
}

- (void)handleTimer:(NSDictionary *)userInfo {
    [self notifyObserver];
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    if ([_timer isValid]) {
        [_timer invalidate];
       _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    completion(YES);
}

- (NSString *)taskName {
    return @"倒计时管理";
}

@end
