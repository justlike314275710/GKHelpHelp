//
//  PSMessageCountModel.h
//  PrisonService
//
//  Created by kky on 2019/9/10.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol PSMessageCountModel<NSObject>

@end

@interface PSMessageCountModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *total;
@property (nonatomic, strong) NSString<Optional> *pointsCount;
@property (nonatomic, strong) NSString<Optional> *pointsUnreadCount;
@property (nonatomic, strong) NSString<Optional> *visitCount;
@property (nonatomic, strong) NSString<Optional> *visitUnreadCount;

@end







