//
//  PSMeetJailsnnmeViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/18.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSUserSession.h"
@interface PSMeetJailsnnmeViewModel : PSViewModel
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic , strong) NSString *jailsSting;
@property (nonatomic , strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *prisons;
- (void)requestMeetJailsterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)requestMeetAllJailsterCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
