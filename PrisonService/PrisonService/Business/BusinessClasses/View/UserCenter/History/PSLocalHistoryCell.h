//
//  PSLocalHistoryCell.h
//  PrisonService
//
//  Created by kky on 2019/6/5.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSLocalHistoryCell : UITableViewCell
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

@property (nonatomic, strong) UILabel *overDueTextLab; //过期原因OR窗口
@property (nonatomic, strong) UILabel *overDueLab;

@property (nonatomic, strong) UILabel *adderssTextlab; //监狱地址
@property (nonatomic, strong) UILabel *addersslab;



@end

NS_ASSUME_NONNULL_END
