//
//  PSPrisonsManager.h
//  PrisonService
//
//  Created by calvin on 2018/4/3.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSLaunchTask.h"
#import "PSJail.h"
#import "PSSettingCell.h"
@interface PSVisitorManager : NSObject<PSLaunchTask>
@property (nonatomic, strong) NSString *defaultJailId;
@property (nonatomic, strong) NSString *defaultJailName;
@property (nonatomic, strong, readonly) PSJail *visitorJail;



+ (PSVisitorManager *)sharedInstance;

@end


