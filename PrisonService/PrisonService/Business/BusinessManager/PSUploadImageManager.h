//
//  PSUploadImageManager.h
//  PrisonService
//
//  Created by kky on 2019/10/29.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^CheckDataCallback)(BOOL successful, NSString *tips);

@interface PSUploadImageManager : NSObject

@property (nonatomic , assign) NSInteger code;

+ (PSUploadImageManager *)uploadImageManager;

-(void)uploadPublicImages:(UIImage*)images completed:(CheckDataCallback)callback;

@end

NS_ASSUME_NONNULL_END
