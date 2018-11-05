//
//  PSFamilyRemittanceViewModel.h
//  PrisonService
//
//  Created by kky on 2018/10/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBasePrisonerViewModel.h"

@interface PSFamilyRemittanceViewModel : PSBasePrisonerViewModel

@property (nonatomic,strong,readonly) NSArray *criminals;
@property (nonatomic,strong) NSString *money;

- (void)checkDataWithCallback:(CheckDataCallback)callback;


@end


