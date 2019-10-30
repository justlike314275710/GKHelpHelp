//
//  PSArticleDetailModel.h
//  PrisonService
//
//  Created by kky on 2019/9/12.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol PSArticleDetailModel<NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface PSArticleDetailModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *username;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *praiseNum;
@property (nonatomic, strong) NSString<Optional> *clientNum;
@property (nonatomic, strong) NSString<Optional> *collectNum;
@property (nonatomic, strong) NSString<Optional> *createdAt;
@property (nonatomic, strong) NSString<Optional> *updatedAt;
@property (nonatomic, strong) NSString<Optional> *status;
@property (nonatomic, strong) NSString<Optional> *finish;
@property (nonatomic, strong) NSString<Optional> *auditAt;
@property (nonatomic, strong) NSString<Optional> *shelfAt;
@property (nonatomic, strong) NSString<Optional> *shelfReason;
@property (nonatomic, strong) NSString<Optional> *rejectReason;
@property (nonatomic, strong) NSString<Optional> *articleType;
@property (nonatomic, strong) NSString<Optional> *type;
@property (nonatomic, strong) NSString<Optional> *penName;
@property (nonatomic, strong) NSString<Optional> *publishAt;
@property (nonatomic, strong) NSString<Optional> *articleTypeName;
@property (nonatomic, strong) NSString<Optional> *finishName;
@property (nonatomic, strong) NSString<Optional> *enableShelf;
@property (nonatomic, strong) NSString<Optional> *publishTypeName;
@property (nonatomic, strong) NSString<Optional> *ispraise;
@property (nonatomic, strong) NSString<Optional> *iscollect;
@property (nonatomic, strong) NSString<Optional> *isreport;

@end

NS_ASSUME_NONNULL_END
