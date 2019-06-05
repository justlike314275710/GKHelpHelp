//
//  PSFamilyServiceNoticeModel.h
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PSFamilyServiceNoticeModel <NSObject>
@end

@interface PSFamilyServiceNoticeModel : JSONModel
@property(nonatomic,strong)NSString<Optional>  *prisonerNumber;
@property(nonatomic,strong)NSString<Optional>  *familyName;
@property(nonatomic,strong)NSString<Optional>  *businessType;
@property(nonatomic,strong)NSString<Optional>  *jailName;
@property(nonatomic,strong)NSString<Optional>  *remarks;
@property(nonatomic,strong)NSString<Optional>  *status;
@property(nonatomic,strong)NSString<Optional>  *applicationDate;


@end

NS_ASSUME_NONNULL_END
