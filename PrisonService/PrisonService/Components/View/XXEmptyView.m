//
//  DemoEmptyView.m
//  LYEmptyViewDemo
//
//  Created by liyang on 2017/12/1.
//  Copyright © 2017年 liyang. All rights reserved.
//

#import "XXEmptyView.h"
#import "PSBusinessConstants.h"
@implementation XXEmptyView

+ (instancetype)diyEmptyView{
    
    return [XXEmptyView emptyViewWithImageStr:@"noData"
                                       titleStr:@"暂无数据"
                                      detailStr:@"请稍后再试!"];
}

+ (instancetype)diyEmptyActionViewWithTarget:(id)target action:(SEL)action{

    return [XXEmptyView emptyActionViewWithImageStr:@"noNetwork"
                                             titleStr:@"无网络连接"
                                            detailStr:@"请检查你的网络连接是否正确!"
                                          btnTitleStr:@"重新加载"
                                               target:target
                                               action:action];
}

- (void)prepare{
    [super prepare];
    
    self.autoShowEmptyView = NO;
    
    self.titleLabTextColor = AppBaseTextColor2;
    self.titleLabFont = [UIFont systemFontOfSize:14];
    
    //self.detailLabTextColor = MainColor(80, 80, 80);
}

@end
