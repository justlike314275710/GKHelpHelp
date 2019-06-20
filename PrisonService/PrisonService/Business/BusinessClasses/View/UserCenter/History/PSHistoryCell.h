//
//  PSHistoryCell.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLabel.h"


@interface PSHistoryCell : UITableViewCell
@property (nonatomic, strong, readonly) UIImageView*iconView;
@property (nonatomic, strong, readonly) UILabel *iconLable;
@property (nonatomic, strong, readonly) UIButton*statusButton;
@property (nonatomic, strong, readonly) UIButton *cancleButton;
@property (nonatomic, strong, readonly) UILabel *dateTextLabel;
@property (nonatomic, strong, readonly) UILabel *dateLabel;

@property (nonatomic, strong, readonly) PSLabel *otherTextLabel;
@property (nonatomic, strong, readonly) UILabel *otherLabel;

@property (nonatomic, strong) UILabel *prisonerTextLab;  //服刑人员
@property (nonatomic, strong) UILabel *prisonerLab;

@property (nonatomic, strong) UILabel *overDueTextLab; //过期原因
@property (nonatomic, strong) UILabel *overDueLab;

@end
