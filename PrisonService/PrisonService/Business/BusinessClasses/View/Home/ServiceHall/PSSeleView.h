//
//  PSSeleView.h
//  PrisonService
//
//  Created by kky on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^FirmSelectBlock)(NSInteger index);

@interface PSSeleView : UIView

@property (nonatomic,copy) FirmSelectBlock firmSelecteBlock;

- (instancetype)initWithFrame:(CGRect)frame dataList:(NSArray *)datalist index:(NSInteger)index;

- (void)showView;


@end


