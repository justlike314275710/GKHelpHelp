//
//  PSInstructionsDataView.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSInstructionsDataView.h"

@implementation PSInstructionsDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
         [self renderContents];
    }
    return self;
}

- (void)renderContents {
    // TODO: implement
    
    UIView*view=[UIView new];
    //view.backgroundColor=[UIColor redColor];
    view.frame=CGRectMake(15, 0, SCREEN_WIDTH-30,45);
    //[cell addSubview:view];
    [self addSubview:view];
    UIButton * onebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    onebutton.frame = CGRectMake(0.f, 15.f, 10.f, 10.f);
    onebutton.layer.cornerRadius = 5;
    onebutton.layer.masksToBounds = YES;
    onebutton.backgroundColor=UIColorFromRGB(255, 138, 7);
    [view addSubview:onebutton];
    NSString*meet_PENDING=NSLocalizedString(@"meet_PENDING", @"审核中");
    UIButton * twobutton = [UIButton new];
    twobutton.titleLabel.lineBreakMode = 0;
    twobutton.frame = CGRectMake(0.f, 10.f, SCREEN_WIDTH/5-10, 20.f);
    [twobutton setTitle:meet_PENDING forState:UIControlStateNormal];
    [twobutton setTitleColor:AppBaseTextColor2 forState:UIControlStateNormal];
    twobutton.titleLabel.font=FontOfSize(10);
    [view addSubview:twobutton];
    
    UIButton * threebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    threebutton.frame = CGRectMake(SCREEN_WIDTH/5, 15.f, 10.f, 10.f);
    threebutton.layer.cornerRadius = 5;
    threebutton.layer.masksToBounds = YES;
    threebutton.backgroundColor=UIColorFromRGB(0, 142, 60);
    [view addSubview:threebutton];
    NSString*meet_PASSED=NSLocalizedString(@"meet_PASSED", @"待会见");
    UIButton * fourbutton = [UIButton new];
    fourbutton.titleLabel.lineBreakMode = 0;
    fourbutton.frame = CGRectMake(SCREEN_WIDTH/5, 10.f, SCREEN_WIDTH/5-10, 20.f);
    [fourbutton setTitle:meet_PASSED forState:UIControlStateNormal];
    [fourbutton setTitleColor:AppBaseTextColor2 forState:UIControlStateNormal];
    fourbutton.titleLabel.font=FontOfSize(10);
    [view addSubview:fourbutton];

    UIButton * fivebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fivebutton.frame = CGRectMake(SCREEN_WIDTH*0.4, 15.f, 10.f, 10.f);
    fivebutton.layer.cornerRadius = 5;
    fivebutton.layer.masksToBounds = YES;
    fivebutton.backgroundColor=[UIColor redColor];
    //fivebutton.backgroundColor=UIColorFromRGB(83, 119, 185);
    [view addSubview:fivebutton];
    NSString*meet_DENIED=NSLocalizedString(@"meet_DENIED", @"已拒绝/已取消");
    //NSString*meet_FINISHED=NSLocalizedString(@"meet_FINISHED", @"已完成");
    UIButton * sixbutton = [UIButton new];
    sixbutton.titleLabel.lineBreakMode = 0;
    sixbutton.frame = CGRectMake(SCREEN_WIDTH*0.4+5, 10.f, SCREEN_WIDTH/5-10, 20.f);
    [sixbutton setTitle:meet_DENIED forState:UIControlStateNormal];
    [sixbutton setTitleColor:AppBaseTextColor2 forState:UIControlStateNormal];
    sixbutton.titleLabel.font=FontOfSize(10);
    [view addSubview:sixbutton];
    
    UIButton * sevenbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sevenbutton.frame = CGRectMake(SCREEN_WIDTH*0.6, 15.f, 10.f, 10.f);
    sevenbutton.layer.cornerRadius = 5;
    sevenbutton.layer.masksToBounds = YES;
    sevenbutton.backgroundColor=UIColorFromRGB(153, 153, 153);
    [view addSubview:sevenbutton];
    NSString*meet_EXPIRED=NSLocalizedString(@"meet_EXPIRED", @"已过期");
    UIButton * eightbutton = [UIButton new];
    eightbutton.titleLabel.lineBreakMode = 0;
    eightbutton.frame = CGRectMake(SCREEN_WIDTH*0.6, 10.f, SCREEN_WIDTH/5-10, 20.f);
    [eightbutton setTitle:meet_EXPIRED forState:UIControlStateNormal];
    [eightbutton setTitleColor:AppBaseTextColor2 forState:UIControlStateNormal];
    eightbutton.titleLabel.font=FontOfSize(10);
    [view addSubview:eightbutton];
    
    UIButton * ninebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ninebutton.frame = CGRectMake(SCREEN_WIDTH*0.8-10, 15.f, 10.f, 10.f);
    ninebutton.layer.cornerRadius = 5;
    ninebutton.layer.masksToBounds = YES;
    ninebutton.backgroundColor=UIColorFromRGB(83, 119, 185);
    [view addSubview:ninebutton];
    NSString*meet_FINISHED=NSLocalizedString(@"meet_FINISHED", @"已完成");
    UIButton * tenbutton = [UIButton new];
    tenbutton.titleLabel.lineBreakMode = 0;
    tenbutton.frame = CGRectMake(SCREEN_WIDTH*0.8-10, 10.f, SCREEN_WIDTH/5-10, 20.f);
    [tenbutton setTitle:meet_FINISHED forState:UIControlStateNormal];
    [tenbutton setTitleColor:AppBaseTextColor2 forState:UIControlStateNormal];
    tenbutton.titleLabel.font=FontOfSize(10);
    [view addSubview:tenbutton];
}
@end
