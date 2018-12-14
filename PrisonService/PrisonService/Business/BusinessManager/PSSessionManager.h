//
//  PSSessionManager.h
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSLaunchTask.h"
#import "PSUserSession.h"
#import "PSPrisonerDetail.h"
#import "PSTipsConstants.h"
typedef void(^SessionCompletion)(BOOL completed);
typedef void(^SynchronizePrisonerDetailsCompletion)();

//typedef NS_ENUM(NSUInteger, PSLoginStatus) {
//    PSLoginNone=0,
//    PSLoginDenied=1,
//    PSLoginPending=2,
//    PSLoginPassed=3
//};

@protocol PSSessionObserver<NSObject>

- (void)userBalanceDidSynchronized;

@end

@interface PSSessionManager : NSObject<PSLaunchTask>

@property (nonatomic, assign) PSLoginStatus loginStatus;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, strong) NSArray *passedPrisoners;
@property (nonatomic, strong) NSArray *passedPrisonerDetails;
@property (nonatomic, strong, readonly) PSRegistration *currentRegistration;
@property (nonatomic, assign) NSInteger selectedPrisonerIndex;


@property (nonatomic, strong, readonly) UIViewController *rootViewController;
+ (PSSessionManager *)sharedInstance;
- (void)addObserver:(id<PSSessionObserver>)observer;
- (void)removeObserver:(id<PSSessionObserver>)observer;
- (void)synchronizePrisonerDetailsCompletion:(SynchronizePrisonerDetailsCompletion)completion;
- (void)synchronizeDefaultJailConfigurations;

- (void)synchronizeUserBalance;
- (void)doLogout;
- (void)autoLogin:(SessionCompletion)completion;

@end
