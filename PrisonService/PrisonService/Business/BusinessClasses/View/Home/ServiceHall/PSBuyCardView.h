//
//  PSBuyCardView.h
//  PrisonService
//
//  Created by kky on 2018/11/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PSBuyModel;
typedef void (^BuySelectBlock)(NSInteger index);

@interface PSBuyCardView : UIView

@property (nonatomic,copy) BuySelectBlock buyBlock;

- (instancetype)initWithFrame:(CGRect)frame buyModel:(PSBuyModel *)buyModel index:(NSInteger)index;

- (void)showView:(UIViewController *)vc;



@end

@interface PSBuyModel : NSObject
@property (nonatomic,copy) NSString *family_members; //家属
@property (nonatomic,copy) NSString *Inmates; //服刑人员
@property (nonatomic,copy) NSString *Prison_name; //监狱名称
@property (nonatomic,assign) CGFloat Amount_of_money; //金额


@end


