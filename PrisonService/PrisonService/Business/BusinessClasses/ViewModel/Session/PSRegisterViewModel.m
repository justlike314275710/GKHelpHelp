//
//  PSRegisterViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSRegisterViewModel.h"
#import "PSSendCodeRequest.h"
#import "PSUploadAvatarRequest.h"
#import "PSUploadCardRequest.h"
#import "PSCheckCodeRequest.h"
#import "PSRegisterRequest.h"
#import "PSWhiteListRequest.h"
#import "PSSessionManager.h"
#import "PSHomeViewModel.h"
#import "PSUploadRelationRequest.h"
#import "AppDelegate.h"
@interface PSRegisterViewModel ()

@property (nonatomic, strong) PSSendCodeRequest *sendCodeRequest;
@property (nonatomic, strong) PSUploadAvatarRequest *uploadAvatarRequest;
@property (nonatomic, strong) PSUploadCardRequest *uploadCardRequest;
@property (nonatomic , strong) PSUploadRelationRequest *uploadRelationRequest;
@property (nonatomic, strong) PSCheckCodeRequest *checkCodeRequest;
@property (nonatomic, strong) PSRegisterRequest *registerRequest;
@property (nonatomic, strong) PSWhiteListRequest *whiteListRequest;

@end

@implementation PSRegisterViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.agreeProtocol = YES;
    }
    return self;
}

