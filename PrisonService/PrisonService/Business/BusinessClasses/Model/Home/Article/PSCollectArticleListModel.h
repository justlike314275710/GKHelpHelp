//
//  PSCollectArticleListModel.h
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol PSCollectArticleListModel<NSObject>

@end

@interface PSCollectArticleListModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *praise_num;
@property (nonatomic, strong) NSString<Optional> *client_num;
@property (nonatomic, strong) NSString<Optional> *created_at;
@property (nonatomic, strong) NSString<Optional> *is_praise;
@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *pen_name;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *username;


@end

