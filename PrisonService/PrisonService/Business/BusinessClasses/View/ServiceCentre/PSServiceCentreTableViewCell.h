//
//  PSServiceCentreTableViewCell.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/18.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSServiceCentreTableViewCellDelegate <NSObject>
- (void)choseTerm:(NSInteger)tag;
@end


@interface PSServiceCentreTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *serviceTitleLabel;
@property (nonatomic, strong, readonly) UIButton *phoneButton;
@property (nonatomic, strong, readonly) UIButton *localMeetingButton;
@property (nonatomic, strong, readonly) UIButton *EcommerceButton;
@property (nonatomic, strong, readonly) UIButton *complaintButton;
@property (nonatomic, assign) id<PSServiceCentreTableViewCellDelegate> delegate;
@end
