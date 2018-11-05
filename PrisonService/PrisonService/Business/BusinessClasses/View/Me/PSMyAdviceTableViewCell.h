//
//  PSMyAdviceTableViewCell.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/11/1.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSMyAdviceTableViewCell : UITableViewCell
@property (nonatomic,strong) UIImageView *headImg;
@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UILabel *moneyLab;
@property (nonatomic,strong) UILabel *timeLab;
@property (nonatomic,strong) UILabel *contentLab;
@property (nonatomic,strong) UIImageView *ratingImg;

@property (nonatomic , strong) UIButton *statusButton;
@end
