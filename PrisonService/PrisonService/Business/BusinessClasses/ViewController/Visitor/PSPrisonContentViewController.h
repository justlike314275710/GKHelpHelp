//
//  PSPrisonSelectViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"

typedef void(^VisitorDidSelectedJail)(void);

@interface PSPrisonContentViewController : PSBusinessViewController

@property (nonatomic, copy) VisitorDidSelectedJail selectedJailCallback;

@end
