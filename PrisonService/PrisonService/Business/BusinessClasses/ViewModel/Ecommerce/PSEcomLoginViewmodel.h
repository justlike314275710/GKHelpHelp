//
//  ecomLoginViewmodel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"

@interface PSEcomLoginViewmodel : PSViewModel
@property (nonatomic, strong) NSString*username;
@property (nonatomic, strong) NSString*password;
@property (nonatomic, strong) NSString*grant_type;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic , strong) NSString *token;
@property (nonatomic , strong) NSString *refresh_token;
-(void)postEcomLogin:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

-(void)postRefreshEcomLogin:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;


-(void)postSureChangePhone:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

//获取IM信息
- (void)loginGetImifnoComplete:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
@end
