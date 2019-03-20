//
//  PSNewsRequest.h
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessRequest.h"
#import "PSNewsResponse.h"

typedef NS_ENUM(NSInteger, PSNewsType) {
    PSNewsPrisonPublic = 1,//狱务公开
    PSNewsWorkDynamic = 2, //工作动态
    PSNewsPublicShow = 3,  //公示信息
    PSNesJxJs = 4, //减刑假释
    PSNesZyjwzx = 5, //暂予监外执行
    PSNesShbj = 6, //社会帮教
    
};

@interface PSNewsRequest : PSBusinessRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) PSNewsType type;
@property (nonatomic, strong) NSString *jailId;

@end
