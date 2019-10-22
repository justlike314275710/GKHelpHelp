//
//  PSMessageViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMessageViewModel.h"
#import "PSFamilyLogsRequest.h"
#import "PSSessionManager.h"

@interface PSMessageViewModel ()

@property (nonatomic, strong) PSFamilyLogsRequest *familyLogsRequest;
@property (nonatomic, strong) NSMutableArray *logs;

@end

@implementation PSMessageViewModel
@synthesize dataStatus = _dataStatus;
- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 10;
    }
    return self;
}

- (NSArray *)messages {
    return _logs;
}

- (NSArray *)buildMessages:(NSArray *)messages {
    for (PSMessage *message in messages) {
        NSString *title = nil;
        NSString *content = nil;
        switch (message.type) {
            case PSMessageRegister:
            {
                title =NSLocalizedString(@"Registration_message", @"认证消息");
                //@"注册消息";
                if ([message.status isEqualToString:@"PASSED"]) {
                    content =NSLocalizedString(@"registration_approved", @"您的注册审核已通过");
                }else if ([message.status isEqualToString:@"DENIED"]) {
                    NSString *reason = message.content ? [NSString stringWithFormat:@",%@",message.content] : @"";
                    NSString*registration_rejected=NSLocalizedString(@"registration_rejected", @"您的注册申请已被拒绝%@");
                    content = [NSString stringWithFormat:registration_rejected,reason];
                }else {
                    content = message.content;
                }
            }
                break;
            case PSMessageMeeting:
            {
                title =NSLocalizedString(@"Meet_message", @"会见消息")  ;
                NSString *statusString = nil;
                if ([message.status isEqualToString:@"PASSED"]) {
                    if ([message.content isEqualToString:@"设备出现故障"] || [message.content isEqualToString:@"临时出现突发情况"]) {
                        statusString = NSLocalizedString(@"Meet_abnormal", @"出现异常");
                    }else{
                        title =NSLocalizedString(@"Interview_review", @"会见审核消息") ;
                        statusString =NSLocalizedString(@"application_passed", @"申请已经通过");
                    }
                }else if ([message.status isEqualToString:@"FINISHED"]) {
                    statusString =NSLocalizedString(@"Application_completed", @"已经完成") ;
                }else if ([message.status isEqualToString:@"PENDING"]) {
                    title =NSLocalizedString(@"Interview_review", @"会见审核消息") ;
                    statusString =NSLocalizedString(@"Application_review", @"申请正在审核");
                }else if ([message.status isEqualToString:@"DENIED"]) {
                    title = NSLocalizedString(@"Interview_review", @"会见审核消息") ;
                    statusString =NSLocalizedString(@"application_approved", @"申请审核未通过") ;
                }else if ([message.status isEqualToString:@"CANCELED"]) {
                    statusString =NSLocalizedString(@"been_cancelled", @"已被取消");
                }else {
                    statusString=@"未通过审核";
                }
                NSString *reason = [message.content isEqualToString:@"成功"] ? @"" : [NSString stringWithFormat:@",%@",message.content];
                NSString*you_meet=NSLocalizedString(@"you_meet", @"您的%@会见%@%@");
                content = [NSString stringWithFormat:you_meet,message.applicationDate ? message.applicationDate : @"",statusString,reason];
                
            }
                break;
            case PSMessageLocalMeeting:
            {
                title =NSLocalizedString(@"Field_interview", @"实地会见消息");
                NSString *statusString = nil;
                if ([message.status isEqualToString:@"PASSED"]) {
                    statusString =NSLocalizedString(@"application_passed", @"申请已经通过");
                }else if ([message.status isEqualToString:@"PENDING"]) {
                    statusString =NSLocalizedString(@"Application_review", @"申请正在审核");
                }else if ([message.status isEqualToString:@"DENIED"]) {
                     statusString =NSLocalizedString(@"application_approved", @"申请审核未通过") ;
                }else if ([message.status isEqualToString:@"CANCELED"]) {
                    statusString =NSLocalizedString(@"been_cancelled", @"已被取消");
                }else {
                    
                }
                NSString *reason = message.content.length > 0 ? ([message.content isEqualToString:@"成功"] ? @"" : [NSString stringWithFormat:@",%@",message.content]) : @"";
                NSString*you_localMeet=NSLocalizedString(@"you_localMeet", @"您的%@实地会见%@%@");
                content = [NSString stringWithFormat:you_localMeet,message.applicationDate ? message.applicationDate : @"",statusString,reason];
            }
                break;
            default:
            {
                title = NSLocalizedString(@"message", @"消息");
                content = message.content;
            }
                break;
        }
        message.title = title;
        message.content = content;
    }
    return messages;
}

- (void)refreshMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page = 1;
    self.logs = nil;
    self.hasNextPage = NO;
    self.dataStatus = PSDataInitial;
    [self requestMessagesCompleted:completedCallback failed:failedCallback];
}

- (void)loadMoreMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.page ++;
    [self requestMessagesCompleted:completedCallback failed:failedCallback];
}

- (void)requestMessagesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.familyLogsRequest = [PSFamilyLogsRequest new];
    self.familyLogsRequest.page = self.page;
    self.familyLogsRequest.rows = self.pageSize;
    if (self.type&&self.type.length>0) {
        self.familyLogsRequest.type = self.type;
    }
    NSString *familyId = [PSSessionManager sharedInstance].session.families.id?[PSSessionManager sharedInstance].session.families.id:@"";
    self.familyLogsRequest.familyId = familyId;
    @weakify(self)
    [self.familyLogsRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        
        if (response.code == 200) {
            PSFamilyLogsResponse *logsResponse = (PSFamilyLogsResponse *)response;
            
            if (self.page == 1) {
                self.logs = [NSMutableArray array];
            }
            if (logsResponse.logs.count == 0) {
                self.dataStatus = PSDataEmpty;
            }else{
                self.dataStatus = PSDataNormal;
            }
            self.hasNextPage = logsResponse.logs.count >= self.pageSize;
            [self.logs addObjectsFromArray:[self buildMessages:logsResponse.logs]];
        }else{
            if (self.page > 1) {
                self.page --;
                self.hasNextPage = YES;
            }else{
                self.dataStatus = PSDataError;
                if (response.code==500) {
                    self.dataStatus = PSDataEmpty;
                }
            }
        }
        if (completedCallback) {
            completedCallback(response);
        }
       
    } errorCallback:^(PSRequest *request, NSError *error) {
        @strongify(self)
        if (self.page > 1) {
            self.page --;
            self.hasNextPage = YES;
        }else{
            self.dataStatus = PSDataError;
        }
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

@end
