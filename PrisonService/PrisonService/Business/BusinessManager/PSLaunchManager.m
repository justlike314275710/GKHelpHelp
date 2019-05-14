//
//  PSLaunchManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/3.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLaunchManager.h"
#import "PSObserverVector.h"
#import "PSVisitorManager.h"
#import "PSSessionManager.h"
#import "PSCountdownManager.h"
#import "PSIMMessageManager.h"
#import "PSMeetingManager.h"
#import "PSGuideManager.h"
#import "PSStartupAdvManager.h"
#import "PSLaunchViewController.h"
#import "PSContentManager.h"
#import "PSLocateManager.h"

@interface PSLaunchManager ()

@property (nonatomic, strong) NSMutableArray *launchQueue;
@property (nonatomic, strong) PSObserverVector *observerVector;

@end

@implementation PSLaunchManager

+ (PSLaunchManager *)sharedInstance {
    static PSLaunchManager *launchManager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!launchManager) {
            launchManager = [[PSLaunchManager alloc] init];
        }
    });
    return launchManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.launchQueue = [NSMutableArray array];
    }
    return self;
}

- (void)addObserver:(id<PSLaunchObserver>)observer {
    [self.observerVector addObserver:observer];
}

- (void)removeObserver:(id<PSLaunchObserver>)observer {
    [self.observerVector removeObserver:observer];
}

- (void)notifyObserverLaunchBegin {
    [_observerVector notifyObserver:@selector(launchManagerStartLaunch) object:nil];
}

- (void)notifyObserverLaunchFinished {
    [_observerVector notifyObserver:@selector(launchManagerDidFinished) object:nil];
}

- (void)notifyObserverLaunchFailed {
    [_observerVector notifyObserver:@selector(launchManagerDidFailed) object:nil];
}

- (void)addTask:(id<PSLaunchTask>)task {
    [self.launchQueue addObject:task];
}

- (void)removeTask:(id<PSLaunchTask>)task {
    [self.launchQueue removeObject:task];
}

- (void)clearAllTasks {
    [self.launchQueue removeAllObjects];
}

- (void)launchNextTask {
    id<PSLaunchTask> task = [_launchQueue count] > 0  ? [_launchQueue firstObject] : nil;
    if (task) {
        @weakify(self)
        [task launchTaskWithCompletion:^(BOOL completed) {
            @strongify(self)
            if (completed) {
                [self removeTask:task];
                if ([self.launchQueue count] == 0) {
                    [self notifyObserverLaunchFinished];
                }else{
                    [self launchNextTask];
                }
            }else{
                [self notifyObserverLaunchFailed];
            }
        }];
    }
}

- (void)launch{
    [self notifyObserverLaunchBegin];
    [self.launchQueue insertObject:self atIndex:0];
    [self launchNextTask];
}

- (void)launchApplication {
    [self addTask:[PSCountdownManager sharedInstance]];
    [self addTask:[PSStartupAdvManager sharedInstance]];
    [self addTask:[PSGuideManager sharedInstance]];
   // [self addTask:[PSVisitorManager sharedInstance]];
    [self addTask:[PSSessionManager sharedInstance]];
    [self addTask:[PSLocateManager sharedInstance]];
    [self addTask:[PSContentManager sharedInstance]];
    [self addTask:[PSMeetingManager sharedInstance]];
    [self addTask:[PSIMMessageManager sharedInstance]];
    
    [self launch];
}

- (void)launchFromLogout {
    [self clearAllTasks];
    [self addTask:[PSSessionManager sharedInstance]];
    [self addTask:[PSContentManager sharedInstance]];
    [self addTask:[PSIMMessageManager sharedInstance]];
    [self launch];
}

- (void)launchHandling {
    PSLaunchViewController *launchViewController = [PSLaunchViewController new];
    [UIApplication sharedApplication].keyWindow.rootViewController = launchViewController;
}

#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    [self launchHandling];
    if (completion) {
        completion(YES);
    }
}

@end
