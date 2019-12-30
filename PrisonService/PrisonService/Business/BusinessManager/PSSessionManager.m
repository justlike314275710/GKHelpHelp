//
//  PSSessionManager.m
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "PSAuthenticationMainViewController.h"
#import "PSSessionManager.h"
#import "PSSessionViewController.h"
#import "PSContentManager.h"
#import "PSBusinessConstants.h"
#import "PSLoginRequest.h"
#import "PSCache.h"
#import "PSLaunchManager.h"
#import "PSPrisonerDetailRequest.h"
#import "PSIMMessageManager.h"
#import "PSSessionViewController.h"
#import "PSSessionPendingController.h"
#import "PSSessionNoneViewController.h"
#import "PSObserverVector.h"
#import "AFNetworking.h"
#import "PSVistorHomeViewController.h"
#import "PSHomeViewModel.h"
#import "PSLoginViewModel.h"
#import "PSDefaultJailResponse.h"
#import "PSDefaultJailRequest.h"
#import "NSObject+version.h"
#import "ASFRManager.h"

//typedef void(^SessionCompletion)(BOOL completed);

@interface PSSessionManager ()

@property (nonatomic, strong) PSLoginRequest *loginRequest;
@property (nonatomic, strong) NSMutableArray *detailRequests;
@property (nonatomic, strong) NSMutableArray *details;
@property (nonatomic, strong) PSObserverVector *observerVector;


@end

@implementation PSSessionManager
{
    AFHTTPSessionManager *manager;
}

+ (PSSessionManager *)sharedInstance {
    static PSSessionManager *sessionManager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!sessionManager) {
            sessionManager = [[PSSessionManager alloc] init];
        }
    });
    return sessionManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initializeSession];
        self.observerVector = [[PSObserverVector alloc] init];
        self.details = [NSMutableArray array];
        self.detailRequests = [NSMutableArray array];

    }
    return self;
}

- (void)dealloc {
    
}

- (void)setPassedPrisonerDetails:(NSArray *)passedPrisonerDetails {
    _passedPrisonerDetails = passedPrisonerDetails;
}

- (PSRegistration *)currentRegistration {
    PSRegistration *cRegistration = nil;
    if (self.selectedPrisonerIndex >= 0 && self.selectedPrisonerIndex < self.passedPrisonerDetails.count) {
        PSPrisonerDetail *selectedDetail = self.passedPrisonerDetails[self.selectedPrisonerIndex];
        for (PSRegistration *registration in self.session.registrations) {
            if ([registration.prisonerId isEqualToString:selectedDetail.prisonerId]) {
                cRegistration = registration;
                break;
            }
        }
    }
    return cRegistration;
   
}
- (PSPrisonerDetail *)currenPrisonerDetail {
    PSPrisonerDetail *cPrisonerDetail = nil;
    NSInteger index = self.selectedPrisonerIndex;
    NSArray *details = self.passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        cPrisonerDetail = details[index];
    }
    return cPrisonerDetail;
}

-(BOOL)isCheck{
    //审核版本第一次进入没有监狱--审核账号
    BOOL result = NO;
    if (self.currenPrisonerDetail) {
        if ([self.currenPrisonerDetail.jailName isEqualToString:@"演示监狱"]&&PRODUCE==1) {
            result = YES;
        }
    } 
    return result;
}

- (void)addObserver:(id<PSSessionObserver>)observer {
    [self.observerVector addObserver:observer];
}

- (void)removeObserver:(id<PSSessionObserver>)observer {
    [self.observerVector removeObserver:observer];
}

- (void)synchronizeDetailsCompletion:(SynchronizePrisonerDetailsCompletion)completion {
    [self.detailRequests removeAllObjects];
    [self.details removeAllObjects];

    for (PSRegistration *registration in self.passedPrisoners) {
        PSPrisonerDetailRequest *detailRequest = [PSPrisonerDetailRequest new];
        detailRequest.prisonerId = registration.prisonerId;
        @weakify(self)
        @weakify(detailRequest)
        [detailRequest send:^(PSRequest *request, PSResponse *response) {
            @strongify(self)
            @strongify(detailRequest)
            PSPrisonerDetailResponse *detailResponse = (PSPrisonerDetailResponse *)response;
            if (detailResponse.code == 200) {
                if (detailResponse.prisonerDetail) {
                    [self.details addObject:detailResponse.prisonerDetail];

                }
            }
            [self.detailRequests removeObject:detailRequest];
            if (self.detailRequests.count == 0) {
                self.passedPrisonerDetails = self.details;
                if (completion) {
                    completion();
                }
            }
        } errorCallback:^(PSRequest *request, NSError *error) {
            @strongify(self)
            [self.detailRequests removeObject:detailRequest];
            if (self.detailRequests.count == 0) {
                self.passedPrisonerDetails = self.details;
                if (completion) {
                    completion();
                }
            }
        }];
        [self.detailRequests addObject:detailRequest];
    }
}

- (void)synchronizePrisonerDetailsCompletion:(SynchronizePrisonerDetailsCompletion)completion {
    //刷新用户绑定的罪犯列表，目前只能使用登录接口刷新，比较尴尬
    @weakify(self)
    [self autoLogin:^(BOOL completed) {
        @strongify(self)
        [self synchronizeDetailsCompletion:completion];
      
    }];
}

- (void)synchronizeUserBalance {
    @weakify(self)
    [self autoLogin:^(BOOL completed) {
        @strongify(self)
        [self.observerVector notifyObserver:@selector(userBalanceDidSynchronized)];
    }];
}

- (void)initializeSession {
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
}

