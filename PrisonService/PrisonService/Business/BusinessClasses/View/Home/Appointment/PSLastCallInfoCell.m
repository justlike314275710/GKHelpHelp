//
//  PSLastCallInfoCell.m
//  PrisonService
//
//  Created by calvin on 2018/4/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLastCallInfoCell.h"

@implementation PSLastCallInfoCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
//        self.textLabel.font = AppBaseTextFont2;
//        self.textLabel.textColor = AppBaseTextColor2;
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(13,35, self.mj_w, 20)];
        _titleLab.font = AppBaseTextFont2;
        _titleLab.textColor = AppBaseTextColor2;
        [self addSubview:_titleLab];
        
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
