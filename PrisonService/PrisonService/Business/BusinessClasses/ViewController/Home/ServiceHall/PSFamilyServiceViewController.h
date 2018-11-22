//
//  PSFamilyServiceViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSFamilyServiceViewModel.h"
typedef void(^PrisonerDidManaged)();

@interface PSFamilyServiceViewController : PSBusinessViewController

@property (nonatomic,strong) NSMutableArray *prisons;

@property (nonatomic, copy) PrisonerDidManaged didManaged;

@end
