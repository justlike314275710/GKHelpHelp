//
//  PrisonOpenCell.h
//  PrisonService
//
//  Created by kky on 2019/2/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSPrisonOpenCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *arrowImg;
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
