//
//  PSFeedbackViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFeedbackViewModel.h"
#import "PSFeedbackRequest.h"
#import "PSSessionManager.h"
#import "PSFeedBackTypesRequest.h"
#import "PSFeedBackTypesResponse.h"
#import "FeedbackTypeModel.h"
#import "PSMailBoxesTypesRequest.h"
#import "PSWriteSuggestionRequest.h"
#import "NSString+emoji.h"

@interface PSFeedbackViewModel ()

@property (nonatomic, strong) PSFeedbackRequest *feedbackRequest;
@property (nonatomic, strong) PSFeedBackTypesRequest *feedbackTypesRequest;
@property (nonatomic, strong) PSMailBoxesTypesRequest *mailBoxesTypesRequest;
@property (nonatomic, strong) PSWriteSuggestionRequest *writeSuggestionRequest;


@end

@implementation PSFeedbackViewModel

 - (id)init {
    self = [super init];
    if (self) {
//        FeedbackTypeModel *reason_one = [FeedbackTypeModel new];
//        reason_one.name = @"功能异常";
//        reason_one.id = @"1";
//        reason_one.type = @"APP_FEEDBACK";
//        reason_one.desc = @"功能故障或不可使用";
//        
//        FeedbackTypeModel *reason_two = [FeedbackTypeModel new];
//        reason_two.name = @"产品建议";
//        reason_two.id = @"2";
//        reason_two.type = @"APP_FEEDBACK";
//        reason_two.desc = @"功能故障或不可使用";
//        
//        FeedbackTypeModel *reason_three = [FeedbackTypeModel new];
//        reason_three.name = @"安全问题";
//        reason_three.id = @"3";
//        reason_three.type = @"APP_FEEDBACK";
//        reason_three.desc = @"功能故障或不可使用";
//        
//        FeedbackTypeModel *reason_four = [FeedbackTypeModel new];
//        reason_four.name = @"其他问题";
//        reason_four.id = @"4";
//        reason_four.type = @"APP_FEEDBACK";
//        reason_four.desc = @"功能故障或不可使用";
//        NSMutableArray *items = [NSMutableArray arrayWithObjects:reason_one,reason_two,reason_three,reason_four, nil];
//        self.reasons = [items copy];
    }
    return self;
}

- (void)checkDataWithCallback:(CheckDataCallback)callback {
    if (self.content.length <10) {
        if (callback) {
            callback(NO,@"请输入不少于10个字的描述");
        }
        return;
    }
    if ([NSString hasEmoji:self.content]||[NSString stringContainsEmoji:self.content]) {
        if (callback) {
            callback(NO,@"输入的反馈详情不能包含表情,请重新输入");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (void)sendFeedbackCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    switch (self.writefeedType) {
        case PSWritefeedBack:
        {
            [self sendAppFeedbackCompleted:completedCallback failed:failedCallback];
        }
            break;
        case PSPrisonfeedBack:
        {
            [self sendSuggestionCompleted:completedCallback failed:failedCallback];
        }
            break;
            
        default:
            break;
    }
}

- (void)sendAppFeedbackCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
    self.feedbackRequest = [PSFeedbackRequest new];
    self.feedbackRequest.content = self.content;
    self.feedbackRequest.imageUrls = self.imageUrls.length>0?self.imageUrls:@"";
    self.feedbackRequest.type = self.type;
    self.feedbackRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
    [self.feedbackRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


- (void)sendSuggestionCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    PSPrisonerDetail *prisonerDetail = (index >= 0 && index < details.count) ? details[index] : nil;
    self.writeSuggestionRequest = [PSWriteSuggestionRequest new];
    self.writeSuggestionRequest.title = @"";
    self.writeSuggestionRequest.contents = self.content;
    self.writeSuggestionRequest.imageUrls = self.imageUrls.length>0?self.imageUrls:@"";
    self.writeSuggestionRequest.jailId = prisonerDetail.jailId?prisonerDetail.jailId:@"";
    self.writeSuggestionRequest.familyId = [PSSessionManager sharedInstance].session.families.id;
    self.writeSuggestionRequest.type = self.type;
    [self.writeSuggestionRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}



- (void)sendFeedbackTypesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    switch (self.writefeedType) {
        case PSWritefeedBack:
        {
            self.feedbackTypesRequest = [PSFeedBackTypesRequest new];
            [self.feedbackTypesRequest send:^(PSRequest *request, PSResponse *response) {
                if (completedCallback) {
                    PSFeedBackTypesResponse *typesResponse = (PSFeedBackTypesResponse *)response;
                    if (typesResponse.types.count > 0) {
                        self.reasons = [typesResponse.types copy];
                    }
                    completedCallback(response);
                }
            } errorCallback:^(PSRequest *request, NSError *error) {
                if (failedCallback) {
                    failedCallback(error);
                }
            }];
        }
            break;
        case PSPrisonfeedBack:
        {
            self.mailBoxesTypesRequest = [PSMailBoxesTypesRequest new];
            [self.mailBoxesTypesRequest send:^(PSRequest *request, PSResponse *response) {
                if (completedCallback) {
                    PSFeedBackTypesResponse *typesResponse = (PSFeedBackTypesResponse *)response;
                    if (typesResponse.types.count > 0) {
                        self.reasons = [typesResponse.types copy];
                    }
                    completedCallback(response);
                }
            } errorCallback:^(PSRequest *request, NSError *error) {
                if (failedCallback) {
                    failedCallback(error);
                }
            }];
        }
            break;
            
        default:
            break;
    }

}


@end
