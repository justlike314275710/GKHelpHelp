//
//  MeetJails.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/18.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface MeetJails : NSObject
@property (nonatomic , strong) NSString *name;
@property (nonatomic , strong) NSString *prisonerId;
@end

@interface MeetPrisonserModel :JSONModel
@property (nonatomic , strong) NSString *prisonerName;
@property (nonatomic , strong) NSString *jailName;
@property (nonatomic , strong) NSString *prisonerId;
@property (nonatomic , strong) NSString *jailId;


@end


