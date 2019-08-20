//
//  PSPublishScuessViewController.m
//  PrisonService
//
//  Created by kky on 2019/8/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPublishScuessViewController.h"

@interface PSPublishScuessViewController ()

@end

@implementation PSPublishScuessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发表文章";
    [self p_setUI];
}

-(void)p_setUI{
    UIImageView *iconImg = [[UIImageView alloc] init];
    iconImg.image = IMAGE_NAMED(@"发表文章审核图");
    [self.view addSubview:iconImg];
    [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(65);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(155);
        make.height.mas_equalTo(180);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"您已成功提交内容，请耐心等待审核";
    label.textColor = UIColorFromRGB(102, 102,102);
    label.font = FontOfSize(14);
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImg.mas_bottom).offset(25);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(21);
    }];
    
    UIButton *iKnowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [iKnowBtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [iKnowBtn setImage:IMAGE_NAMED(@"我知道了") forState:UIControlStateNormal];
    [self.view addSubview:iKnowBtn];
    [iKnowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).offset(58);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(89);
    }];
    
}

- (void)action:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
