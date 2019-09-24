//
//  PSPublicArticleModel.h
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol PSPublicArticleModel<NSObject>

@end
NS_ASSUME_NONNULL_BEGIN

@interface PSPublicArticleModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *familyId;
@property (nonatomic, strong) NSString<Optional> *disabledReason;
@property (nonatomic, strong) NSString<Optional> *accountName;
@property (nonatomic, strong) NSString<Optional> *isEnabled;
@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *pseudonym;
@end

NS_ASSUME_NONNULL_END
