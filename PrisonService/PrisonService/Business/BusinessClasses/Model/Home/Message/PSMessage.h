//
//  PSMessage.h
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

typedef NS_ENUM(NSInteger, PSMessageType) {
    PSMessageRegister = 1,//注册消息
    PSMessageMeeting = 2,//会见消息
    PSMessageLocalMeeting = 3,//实地会见
    PSMessageArticleMessage = 4,//文章审核

};

@protocol PSMessage<NSObject>

@end

@interface PSMessage : JSONModel

@property (nonatomic, strong) NSString<Ignore> *title;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *applicationDate;
@property (nonatomic, strong) NSString<Optional> *createdAt;
@property (nonatomic, strong) NSString<Optional> *status;
@property (nonatomic, assign) PSMessageType type;

@end
