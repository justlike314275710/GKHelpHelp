//
//  PSJail.h
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

@protocol PSJail
@end

@interface PSJail : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;

@end
