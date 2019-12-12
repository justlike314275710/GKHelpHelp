//
//  PSURLMacros.h
//  PrisonService
//
//  Created by kky on 2019/5/9.
//  Copyright © 2019年 calvin. All rights reserved.
//

#ifndef PSURLMacros_h
#define PSURLMacros_h

#pragma mark - ——————— 详细接口地址     ————————
//修改头像
#define URL_upload_avatar @"/users/me/avatar"
//获取我的头像
#define URL_get_userAvatar @"/users/me/avatar"
//获取用户头像
#define URL_get_Avatar @"/users/by-username/avatar?username="

#pragma mark - ——————— 公共服务接口     ————————
//注册手机用户
#define URL_public_users_of_mobile @"/users/of-mobile"
//新增加意见反馈
#define URL_feedbacks_add     @"/feedbacks"
#pragma mark - ——————— 狱务通业务接口    ———————
//文章举报
#define URL_api_reportArticle     @"/api/article/reportArticle"


#endif /* PSURLMacros_h */