- (void)checkPersonalDataWithCallback:(CheckDataCallback)callback {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appdelegate.IS_NetWork == NO) {
        if (callback) {
            NSString*No_network_connection=NSLocalizedString(@"No network connection", @"无网络连接");
            callback(NO,No_network_connection);
        }
        return;
    }
    if (self.phoneNumber.length == 0) {
        if (callback) {
            callback(NO,@"请输入手机号码");
        }
        return;
    }
    if (self.avatarUrl.length == 0) {
        if (callback) {
            callback(NO,@"请设置头像");
        }
        return;
    }
    if (self.messageCode.length==0) {
        if (callback) {
            callback(NO,@"请输入验证码");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (void)checkMemberDataWithCallback:(CheckDataCallback)callback {
    if (self.relationShip.length == 0) {
        if (callback) {
            NSString*enter_Relationship=NSLocalizedString(@"enter_Relationship", @"请输入与服刑人员关系");
            callback(NO,enter_Relationship);
        }
        return;
    }
    if (self.prisonerNumber.length == 0) {
        if (callback) {
            NSString*enter_PrisonerNumber=NSLocalizedString(@"enter_PrisonerNumber", @"请输入囚号");
            callback(NO,enter_PrisonerNumber);
        }
        return;
    }
    if (!self.selectedJail) {
        if (callback) {
            callback(NO,@"请选择服刑人员所属监狱");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (void)checkIDCardDataWithCallback:(CheckDataCallback)callback {
    if (!self.avatarImage) {
        if (callback) {
            callback(NO,NSLocalizedString(@"Please upload an avatar", @"请上传头像"));
        }
        return;
    }
    
    if (self.frontCardUrl.length == 0) {
        if (callback) {
            callback(NO,NSLocalizedString(@"Please upload a photo of your ID with a avatar", @"请上传带头像一面的身份证照片"));
        }
        return;
    }
    if (self.backCardUrl.length == 0) {
        if (callback) {
            callback(NO,NSLocalizedString(@"Please upload a photo of the ID card with the national emblem", @"请上传带国徽一面的身份证照片"));
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}


- (void)checkAddFamilesDataWithCallback:(CheckDataCallback)callback {
    if (self.relationShip.length==0) {
        if (callback) {
            NSString*enter_Relationship=NSLocalizedString(@"enter_Relationship", @"请输入与服刑人员关系");
            callback(NO,enter_Relationship);
        }
        return;
    }
    
    if (!self.avatarImage) {
        if (callback) {
            callback(NO,NSLocalizedString(@"Please upload an avatar", @"请上传头像"));
        }
        return;
    }
    
    if (self.frontCardUrl.length == 0) {
        if (callback) {
            callback(NO,NSLocalizedString(@"Please upload a photo of your ID with a avatar", @"请上传带头像一面的身份证照片"));
        }
        return;
    }
    if (self.backCardUrl.length == 0) {
        if (callback) {
            callback(NO,NSLocalizedString(@"Please upload a photo of the ID card with the national emblem", @"请上传带国徽一面的身份证照片"));
        }
        return;
    }
 
    if (callback) {
        callback(YES,nil);
    }
}

- (void)checkMessageDataWithCallback:(CheckDataCallback)callback {
    if (self.messageCode.length == 0) {
        if (callback) {
            callback(NO,@"请输入短信验证码");
        }
        return;
    }
    if (!self.avatarImage) {
        if (callback) {
            callback(NO,@"请拍摄头像");
        }
        return;
    }
    if (!self.agreeProtocol) {
        if (callback) {
            callback(NO,@"请阅读并同意《狱务通使用协议》");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (void)setSession:(PSUserSession *)session {
    _session = session;
}

- (void)requestCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.sendCodeRequest = [PSSendCodeRequest new];
    self.sendCodeRequest.phone = self.phoneNumber;
    [self.sendCodeRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)uploadAvatarCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.avatarUrl = nil;
    self.uploadAvatarRequest = [PSUploadAvatarRequest new];
    self.uploadAvatarRequest.avatarData = UIImageJPEGRepresentation(self.avatarImage, 0.3);
    @weakify(self)
    [self.uploadAvatarRequest send:^(PSRequest *request, PSResponse *response) {
        
        @strongify(self)
        PSUploadAvatarResponse *avatarResponse = (PSUploadAvatarResponse *)response;
        self.avatarUrl = avatarResponse.url;
    
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)uploadRelationCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    //self.avatarUrl = nil;
    self.uploadAvatarRequest = [PSUploadAvatarRequest new];
    self.uploadAvatarRequest.avatarData = UIImageJPEGRepresentation(self.relationImage, 0.3);
    @weakify(self)
    [self.uploadAvatarRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        PSUploadAvatarResponse *avatarResponse = (PSUploadAvatarResponse *)response;
        self.relationUrl = avatarResponse.url;
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


- (void)uploadIDCardCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback frontOrBack:(BOOL)front {
    if (front) {
        self.frontCardUrl = nil;
    }else{
        self.backCardUrl = nil;
    }
    self.uploadCardRequest = [PSUploadCardRequest new];
    self.uploadCardRequest.cardData = UIImageJPEGRepresentation(front ? self.frontCardImage : self.backCardImage, 0.3);
    @weakify(self)
    [self.uploadCardRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        PSUploadCardResponse *cardResponse = (PSUploadCardResponse *)response;
        if (front) {
            self.frontCardUrl = cardResponse.url;
        }else{
            self.backCardUrl = cardResponse.url;
        }
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)checkCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.checkCodeRequest = [PSCheckCodeRequest new];
    self.checkCodeRequest.phone = self.phoneNumber;
    self.checkCodeRequest.code = self.messageCode;
    [self.checkCodeRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)registerCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.phoneNumber=[LXFileManager readUserDataForKey:@"phoneNumber"];
    self.registerRequest = [PSRegisterRequest new];
    self.registerRequest.name = self.name;
    self.registerRequest.phone = [LXFileManager readUserDataForKey:@"phoneNumber"];
    self.registerRequest.gender = self.gender;
    self.registerRequest.uuid = self.cardID;
    self.registerRequest.jailId = self.selectedJail.id;
    self.registerRequest.prisonerNumber = self.prisonerNumber;
    self.registerRequest.relationship = self.relationShip;
    self.registerRequest.avatarUrl = self.avatarUrl;
    self.registerRequest.idCardFront = self.frontCardUrl;
    self.registerRequest.idCardBack = self.backCardUrl;
    self.registerRequest.relationUrl=self.relationUrl;
    self.registerRequest.type=@"0";
    @weakify(self)
    [self.registerRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        PSRegisterResponse *registerResponse = (PSRegisterResponse *)response;
        if (registerResponse.code == 200) {
            if (registerResponse.data) {
                self.session = registerResponse.data;
                self.session.families.phone = self.phoneNumber;
                self.session.families.uuid = self.cardID;
                
            }
        }
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
        
    }];
}


- (void)addFamilesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    PSHomeViewModel *homeViewModel = [[PSHomeViewModel alloc]init];;
    NSInteger selectedIndex = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails.count > selectedIndex ? homeViewModel.passedPrisonerDetails[selectedIndex] : nil;
    self.registerRequest = [PSRegisterRequest new];
    self.registerRequest.name = self.name;
    self.registerRequest.phone = @"";
    self.registerRequest.gender = self.gender;
    self.registerRequest.uuid = self.cardID;
    self.registerRequest.jailId = prisonerDetail.jailId;
    self.registerRequest.prisonerNumber = prisonerDetail.prisonerNumber;
    self.registerRequest.relationship = self.relationShip;
    self.registerRequest.avatarUrl = self.avatarUrl;
    self.registerRequest.idCardFront = self.frontCardUrl;
    self.registerRequest.idCardBack = self.backCardUrl;
    self.registerRequest.relationUrl=self.relationUrl;
    self.registerRequest.type=@"1";
    //@weakify(self)
    [self.registerRequest send:^(PSRequest *request, PSResponse *response) {
       // @strongify(self)
        //PSRegisterResponse *registerResponse = (PSRegisterResponse *)response;
  
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
        
    }];
}



- (void)checkWhiteListCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.whiteListRequest = [PSWhiteListRequest new];
    self.whiteListRequest.phone = self.phoneNumber;
    [self.whiteListRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

@end
