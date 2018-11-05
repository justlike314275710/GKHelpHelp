//
//  PSBusinessConstants.h
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.
//
//开发环境
<<<<<<< HEAD
#define ServerDomain @"http://120.78.190.101:8086"
=======
//#define ServerDomain @"http://120.78.190.101:8086"

//#define ServerDomain @"http://192.168.0.121:8086" //杨波
>>>>>>> ea064ae4415599fccb7c2500f7d14b5723b6e964
//测试环境
//#define ServerDomain @"http://120.78.190.101:8084"
//生产环境
//#define ServerDomain @"https://www.yuwugongkai.com"
<<<<<<< HEAD
//H5 生产Server
//#define H5ServerDomain @"http://39.108.185.51:8081"
=======

>>>>>>> ea064ae4415599fccb7c2500f7d14b5723b6e964
//H5 开发Server
#define H5ServerDomain @"http://120.78.190.101:8085"
//H5 测试Server
<<<<<<< HEAD
//#define H5ServerDomain @"http://120.78.190.101:8083"
//电子商务Server
#define CommerceServerDomain @"http://39.108.185.51:8088"
//其他环境接口地址
//#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app",ServerDomain]
#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app-auth",ServerDomain]

//测试环境接口地址
//#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app-demo",ServerDomain]
=======
#define H5ServerDomain @"http://120.78.190.101:8083"
//H5 生产Server
//#define H5ServerDomain @"http://39.108.185.51:8081"
//电子商务Server
#define CommerceServerDomain @"http://39.108.185.51:8088"
//其他环境接口地址
//#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app",ServerDomain] //生产
//#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app-auth",ServerDomain] //开发
//#define ServerUrl [NSString stringWithFormat:@"%@",ServerDomain] //杨
//测试环境接口地址
#define ServerUrl [NSString stringWithFormat:@"%@/ywgk-app-demo",ServerDomain]

>>>>>>> ea064ae4415599fccb7c2500f7d14b5723b6e964
//图片上传地址
//#define UploadServerUrl [NSString stringWithFormat:@"%@/image-server",ServerDomain]
#define UploadServerUrl @"http://120.78.190.101:1339/image-server"
//使用协议
//#define ProtocolUrl [NSString stringWithFormat:@"%@/front/xieyi.html",H5ServerDomain]
#define ProtocolUrl @"http://39.108.185.51:8081/front/xieyi.html"
//电子商务地址
//#define CommerceUrl [NSString stringWithFormat:@"%@/ywt-ec/index.html",CommerceServerDomain]
//电子商务敬请期待
#define ProCommerceUrl [NSString stringWithFormat:@"%@/ywt-ec/index.html",CommerceServerDomain]

//授权认证平台开发地址
#define EmallHostUrl @"http://10.10.10.17:8081"
#define EmallUrl @"http://10.10.10.17:805"
#define ConsultationHostUrl @"http://10.10.10.17:8086"
//授权认证平台测试地址
//#define EmallHostUrl @"http://10.10.10.16:8081"
//#define EmallUrl @"http://10.10.10.16:805"

//授权认证平台生产地址
//#define EmallUrl @"http://m.trade.prisonpublic.com" //电子商城
//#define EmallHostUrl @"http://api.auth.prisonpublic.com"

//监狱详情地址 后面接jailId
#define PrisonDetailUrl [NSString stringWithFormat:@"%@/h5/#/prison/detail/",H5ServerDomain]
//法律法规列表
#define LawUrl [NSString stringWithFormat:@"%@/h5/#/law/list",H5ServerDomain]
//新闻详情 后面接新闻id
#define NewsUrl [NSString stringWithFormat:@"%@/h5/#/news/detail/",H5ServerDomain]

#define AppToken @"523b87c4419da5f9186dbe8aa90f37a3876b95e448fe2a"


#define AppUserSessionCacheKey @"AppUserSessionCacheKey"

#define AppDotChange @"AppDotChange"
#define JailChange @"JailChange"
#define AppScheme @"YuWuService"
//紫荆云视域名
#define ZIJING_DOMAIN @"cs.zijingcloud.com"

#define PICURL(url) [[NSString stringWithFormat:@"%@?token=%@",url,AppToken] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
