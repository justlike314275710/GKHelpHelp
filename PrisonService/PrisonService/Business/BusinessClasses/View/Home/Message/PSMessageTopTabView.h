//
//  PSMessageTopTabView.h
//  PrisonService
//
//  Created by kky on 2019/9/5.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLButton;

@protocol PSMessageTopTabViewDelegate <NSObject>
/// 点击item

/**

 @param button 点击的按钮
 @param index  当前inex
 @param lastindex 上个index
 */
- (void)pagescrollMenuViewItemOnClick:(YLButton *)button index:(NSInteger)index lastindex:(NSInteger)lastindex;


@end

NS_ASSUME_NONNULL_BEGIN

@interface PSMessageTopTabView : UIView
@property(nonatomic,strong)UIView*TopTabHeight;
@property(nonatomic,strong)NSArray *viewControllers;
@property(nonatomic,strong)NSArray *numbers;
- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
       normalImages:(NSArray *)normalImages
     selectedImages:(NSArray *)selectedImages
       currentIndex:(NSInteger)currentIndex
           delegate:(id<PSMessageTopTabViewDelegate>)delegate
     viewController:(UIViewController *)viewController
            numbers:(NSArray *)numbers;




@end

NS_ASSUME_NONNULL_END
