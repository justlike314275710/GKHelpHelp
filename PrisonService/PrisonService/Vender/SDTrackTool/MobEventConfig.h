//
//  MobEventConfig.h
//  PrisonService
//
//  Created by kky on 2018/12/12.
//  Copyright © 2018年 calvin. All rights reserved.
//
#ifndef MobEventConfig_h
#define MobEventConfig_h

/*------------------event_id----------------*/
#define VER_Login               @"VER_Login"              // 验证码登录
#define PSW_Login               @"PSW_Login"              // 密码登录
#define SERVICE_Consumption     @"SERVICE_Consumption"    // 狱内消费情况
#define SERVICE_PERIOD          @"SERVICE_PERIOD"         // 零花钱消费情况
#define SERVICE_PRISONER_CHANGE @"SERVICE_PRISONER_CHANGE"// 切换服刑人员
#define SERVICE_PRISONER_BIND   @"SERVICE_PRISONER_BIND"  // 绑定服刑人员

#define ARTICLE_HDWZ            @"ARTICLE_HDWZ"           // 点击顶部互动文章
#define ARTICLE_LIST_LIKE       @"ARTICLE_LIST_LIKE"      // 简介列表点赞
#define ARTICLE_CLICK_DETAIL    @"ARTICLE_CLICK_DETAIL"   // 文章详情
#define ARTICLE_DETAIL_LIKE     @"ARTICLE_DETAIL_LIKE"    // 详情点赞
#define ARTICLE_DETAIL_COLLECT  @"ARTICLE_DETAIL_COLLECT" // 详情收藏
#define ARTICLE_CLICK_COLLECT   @"ARTICLE_CLICK_COLLECT"  // 点击顶部收藏
#define ARTICLE_CLICK_MINE      @"ARTICLE_CLICK_MINE"     // 点击我的文章
#define ARTICLE_CLICK_WFB_MINE  @"ARTICLE_CLICK_WFB_MINE" // 点击我的文章未发布
#define ARTICLE_CLICK_YFB_MINE  @"ARTICLE_CLICK_YFB_MINE" // 点击我的文章已发布
#define ARTICLE_CLICK_WTG_MINE  @"ARTICLE_CLICK_WTG_MINE" // 点击我的文章未通过
#define ARTICLE_EDIT            @"ARTICLE_EDIT"           // 编辑文章
#define ARTICLE_RELEASE         @"ARTICLE_RELEASE"        // 发布文章
#define ARTICLE_REPORT          @"ARTICLE_REPORT"         // 举报文章

#define PUBliC_PRISON_JXJS      @"PUBliC_PRISON_JXJS"     // 减刑假释
#define PUBliC_PRISON_JWZX      @"PUBliC_PRISON_JWZX"     // 监外执行
#define PUBliC_PRISON_SHBJ      @"PUBliC_PRISON_SHBJ"     // 社会帮教

#define PUBliC_PRISON_FLFW      @"PUBliC_PRISON_FLFW"     // 法律服务
#define PUBliC_PRISON_FLFG      @"PUBliC_PRISON_FLFG"     // 法律法规
#define HOME_PAGE_YCTS          @"HOME_PAGE_YCTS"         // 远程探视
#define HOME_PAGE_SDHJ          @"HOME_PAGE_SDHJ"         // 实地会见
#define HOME_PAGE_DZSW          @"HOME_PAGE_DZSW"         // 电子商务
#define HOME_PAGE_JSFW          @"HOME_PAGE_JSFW"         // 家属服务
#define HOME_PAGE_HDPT          @"HOME_PAGE_HDPT"         // 互动平台

#define TSJY_PAGE_GSXX          @"TSJY_PAGE_GSXX"         // 公示信息
#define TSJY_PAGE_TSJY          @"TSJY_PAGE_TSJY"         // 投诉建议
#define TSJY_PAGE_TXYJFK        @"TSJY_PAGE_TXYJFK"       // 填写意见反馈

#define FWZX_PAGE_FLFW          @"FWZX_PAGE_FLFW"         // 法律服务
#define FWZX_PAGE_XLZX          @"FWZX_PAGE_XLZX"         // 心理咨询

