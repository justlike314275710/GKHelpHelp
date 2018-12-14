//
//  PSServiceCentreTableViewCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/18.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSServiceCentreTableViewCell.h"

@implementation PSServiceCentreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self renderContents];
    }
    return self;
}

- (void)renderContents {
    CGFloat horSidePadding = 15;
    CGFloat verSidePadding = 15;
    UIView *mainView = [UIView new];
    [self addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    CGFloat qWidth = 150;
    CGFloat qHeight = 15;
     _serviceTitleLabel = [UILabel new];
     _serviceTitleLabel.font = FontOfSize(12);
     _serviceTitleLabel.textAlignment = NSTextAlignmentLeft;
     _serviceTitleLabel.textColor =[UIColor blackColor];
    NSString*common_function=
    NSLocalizedString(@"common_function", @"常用功能");
    _serviceTitleLabel.text=common_function;
    [mainView addSubview: _serviceTitleLabel];
    [ _serviceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horSidePadding);
        make.top.mas_equalTo(verSidePadding);
        make.width.mas_equalTo(qWidth);
        make.height.mas_equalTo(qHeight);
    }];
    
    NSString*family_phone=NSLocalizedString(@"family_phone", nil);
    NSString*local_meetting=NSLocalizedString(@"local_meetting", nil);
    NSString*e_mall=NSLocalizedString(@"e_mall", nil);
    NSString*complain_advice=NSLocalizedString(@"complain_advice", nil);
    
    NSArray *arr = @[family_phone,local_meetting,e_mall,complain_advice];
    NSArray *imgArr = @[@"亲情电话",@"实地会见",@"电子商务",@"投诉建议"];
    CGFloat btnW = SCREEN_WIDTH / arr.count;
    for (int i = 0; i < arr.count; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * btnW, CGRectGetMaxY(_serviceTitleLabel.frame) + 35, btnW, 60)];
        [button setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
        [button setTitle:arr[i] forState:UIControlStateNormal];
        [button setImage:[UIImage R_imageNamed:imgArr[i]] forState:UIControlStateNormal];
        button.titleLabel.textAlignment =NSTextAlignmentCenter;
        //NSTextAlignmentCenter;
        button.titleLabel.font = FontOfSize(12);
        button.titleLabel.numberOfLines=0;
        [button addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        //注意就是这个方法,把我们的普通按钮转成我们需要的按钮
        [self initButton:button];
        [mainView addSubview:button];
        
    }
    

}


-(void)initButton:(UIButton*)btn{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height + 20 ,-btn.imageView.frame.size.width, 0.0,0.0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,10, -btn.titleLabel.bounds.size.width)];
    if ([NSObject judegeIsVietnamVersion]) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0,(btn.width- btn.imageView.width)/2,10, -btn.titleLabel.bounds.size.width)];
    }
}

- (void)checkAction:(UIButton *)sender {
    [_delegate choseTerm:sender.tag];
}  


@end