- (void)setSession:(PSUserSession *)session {
    _session = session;
    NSMutableArray *passedPrisoners = [NSMutableArray array];
    PSLoginStatus status = PSLoginNone;
    if (_session) {
        if([_session.status isEqualToString:@"PASSED"] ){         //已认证
             status = PSLoginPassed;
        }else if ([_session.status isEqualToString:@"PENDING"]) { //待审核
            if (status < PSLoginPassed) {
                status = PSLoginPending;
            }
        }else if ([_session.status isEqualToString:@"DENIED"]) { //未认证
            if (status < PSLoginDenied) {
                status = PSLoginDenied;
            }
        }
        
        for (PSRegistration *registration in _session.registrations) {
            if ([registration.status isEqualToString:@"PASSED"]) {
                //status = PSLoginPassed;
                [passedPrisoners addObject:registration];
            }else if ([registration.status isEqualToString:@"PENDING"]) {
                if (status < PSLoginPassed) {
                    //status = PSLoginPending;
                }
            }else if ([registration.status isEqualToString:@"DENIED"]) {
                if (status < PSLoginDenied) {
                    //status = PSLoginDenied;
                }
            }
        }
    }
    _passedPrisoners = passedPrisoners;
    _loginStatus = status;
 
}

- (void)doLogin:(SessionCompletion)completion {
    
//    if (token) {
//        PSSessionViewController *sessionViewController = [[PSSessionViewController alloc] init];
//        [sessionViewController setCallback:^(BOOL successful, id session) {
//            if (successful) {
//                self.session = session;
//                [PSCache addCache:AppUserSessionCacheKey obj:session];
//            }
//            if (completion) {
//                    completion(YES);
//                }
//        }];
//
//    } else {
        PSLoginStatus status = self.loginStatus;
//        if (status == PSLoginPending) {      //待审核
//            PSSessionViewController *sessionViewController = [[PSSessionViewController alloc] init];
//            [sessionViewController initialize];
//            [sessionViewController setCallback:^(BOOL successful, id session) {
//                if (successful) {
//                    self.session = session;
//                    [PSCache addCache:AppUserSessionCacheKey obj:session];
//                }
//                if (!self.session) {
//                    if (completion) {
//                        completion(YES);
//                    }
//                }
//                if (self.loginStatus == PSLoginPassed) {
//                    if (completion) {
//                        completion(YES);
//                    }
//                }
//
//                else if (self.loginStatus == PSLoginDenied||self.loginStatus == PSLoginNone||self.loginStatus == PSLoginPending){
//                    if (completion) {
//                        completion(YES);
//                    }
//
//                }
//            }];
//            [UIApplication sharedApplication].keyWindow.rootViewController = sessionViewController;
//        }else
            if(status == PSLoginPassed||status == PSLoginPending||status == PSLoginDenied) { //已认证
            if (completion) {
                completion(YES);
            }
        }
        else{
            PSSessionViewController *sessionViewController = [[PSSessionViewController alloc] init];
            [sessionViewController initialize];
            [sessionViewController setCallback:^(BOOL successful, id session) {
                if (successful) {
                    self.session = session;
                    [PSCache addCache:AppUserSessionCacheKey obj:session];
                }
                if (!self.session) {
                    if (completion) {
                        completion(YES);
                    }
                }
                if (self.loginStatus == PSLoginPassed) {
                    if (completion) {
                        completion(YES);
                    }
                }
                else if (self.loginStatus == PSLoginDenied||self.loginStatus == PSLoginNone||self.loginStatus == PSLoginPending){
                    if (completion) {
                        completion(YES);
                    }
                    
                }
            }];
            [UIApplication sharedApplication].keyWindow.rootViewController = sessionViewController;
        }
    //}
}

- (void)autoLogin:(SessionCompletion)completion {
    
    manager=[AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.f;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    NSString*url=[NSString stringWithFormat:@"%@/families/validTourist",ServerUrl];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"]integerValue] == 200) {
            if (responseObject[@"data"]) {
                self.session =[[PSUserSession alloc]initWithDictionary:responseObject[@"data"] error:nil];
                 [PSCache addCache:AppUserSessionCacheKey obj:self.session];
            }
        }
        if (completion) {
            completion(YES);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(YES);
        }
    }];
}
//清除人脸识别本地数据
- (void)clearFaceData {
    ASFRManager *manger = [[ASFRManager alloc] init];
    NSArray *ary = [manger allPersons];
    for (ASFRPerson *person in ary) {
        int personid = (int)person.Id;
        [manger deletePerson:personid];
    }
}
- (void)
doLogout {
    
    [self clearFaceData];
    [PSCache removeCacheForKey:AppUserSessionCacheKey];
    self.session = nil;
    [[PSIMMessageManager sharedInstance] logoutIM];
    [[PSLaunchManager sharedInstance] launchFromLogout];
    [self clearAllUserDefaultsData];
}
    
- (void)clearAllUserDefaultsData{
    //版本号
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults*userDefaults = [NSUserDefaults  standardUserDefaults];
    //引导页标志KEY
    NSString *guideKey = [NSString stringWithFormat:@"%@_%@",localVersion,@"DID_GUIDE_KEY"];
    
    NSDictionary*dic = [userDefaults  dictionaryRepresentation];
    for(id key in dic) {
        //版本更新的不去掉 // //1.2.13版本强制退出标志不去掉 //电话号码不去掉
        if (![key isEqualToString:localVersion]&&
            ![key isEqualToString:forceLogoutKey]&&
            ![key isEqualToString:guideKey]&&
            ![key isEqualToString:@"phoneNumber"]) {
            [userDefaults  removeObjectForKey:key];
        }
    }
    [userDefaults  synchronize];
}
    
#pragma mark -
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    [self doLogin:^(BOOL completed) {
        if (completion) {
            completion(completed);
        }
    }];
}

@end
