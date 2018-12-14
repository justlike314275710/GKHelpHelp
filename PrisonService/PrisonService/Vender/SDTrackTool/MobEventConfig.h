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
#define YUWUTONG_AUTH           @"yuwutong_auth"            // , 提交认证, 0
#define ADD_FAMILY              @"add_family"               // , 添加家属提交, 0
#define BIND_PRISONER           @"bind_prisoner"            // , 绑定服刑人员, 0
#define APPLY_FAMILY_CALL       @"apply_family_call"        // , 申请远程会见, 0
#define CANCEL_FAMILY_CALL      @"cancel_family_call"       // , 取消远程会见, 0
#define BUY_FAMILY_CARD         @"buy_family_card"          // , 购买亲情电话卡, 1
#define RECEIVE_REMOTE_CALL     @"receive_remote_call"      // , 接收到远程呼叫, 0
#define FACE_RECOGNITION        @"face_recognition"         // , 人脸识别, 0
#define APPLY_REAL_MEETING      @"apply_real_meeting"       // , 申请实地会见, 0
#define CANCEL_REAL_MEETING     @"cancel_real_meeting"      // , 取消实地会见, 0
#define UPDATE_APP_VERSION      @"update_app_version"       // , 应用内版本更新, 0
#define VIDEO_MEETING_COMPLETE  @"video_meeting_complete"   // , 视频通话完成, 1


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