#define ZHXX_PAGE_XGTX          @"ZHXX_PAGE_XGTX"         // 修改头像
#define ZHXX_PAGE_LXDH          @"ZHXX_PAGE_LXDH"         // 联系电话
#define ZHXX_PAGE_GHSJHM        @"ZHXX_PAGE_GHSJHM"        // 点击头像-->已认证
#define ZHXX_PAGE_GHSJHM_WRZ        @"ZHXX_PAGE_GHSJHM_WRZ"       // 点击头像-->未认证
#define ZHXX_PAGE_JTZZ          @"ZHXX_PAGE_JTZZ"         // 家庭住址
#define ZHXX_PAGE_YZBM          @"ZHXX_PAGE_YZBM"         // 邮政编码
#define ZHXX_PAGE_GHSJ          @"ZHXX_PAGE_GHSJ"         // 更换手机

#define SZ_PAGE_CZMM          @"SZ_PAGE_CZMM"           // 重置密码
#define SZ_PAGE_YJFK            @"SZ_PAGE_YJFK"           // 意见反馈
#define ZHXX_PAGE_CZKJ          @"ZHXX_PAGE_CZKJ"          // 存储空间
#define ZHXX_PAGE_DQBB          @"ZHXX_PAGE_DQBB"          // 当前版本
#define ZHXX_PAGE_TCDL          @"ZHXX_PAGE_TCDL"          // 退出登录

#define SZ_PAGE_LXWM          @"SZ_PAGE_LXWM"           // 联系我们
#define SZ_PAGE_SYXY          @"SZ_PAGE_SYXY"           // 使用协议

#define MIME_PAGE_JSFQ        @"MIME_PAGE_JSFQ"          // 家属服务
#define MIME_PAGE_CZJL        @"MIME_PAGE_CZJL"          // 充值记录
#define MIME_PAGE_DJYCTSKYE   @"MIME_PAGE_DJYCTSKYE"          // 点击远程探视卡余额
#define MIME_PAGE_HJLS   @"MIME_PAGE_HJLS"          // 会见历史
#define MIME_PAGE_JSRZ   @"MIME_PAGE_JSRZ"          // 家属认证

#define YCTSSP_PAGE_GMTSK       @"YCTSSP_PAGE_GMTSK"         // 远程探视购买探视卡
#define YCTS_PAGE_YCTSMX      @"YCTS_PAGE_YCTSMX"        // 远程探视明细
#define YCTS_PAGE_GMTSK       @"YCTS_PAGE_GMTSK"         // 余额购买探视卡
#define YCTS_PAGE_DBGMTSK     @"YCTS_PAGE_DBGMTSK"       // 底部购买探视卡
#define YCTS_PAGE_DBTK        @"YCTS_PAGE_DBTK"          // 底部退款
#define YCTS_PAGE_ZCGM        @"YCTS_PAGE_ZCGM"          // 再次购买
#define MIME_PAGE_JSHK        @"MIME_PAGE_JSHK"          // 家属汇款
#define MIME_PAGE_WDZX        @"MIME_PAGE_WDZX"          // 我的咨询
#define HJLS_PAGE_QXYCHJ      @"HJLS_PAGE_QXYCHJ"        // 取消远程会见
#define HJLS_PAGE_QXSDHJ      @"HJLS_PAGE_QXSDHJ"        // 取消实地会见



#define MIME_ClICK_SZ      @"MIME_ClICK_SZ"              // 点击设置









#define YUWUTONG_AUTH           @"yuwutong_auth"            // , 提交认证, 0
#define ADD_FAMILY              @"add_family"               // , 添加家属提交, 0
#define BIND_PRISONER           @"bind_prisoner"            // , 绑定服刑人员, 0
#define APPLY_FAMILY_CALL       @"apply_family_call"        // , 申请远程会见, 0
#define CANCEL_FAMILY_CALL      @"cancel_family_call"       // , 取消远程会见, 0
#define CANCEL_LOCAL_CALL      @"CANCEL_LOCAL_CALL"         // , 会见历史取消实地会见, 0
#define BUY_FAMILY_CARD         @"buy_family_card"          // , 购买亲情电话卡, 1
#define RECEIVE_REMOTE_CALL     @"receive_remote_call"      // , 接收到远程呼叫, 0
#define FACE_RECOGNITION        @"face_recognition"         // , 人脸识别, 0

