//
//  PSLocateManager.h
//  PrisonService
//
//  Created by calvin on 2018/5/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSLaunchTask.h"

@interface PSLocateManager : NSObject<PSLaunchTask>

@property (nonatomic, strong, readonly) NSString *province;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, strong, readonly) NSString *lat;
@property (nonatomic, strong, readonly) NSString *lng;

+ (PSLocateManager *)sharedInstance;

@end
