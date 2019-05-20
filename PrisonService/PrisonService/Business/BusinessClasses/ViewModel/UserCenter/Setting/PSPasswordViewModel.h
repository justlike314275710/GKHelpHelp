//
//  PSPasswordViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/20.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSViewModel.h"

@interface PSPasswordViewModel : PSViewModel
@property (nonatomic , strong) NSString *phone_password;

- (void)requestPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
@end
