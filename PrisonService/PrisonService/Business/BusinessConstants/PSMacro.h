//
//  PSMacro.h
//  PrisonService
//
//  Created by calvin on 2018/4/2.
//  Copyright © 2018年 calvin. All rights reserved.
//
#define UIColorFromHexadecimalRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromHexadecimalRGBA(rgbValue,alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

#define UIColorFromRGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define UIColorFromRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define AppBaseTextColor1 (UIColorFromHexadecimalRGB(0x666666))//灰色

#define AppBaseTextColor2 (UIColorFromHexadecimalRGB(0x999999))

#define AppBaseTextColor3 (UIColorFromHexadecimalRGB(0x264c90))//蓝色 主题色

#define AppBaseTextColor4 (UIColorFromHexadecimalRGB(0x7d8da2))

#define AppBaseLineColor (UIColorFromHexadecimalRGB(0xe5e5e5))

//法律咨询部分label字体
#define CFontColor_LawTitle  (UIColorFromHexadecimalRGB(0xF34800)) //[UIColor colorWithHexString:@"F34800"] //Field pla
#define AppBaseTextFont1 (FontOfSize(15))

#define AppBaseTextFont2 (FontOfSize(13))

#define AppBaseTextFont3 (FontOfSize(14))

#define AppBaseBackgroundColor1 [UIColor whiteColor]

#define AppBaseBackgroundColor2 (UIColorFromHexadecimalRGB(0xF9F8FE))

#define FontOfSize(size) [UIFont systemFontOfSize:size]
#define boldFontOfSize(size) [UIFont boldSystemFontOfSize:size] 


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define RELATIVE_HEIGHT_VALUE(value) SCREEN_HEIGHT * value / 667.0

#define RELATIVE_WIDTH_VALUE(value) SCREEN_WIDTH * value / 375.0

#define IS_iPhone_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IMAGE_NAMED(name) [UIImage imageNamed:name]

//获取视图的高
#define GETHEIGHT(view) CGRectGetHeight(view.frame)
//获取视图的宽
#define GETWIDTH(view) CGRectGetWidth(view.frame)
//获取视图的X坐标
#define GETORIGIN_X(view) view.frame.origin.x
//获取视图的Y坐标
#define GETORIGIN_Y(view) view.frame.origin.y
//获取下一个视图的X坐标
#define GETRIGHTORIGIN_X(view) view.frame.origin.x + CGRectGetWidth(view.frame)
//获取下一个视图的Y坐标
#define GETBOTTOMORIGIN_Y(view) view.frame.origin.y + CGRectGetHeight(view.frame)

#define StatusHeight  [[UIApplication sharedApplication] statusBarFrame].size.height

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

//获取屏幕宽高
#define KScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreen_Bounds [UIScreen mainScreen].bounds

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

//View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]
//拼接字符串
#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

//枚举---
typedef NS_ENUM(NSInteger,WritefeedType) {
    PSWritefeedBack,   //app投诉反馈
    PSPrisonfeedBack,  //监狱投诉建议
};

//发送通知
#define KPostNotification(name,obj) [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];

/// PushVC
#define     PushVC(vc)                  {\
[vc setHidesBottomBarWhenPushed:YES];\
[self.navigationController pushViewController:vc animated:YES];\
}

//***********************************************通知*****************************************
//订单状态改变
#define KNotificationOrderStateChange @"KNotificationOrderStateChange"
//新的订单
#define KNotificationNewOrderState @"KNotificationNewOrderState"

#define NotificationNoNetwork @"NotificationNoNetwork"
//获取到地址重新刷新广告
#define KNotificationRefreshAdvertisement @"KNotificationRefreshAdvertisement"
//用户修改头像成功通知
#define KNotificationUserAvaterChangeScuess @"KNotificationUserAvaterChangeScuess"
//刷新我的互动文章
#define KNotificationRefreshInteractiveArticle  @"KNotificationRefreshInteractiveArticle"
//刷新我的收藏
#define KNotificationRefreshCollectArticle    @"KNotificationRefreshMyCollectArticle"
//刷新我的文章
#define KNotificationRefreshMyArticle          @"KNotificationRefreshMyArticle"
//刷新咨询消息
#define KNotificationRefreshzx_message         @"KNotificationRefreshzx_message"
//刷新探视消息
#define KNotificationRefreshts_message         @"KNotificationRefreshts_message"
//文章权限改变通知
#define KNotificationAuthorChange      @"KNotificationAuthorChange"
//刷新互动平台消息
#define KNotificationRefreshhd_message         @"KNotificationRefreshhd_message"

//刷新文章详情
#define KNotificationRefreshArticleDetail       @"KNotificationRefreshArticleDetail"
#define Kuncertified_isLogin @"uncertified_isLogin"   //没认证是否登录提示
//视屏会见通知倒计时
#define KNOtificationMeetingCountdown @"KNOtificationMeetingCountdown"
//视屏会见通知倒计时
#define KNOtificationALLMessageScrollviewIndex @"KNOtificationALLMessageScrollviewIndex"

#ifdef DEBUG
#define PSLog(...) NSLog(__VA_ARGS__);
#else
#define PSLog(...);
#endif
