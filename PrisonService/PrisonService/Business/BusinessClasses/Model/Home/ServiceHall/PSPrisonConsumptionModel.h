//
//  5000 PSPrisonConsumptionModel.h
//  PrisonService
//
//  Created by kky on 2019/3/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol PSPrisonConsumptionModel <NSObject>
@end

@interface PSPrisonConsumptionModel : JSONModel
@property(nonatomic,strong)NSString<Optional>  *address;
@property(nonatomic,strong)NSString<Optional>  *minBalance;
@property(nonatomic,strong)NSString<Optional>  *balance;
@property(nonatomic,strong)NSString<Optional>  *month;
@property(nonatomic,strong)NSString<Optional>  *prisonerNumber;
@property(nonatomic,strong)NSString<Optional>  *consumeAt;
@property(nonatomic,strong)NSString<Optional>  *consume;
@property(nonatomic,strong)NSString<Optional>  *id;
@property(nonatomic,strong)NSString<Optional>  *consumeType;
@property(nonatomic,strong)NSString<Optional>  *consumeTotal;


@end


