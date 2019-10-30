//
//  PSAllMessageViewController.h
//  PrisonService
//
//  Created by kky on 2019/9/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSPrisonerDetail.h"
#import "PSMessageCountModel.h"
typedef void (^BackBlock)();

NS_ASSUME_NONNULL_BEGIN

@interface PSAllMessageViewController : PSBusinessViewController

@property (nonatomic,strong)PSPrisonerDetail *prisonerDetail;
@property (nonatomic,strong)PSMessageCountModel *model;
@property (nonatomic,copy)BackBlock backBlock;
-(void)scrollviewItemIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
