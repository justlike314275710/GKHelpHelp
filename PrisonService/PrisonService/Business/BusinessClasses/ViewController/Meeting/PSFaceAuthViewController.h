//
//  PSFaceAuthViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
@class PSFaceAuthViewController;
typedef void(^FaceAuthCompletion)(BOOL successful);

@interface PSFaceAuthViewController : PSBusinessViewController

@property (nonatomic, copy) FaceAuthCompletion completion;
@property (nonatomic, strong) NSString*iconUrl;

@end
