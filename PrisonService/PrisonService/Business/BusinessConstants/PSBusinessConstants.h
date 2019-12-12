//
//  PSBusinessConstants.h
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.

#define DEVELOP  0   //开发
#define UAT  1     //测试
#define PRODUCE 1   //生产




#ifdef DEBUG
#else
#define PRODUCE 1    //生产
#endif

#if DEVELOP       //开发
#define ServerDomain @"http://192.168.0.180:8089"
#define H5ServerDomain @"http://120.78.190.101:8085"          //H5 Server
#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app-auth",ServerDomain] //其他环境接口地址
#define EmallUrl @"http://10.10.10.17:805"               //电子商城
#define EmallHostUrl @"http://192.168.0.230:8081"        //认证授权平台
#define ImageDeleteUrl @"http://120.78.190.101:1339/delete/resources"//删除图片接口
#define ConsultationHostUrl @"http://qa.api.legal.prisonpublic.com"
#define UploadServerUrl @"http://120.79.251.238:1339/image-server"


#elif UAT            //测试
#define ServerDomain @"http://47.107.245.151:8022"
#define H5ServerDomain @"http://120.79.251.238:8021" 
#define UploadServerUrl @"http://47.107.245.151:1339/image-server"
#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app",ServerDomain]
#define EmallHostUrl  @"http://qa.api.auth.prisonpublic.com"
#define EmallUrl @"http://10.10.10.16:805"
#define ImageDeleteUrl @"http://120.78.190.101:1339/delete/resources"//删除图片接口
#define ConsultationHostUrl @"http://qa.api.legal.prisonpublic.com"


#elif PRODUCE        //生产
#define ServerDomain @"https://www.yuwugongkai.com"
#define H5ServerDomain @"http://39.108.185.51:8081"
#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app",ServerDomain] //生产
#define EmallUrl @"https://m.trade.prisonpublic.com" //电子商城
#define EmallHostUrl @"https://api.auth.prisonpublic.com"
#define ImageDeleteUrl @"https://www.yuwugongkai.com/image-server/delete/resources"//删除图片接口
#define ConsultationHostUrl @"http://qa.api.legal.prisonpublic.com"
#define UploadServerUrl [NSString stringWithFormat:@"%@/image-server",ServerDomain]

#else               //生产（防止没有定义的时候没有域名)
#define ServerDomain @"https://www.yuwugongkai.com"
#define H5ServerDomain @"http://39.108.185.51:8081"
#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app",ServerDomain] //生产
#define EmallUrl @"https://m.trade.prisonpublic.com" //电子商城
#define EmallHostUrl @"https://api.auth.prisonpublic.com"

#endif


//电子商务Server
#define CommerceServerDomain @"http://39.108.185.51:8088"
//使用协议
//#define ProtocolUrl [NSString stringWithFormat:@"%@/front/xieyi.html",H5ServerDomain]
#define ProtocolUrl @"http://39.108.185.51:8081/front/xieyi.html"
//电子商务地址
//#define CommerceUrl [NSString stringWithFormat:@"%@/ywt-ec/index.html",CommerceServerDomain]
//电子商务敬请期待
#define ProCommerceUrl [NSString stringWithFormat:@"%@/ywt-ec/index.html",CommerceServerDomain]
//外网授权认证平台测试地址
//#define EmallHostUrl @"http://123.57.7.159:8081" //123.57.7.159
//监狱详情地址 后面接jailId
#define PrisonDetailUrl [NSString stringWithFormat:@"%@/h5/#/prison/detail/",H5ServerDomain]
//法律法规列表
#define LawUrl [NSString stringWithFormat:@"%@/h5/#/law/list?t=%@",H5ServerDomain,[NSDate getNowTimeTimestamp]]
//新闻详情 后面接新闻id
#define NewsUrl [NSString stringWithFormat:@"%@/h5/#/news/detail",H5ServerDomain]
#define AppToken @"523b87c4419da5f9186dbe8aa90f37a3876b95e448fe2a"
#define AppUserSessionCacheKey @"AppUserSessionCacheKey"
#define AppDotChange @"AppDotChange"
#define JailChange @"JailChange"
#define AppScheme @"YuWuService"
#define RefreshToken @"RefreshToken" //刷新token

//根据username获取头像url
#define AvaterImageWithUsername(username)  [NSString stringWithFormat:@"%@/users/by-username/avatar?username=%@",EmallHostUrl,username]



//紫荆云视域名
#define ZIJING_DOMAIN @"cs.zijingcloud.com"

#define PICURL(url) [[NSString stringWithFormat:@"%@?token=%@",url,AppToken] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]

#define AppUIdKey @"prison.app"
#define AppUIdValue @"1688c4f69fc6404285aadbc996f5e429"

