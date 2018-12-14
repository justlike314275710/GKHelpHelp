//
//  PSServicePrisonsCell.h
//  PrisonService
//
//  Created by kky on 2018/11/22.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetJails.h"

typedef void (^BindingBlock)();
typedef void (^ChangeBlock)(MeetPrisonserModel *meetjails);

@interface PSServicePrisonsCell : UICollectionViewCell

@property (nonatomic,strong)NSArray *Prisons;
@property (nonatomic,copy)BindingBlock bingBlock;
@property (nonatomic,copy)ChangeBlock changeBlock;

@end


