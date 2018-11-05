//
//  PSRemittanceRecordCell.h
//  PrisonService
//
//  Created by kky on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemittanceRecode.h"

@interface PSRemittanceRecordCell : UITableViewCell
@property (nonatomic ,strong) UILabel *amountLab;
@property (nonatomic ,strong) UILabel *payStateLab;
@property (nonatomic ,strong) UILabel *nameLab;
@property (nonatomic ,strong) UILabel *timeLab;
@property (nonatomic ,strong) UILabel *numbersLab;
@property (nonatomic ,strong) RemittanceRecode *model;


@end


