//
//  PSProLoginViewController.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectIndex)(NSInteger selectIndex);//编码
typedef void (^SelectValue)(NSString *selectValue);//数值


@interface ZJBLStoreShopTypeAlert : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *titles;//string数组
@property (nonatomic, assign) NSInteger selectedPrisonerIndex;
@property (nonatomic, strong) UILabel *titleLabel;//标题label
@property (nonatomic, strong) UIButton *closeButton;//关闭按钮

@property (nonatomic, copy) SelectIndex selectIndex;
@property (nonatomic, copy) SelectValue selectValue;

/*!
 * @abstract 创建弹窗下拉列表类方法
 *
 * @param title 下拉框标题
 * @param titles 下拉框显示的string数组
 * @param selectIndex 选择的index
 * @param selectValue 选择的string
 * @param showCloseButton 显示关闭按钮则关闭点击列表外remove弹窗的功能
 *
 */
+ (ZJBLStoreShopTypeAlert *)showWithTitle:(NSString *)title
                                   titles:(NSArray *)titles
                              selectIndex:(SelectIndex)selectIndex
                              selectValue:(SelectValue)selectValue
                          showCloseButton:(BOOL)showCloseButton;

@end
