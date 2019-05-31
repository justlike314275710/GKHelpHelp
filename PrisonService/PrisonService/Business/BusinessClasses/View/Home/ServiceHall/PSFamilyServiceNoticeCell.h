//
//  PSFamilyServiceNoticeCell.h
//  PrisonService
//
//  Created by kky on 2019/5/30.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLabel.h"


@interface PSFamilyServiceNoticeCell : UITableViewCell
@property (nonatomic, strong, readonly) UIImageView*iconView;
@property (nonatomic, strong, readonly) UILabel *iconLable;
@property (nonatomic, strong, readonly) UIButton*statusButton;
@property (nonatomic, strong, readonly) UIButton *cancleButton;


@property (nonatomic, strong, readonly) PSLabel *otherTextLabel;
@property (nonatomic, strong, readonly) UILabel *otherLabel;

@property (nonatomic, strong) UILabel *prisonNameLab;       //监狱名称
@property (nonatomic, strong) UILabel *prisonNameTextLab;   //监狱名称
@property (nonatomic, strong) UILabel *prisonNumberLab;     //囚号
@property (nonatomic, strong) UILabel *prisonNumberTextLab; //囚号
@property (nonatomic, strong, readonly) UILabel *dateLabel; //申请日期
@property (nonatomic, strong, readonly) UILabel *dateTextLabel;


@end


