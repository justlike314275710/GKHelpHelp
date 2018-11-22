//
//  PSFamilyServiceViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBasePrisonerViewModel.h"
#import "PSFamilyServiceItem.h"

@interface PSFamilyServiceViewModel : PSBasePrisonerViewModel

@property (nonatomic, strong, readonly) NSArray *familyServiceItems;
@property (nonatomic, strong, readonly) NSArray *otherServiceItems;
@property (nonatomic,strong)NSMutableArray *array;


- (void)requestCommentsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

@end
