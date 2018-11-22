//
//  PSPrisonerManageViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSHomeViewModel.h"

typedef void(^PrisonerDidManaged)();

@interface PSPrisonerManageViewController : PSBusinessViewController

@property (nonatomic, copy) PrisonerDidManaged didManaged;
@property (nonatomic ,strong) PSPrisonerDetail *prisonerDetail;

@end
