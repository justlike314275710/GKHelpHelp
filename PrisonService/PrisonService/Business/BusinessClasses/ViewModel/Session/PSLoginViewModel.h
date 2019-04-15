//
//  PSLoginViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSUserSession.h"

@interface PSLoginViewModel : PSViewModel
@property (nonatomic , assign) NSInteger code;
@property (nonatomic,strong)  NSString *PhoneNewNumber;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *cardID;
@property (nonatomic, strong) NSString *message;
@property (nonatomic ,strong) NSString *messageCode;
@property (nonatomic, strong, readonly) PSUserSession *session;
@property (nonatomic, assign) BOOL agreeProtocol;

- (void)loginCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;


- (void)requestCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)checkPhoneDataWithCallback:(CheckDataCallback)callback;
- (void)checkCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)checkWhiteListCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;


@end
