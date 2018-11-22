//
//  UpDateModel.h
//  PrisonService
//
//  Created by kky on 2018/11/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>


@interface UpDateModel : JSONModel

#pragma mark - updateModel
//
/***
 iOS版本更新获取接口：https://www.yuwugongkai.com/ywgk-app/api/versions/page
 id  = 3
 versionCode 版本名，如1.0.1
 versionNumber 版本号，如10
 download  更新地址
 isForce 是否强制更新  1为强制更新  
 
 ***/
@property (nonatomic,retain) NSString *createdAt;
@property (nonatomic,retain) NSString *des; //description
@property (nonatomic,retain) NSString *download;
@property (nonatomic,retain) NSString *id;
@property (nonatomic,retain) NSString *isForce;
@property (nonatomic,retain) NSString *typeId;
@property (nonatomic,retain) NSString *updatedAt;
@property (nonatomic,retain) NSString *versionCode;
@property (nonatomic,retain) NSString *versionNumber;

@end

