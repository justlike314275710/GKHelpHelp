//
//  VIRegisterViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/8.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIRegisterViewModel.h"
#import "PSSendCodeRequest.h"
#import "PSUploadAvatarRequest.h"
#import "PSUploadCardRequest.h"
#import "PSCheckCodeRequest.h"
#import "VIRegisterRequest.h"
#import "VIRegisterResponse.h"
#import "PSWhiteListRequest.h"
#import "PSHomeViewModel.h"

@interface VIRegisterViewModel ()

@property (nonatomic, strong) PSSendCodeRequest *sendCodeRequest;
@property (nonatomic, strong) PSUploadAvatarRequest *uploadAvatarRequest;
@property (nonatomic, strong) PSUploadCardRequest *uploadCardRequest;
@property (nonatomic, strong) PSCheckCodeRequest *checkCodeRequest;
@property (nonatomic, strong) VIRegisterRequest *registerRequest;
@property (nonatomic, strong) PSWhiteListRequest *whiteListRequest;

@end

@implementation VIRegisterViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.agreeProtocol = YES;
    }
    return self;
}

- (void)checkPersonalDataWithCallback:(CheckDataCallback)callback {
    if (self.phoneNumber.length == 0) {
        if (callback) {
            callback(NO,@"Xin vui lòng nhập số điện thoại");
        }
        return;
    }
    if (self.avatarUrl.length == 0) {
        if (callback) {
            callback(NO,@"Xin vui lòng đặt avatar");
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
            callback(NO,@"Hãy nhập vào mối quan hệ với các nhà giam");
        }
        return;
    }
    if (self.prisonerNumber.length == 0) {
        if (callback) {
            callback(NO,@"Xin vui lòng nhập số");
        }
        return;
    }
    if (!self.selectedJail) {
        if (callback) {
            callback(NO,@"Hãy chọn một nhà tù");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (void)checkIDCardDataWithCallback:(CheckDataCallback)callback {
    if (self.frontCardUrl.length == 0) {
        if (callback) {
            callback(NO,@"Hãy tải lên những bức ảnh của một mặt");
        }
        return;
    }
    if (self.backCardUrl.length == 0) {
        if (callback) {
            callback(NO,@"Xin vui lòng đăng tải hình ảnh id của huy hiệu quốc gia");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}

- (void)checkMessageDataWithCallback:(CheckDataCallback)callback {
  
    if (self.avatarUrl.length==0) {
        if (callback) {
            callback(NO,@"Xin vui lòng quay đầu");
        }
        return;
    }
    
    if (self.name.length==0) {
        if (callback) {
            callback(NO,@"Hãy nhập vào tên");
        }
        return;
    }
    if (self.cardID.length==0) {
        if (callback) {
            callback(NO,@"Hãy nhập vào một số thẻ căn cước.");
        }
        return;
    }
    if (self.gender.length==0) {
        if (callback) {
            callback(NO,@"Hãy nhập vào giới tính");
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
            callback(NO,@"Hãy nhập vào mối quan hệ với các nhà giam");
        }
        return;
    }
    
    if (!self.avatarImage) {
        if (callback) {
            callback(NO,@"Xin hãy tải lên đầu.");
        }
        return;
    }
    if (self.cardID.length==0) {
        if (callback) {
            callback(NO,@"Hãy nhập vào một số thẻ căn cước.");
        }
        return;
    }
    if (self.frontCardUrl.length == 0) {
        if (callback) {
            callback(NO,@"Hãy tải lên những bức ảnh của một mặt");
        }
        return;
    }
    if (self.backCardUrl.length == 0) {
        if (callback) {
            callback(NO,@"Xin vui lòng đăng tải hình ảnh id của huy hiệu quốc gia");
        }
        return;
    }
    if (self.name.length==0) {
        if (callback) {
            callback(NO,@"Xin vui lòng nhập tên");
        }
        return;
    }
    if (self.gender.length==0) {
        if (callback) {
            callback(NO,@"Vui lòng nhập giới tính");
        }
        return;
    }
//    if (!self.agreeProtocol) {
//        if (callback) {
//            NSString*read_agree_usageProtocol=NSLocalizedString(@"read_agree_usageProtocol", @"请阅读并同意《狱务通使用协议》");
//            callback(NO,read_agree_usageProtocol);
//        }
//        return;
//    }
    if (callback) {
        callback(YES,nil);
    }
}
- (void)checkProtocolDataWithCallback:(CheckDataCallback)callback {
    if (!self.agreeProtocol) {
        if (callback) {
            NSString*read_agree_usageProtocol=NSLocalizedString(@"read_agree_usageProtocol", @"请阅读并同意《狱务通使用协议》");
            callback(NO,read_agree_usageProtocol);
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
    self.relationUrl = nil;
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

- (void)addFamilesCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    PSHomeViewModel *homeViewModel = [[PSHomeViewModel alloc]init];;
    NSInteger selectedIndex = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails.count > selectedIndex ? homeViewModel.passedPrisonerDetails[selectedIndex] : nil;
    self.registerRequest = [VIRegisterRequest new];
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
    self.registerRequest.type=self.type;
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

- (void)registerCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    self.registerRequest = [VIRegisterRequest new];
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
    self.registerRequest.type=self.type;
    @weakify(self)
    [self.registerRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        VIRegisterResponse *registerResponse = (VIRegisterResponse *)response;
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