#define APPLY_IMEITE_MEETING    @"APPLY_IMEITE_MEETING"     // , 立即预约, 0
#define APPLY_CANCEL_MEETING    @"APPLY_CANCEL_MEETING"     // , 实地会见取消预约, 0
#define APPLY_SURE_MEETING      @"APPLY_SURE_MEETING"     // , 确定预约, 0
#define APPLY_REAL_MEETING      @"apply_real_meeting"       // , 申请实地会见, 0
#define CANCEL_REAL_MEETING     @"cancel_real_meeting"      // , 取消实地会见, 0

#define UPDATE_APP_VERSION      @"update_app_version"       // , 应用内版本更新, 0
#define VIDEO_MEETING_COMPLETE  @"video_meeting_complete"   // , 视频通话完成, 1

#define FWZX_CLICK_YCTS  @"FWZX_CLICK_YCTS"          //服务中心点击远程探视
#define FWZX_CLICK_SDHJ  @"FWZX_CLICK_SDHJ"          //服务中心点击实地会见
#define FWZX_CLICK_DZSW  @"FWZX_CLICK_DZSW"          //服务中心点击电子商务
#define FWZX_CLICK_JSFW  @"FWZX_CLICK_JSFW"          //服务中心点击家属服务

#define CLICK_HOME_PAGE         @"click_home_page"                 //点击主页, 0
#define CLICK_CENTER_SERVICE    @"click_center_service"            //点击服务中心, 0
#define CLICK_MINE_PAGE         @"click_mine_page"                 //点击"我的"页面, 0
#define CLICK_JAIL_DETAIL       @"click_jail_detail"               //点击监狱详情, 0
#define CLICK_PRISONER_OPNENING @"click_prisoner_opnening"         //点击狱务公开, 0
#define CLICK_WORK_DYNAMIC      @"click_work_dynamic"              //点击工作动态, 0
#define CLICK_LAWS_REGULAR      @"click_laws_regular"              //点击法律法规, 0

#define CLICK_FAMILY_CALL       @"click_family_call"               //点击亲情电话, 0
#define CLICK_REAL_MEETING      @"click_real_meeting"              //点击实地会见, 0
#define CLICK_E_MALL            @"click_e_mall"                    //点击电子商务, 0
#define CLICK_COMPLAIN_ADVICE   @"click_complain_advice"           //点击投诉建议, 0
#define CLICK_REFUSED_MEETING   @"click_refused_meeting"           //点击拒绝接听, 0
#define CLICK_ACCEPT_MEETING    @"click_accept_meeting"            //点击接听来电, 0
#define CLICK_APPLY_FAMILY_CALL @"click_apply_family_call"         //点击申请亲情电话按钮, 0
#define CLICK_GO_AUTH           @"click_go_auth"                   //点击去认证按钮, 0
#define CLICK_UPDATE_APP        @"click_update_app"                //点击更新应用, 0
#define CLICK_IGNORE_UPDATE_APP @"click_ignore_update_app"         //点击忽略此版本, 0
#define CLICK_ADD_FAMILY        @"click_add_family"                //点击添加家属按钮, 0
#define CLICK_GO_BIND_PRISONER  @"click_go_bind_prisoner"          //点击去添加绑定服刑人员, 0






/*-----------------event_key----------------*/  //参数
//监狱名称
#define JAIL_NAME  @"jailName"
//事件结果状态
#define STATUS  @"status"
//事件错误内容
#define ERROR_STR  @"error_str"
//支付类型
#define PAY_TYPE  @"pay_type"
//选择金钱是方式
#define PAY_INSERT_TYPE  @"PAY_INSERT_TYPE"
//购买数量
#define PAY_COUNT  @"PAY_COUNT"
//购买数量
#define PAY_ENTER  @"PAY_ENTER"

//版本号
#define VERSION_NAME  @"version_name"
//时长
#define DURATION  @"duration"

//------成功失败--------
#define MobSUCCESS  @"SUCCESS"

#define MobFAILURE  @"FAILURE"

typedef enum : NSUInteger {
    SUCCESS,
    FAILURE,
} UMStatus;

#endif /* MobEventConfig_h */
