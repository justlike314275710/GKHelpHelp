//
//  AccountsViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSPrisonerDetail.h"
#import "PSUserSession.h"
@interface AccountsViewModel : PSViewModel
@property (nonatomic, strong) PSUserSession *session;
@property(nonatomic,strong) NSString*blance;
@property(nonatomic,strong) NSString*applicationDate;

- (void)requestAccountsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;//获取相应监狱家属余额

//查询改日期是否能预约视频通话
- (void)requestCheckDataCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;



@end
