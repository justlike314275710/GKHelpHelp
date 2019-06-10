//
//  PSMeettingHistory.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol PSMeettingHistory <NSObject>
@end

@interface PSMeettingHistory : JSONModel
@property (nonatomic, strong) NSString<Optional> *meetingTime;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *prisonerId;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *remarks;
@property (nonatomic, strong) NSString<Optional> *status;
@property (nonatomic, strong) NSString<Optional> *applicationDate;
@property (nonatomic, strong) NSString<Optional> *historyId;
//@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *canCancel;
@property (nonatomic, strong) NSString<Optional> *address;
@property (nonatomic, strong) NSString<Optional> *batch;
@property (nonatomic, strong) NSString<Optional> *window;
@end

