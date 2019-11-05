//
//  PSLoginViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSSessionHandler.h"
#import "PSLoginViewModel.h"

@interface PSLoginViewController : PSBusinessViewController<PSSessionHandler>

@property (nonatomic, copy) SessionHandlerCallback callback;

@end
