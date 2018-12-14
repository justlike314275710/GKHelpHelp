//
//  PSFamilyServiceInfoView.h
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSInteger(^FamilyServiceInfoRows)();
typedef NSString *(^FamilyServiceInfoRowIconName)(NSInteger index);
typedef NSString *(^FamilyServiceInfoRowTitleText)(NSInteger index);
typedef NSString *(^FamilyServiceInfoRowDetailText)(NSInteger index);

@interface PSFamilyServiceInfoView : UIView

@property (nonatomic, strong, readonly) UILabel *prisonerLabel;
@property (nonatomic, strong, readonly) UILabel *guiltyPeriodLabel;
@property (nonatomic, strong, readonly) UILabel *guiltyNameLabel;
@property (nonatomic, strong, readonly) UILabel *startLabel;
@property (nonatomic, strong, readonly) UILabel *endLabel;
@property (nonatomic, strong, readonly) UILabel *extraLabel;
@property (nonatomic, strong, readonly) UILabel *reduceLabel;
@property (nonatomic, strong, readonly) UILabel *lastReduceLabel;
@property (nonatomic, copy) FamilyServiceInfoRows infoRows;
@property (nonatomic, copy) FamilyServiceInfoRowIconName iconNameOfRow;
@property (nonatomic, copy) FamilyServiceInfoRowTitleText titleTextOfRow;
@property (nonatomic, copy) FamilyServiceInfoRowDetailText detailTextOfRow;
@property (nonatomic, copy) NSString *prisonerName;

@end
