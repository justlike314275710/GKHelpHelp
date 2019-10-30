//
//  FeedloadImgView.h
//  PrisonService
//
//  Created by kky on 2018/12/19.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FeedloadResultBlock)(NSMutableArray *result); //浏览图片

@interface FeedloadImgView : UIView

@property (nonatomic,strong) NSMutableArray      *dataString;//返回的图片
@property (nonatomic,strong) NSMutableArray      *dataUrlString;//上传返回的URL
@property (nonatomic,copy  ) FeedloadResultBlock feedloadResultBlock;
@property (nonatomic,assign) WritefeedType       feedType;
/**
 @param feedType 反馈类型
 */
- (instancetype)initWithFrame:(CGRect)frame
                        count:(NSInteger)count
                         feedType:(WritefeedType)feedType;



@end

