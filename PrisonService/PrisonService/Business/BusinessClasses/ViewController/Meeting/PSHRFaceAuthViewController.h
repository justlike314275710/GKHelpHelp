//
//  PSHRFaceAuthViewController.h
//  PrisonService
//
//  Created by kky on 2019/12/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSMeetingViewModel.h"
typedef void(^FaceAuthCompletion)(BOOL successful);
@interface PSHRFaceAuthViewController : PSBusinessViewController
@property(nonatomic,copy)  FaceAuthCompletion completion;
@property(nonatomic,strong)PSMeetingViewModel *meetViewModel;


@end


