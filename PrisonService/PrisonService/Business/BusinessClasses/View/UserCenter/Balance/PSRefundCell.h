//
//  PSRefundCell.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSRefundCell : UITableViewCell
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *dateLabel;
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong, readonly) UILabel *payWayLab;
@property (nonatomic, strong, readonly) UILabel *orderNoLab;

@end
