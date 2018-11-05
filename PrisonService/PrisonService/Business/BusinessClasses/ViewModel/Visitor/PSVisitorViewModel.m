//
//  PSVisitorViewModel.m
//  PrisonService
//
//  Created by calvin on 2018/4/8.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSVisitorViewModel.h"
#import "PSProvinceRequest.h"
#import "PSCityRequest.h"
#import "PSJailsRequest.h"
#import "PSProfileResponse.h"
#import "PSProfileRequest.h"
#import "PSDefaultJailRequest.h"
#import "PSDefaultJailResponse.h"
@interface PSVisitorViewModel ()

@property (nonatomic, strong) PSProvinceRequest *provinceRequest;
@property (nonatomic, strong) PSCityRequest *cityRequest;
@property (nonatomic, strong) PSJailsRequest *jailsRequest;
@property (nonatomic ,strong) PSProfileRequest *profileRequest;
@property (nonatomic, strong) PSDefaultJailRequest*jailRequest;
@end

@implementation PSVisitorViewModel
- (id)init {
    self = [super init];
    if (self) {
        self.provinceSelectIndex = -1;
        self.citySelectIndex = -1;
        self.jailSelectIndex = -1;
    }
    return self;
}

- (void)setProvices:(NSArray *)provices {
    _provices = provices;
}

- (NSArray *)currentCitys {
    if (self.provinceSelectIndex >= 0 && self.provinceSelectIndex < self.provices.count) {
        PSProvince *selectProvince = self.provices[self.provinceSelectIndex];
        return selectProvince.citys;
    }else{
        return nil;
    }
}

- (NSArray *)currentJails {
    if (self.provinceSelectIndex >= 0 && self.provinceSelectIndex < self.provices.count) {
        PSProvince *selectProvince = self.provices[self.provinceSelectIndex];
        if (self.citySelectIndex >= 0 && self.citySelectIndex < selectProvince.citys.count) {
            PSCity *selectCity = selectProvince.citys[self.citySelectIndex];
            return selectCity.jails;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

- (PSProvince *)selectedProvince {
    if (self.provinceSelectIndex >= 0 && self.provinceSelectIndex < self.provices.count) {
        return self.provices[self.provinceSelectIndex];
    }
    return nil;
}

- (PSCity *)selectedCity {
    PSProvince *selectedProvince = self.selectedProvince;
    if (selectedProvince) {
        if (self.citySelectIndex >= 0 && self.citySelectIndex < selectedProvince.citys.count) {
            return selectedProvince.citys[self.citySelectIndex];
        }
    }
    return nil;
}

- (PSJail *)selectedJail {
    PSCity *selectedCity = self.selectedCity;
    if (selectedCity) {
        if (self.jailSelectIndex >= 0 && self.jailSelectIndex < selectedCity.jails.count) {
            return selectedCity.jails[self.jailSelectIndex];
        }
    }
    return nil;
}

- (void)setProvinceSelectIndex:(NSInteger)provinceSelectIndex {
    _provinceSelectIndex = provinceSelectIndex;
    _citySelectIndex = -1;
    _jailSelectIndex = -1;
}

- (void)setCitySelectIndex:(NSInteger)citySelectIndex {
    _citySelectIndex = citySelectIndex;
    _jailSelectIndex = -1;
}

- (void)requestProvincesWithCompletion:(RequestDataCompleted)completed failed:(RequestDataFailed)failed {
    if (self.provices.count > 0) {
        if (completed) {
            completed(nil);
        }
    }else{
        [self.provinceRequest cancelRequest];
        self.provinceRequest = [[PSProvinceRequest alloc] init];
        @weakify(self)
        [self.provinceRequest send:^(PSRequest *request, PSResponse *response) {
            @strongify(self)
            if (response.code == 200) {
                PSProvinceResponse *provinceResponse = (PSProvinceResponse *)response;
                self.provices = provinceResponse.provinces;
                if (completed) {
                    completed(nil);
                }
            }else{
                if (failed) {
                    failed(nil);
                }
            }
        } errorCallback:^(PSRequest *request, NSError *error) {
            if (failed) {
                failed(error);
            }
        }];
    }
}

- (void)requestCitysOfSelectProvinceWithCompletion:(RequestDataCompleted)completed failed:(RequestDataFailed)failed {
    if (self.provinceSelectIndex >= 0 || self.provinceSelectIndex < self.provices.count) {
        PSProvince *selectProvince = self.provices[self.provinceSelectIndex];
        if (selectProvince.citys.count > 0) {
            if (completed) {
                completed(nil);
            }
        }else{
            [self.cityRequest cancelRequest];
            self.cityRequest = [[PSCityRequest alloc] init];
            self.cityRequest.provicesId = selectProvince.id;
            [self.cityRequest send:^(PSRequest *request, PSResponse *response) {
                if (response.code == 200) {
                    PSCityResponse *cityResponse = (PSCityResponse *)response;
                    selectProvince.citys = cityResponse.citys;
                    if (completed) {
                        completed(nil);
                    }
                }else{
                    if (failed) {
                        failed(nil);
                    }
                }
            } errorCallback:^(PSRequest *request, NSError *error) {
                if (failed) {
                    failed(error);
                }
            }];
        }
    }else{
        if (failed) {
            failed(nil);
        }
    }
}

- (void)requestJailsOfSelectCityWithCompletion:(RequestDataCompleted)completed failed:(RequestDataFailed)failed {
    if (self.provinceSelectIndex >= 0 || self.provinceSelectIndex < self.provices.count) {
        PSProvince *selectProvince = self.provices[self.provinceSelectIndex];
        if (self.citySelectIndex >= 0 || self.citySelectIndex < selectProvince.citys.count) {
            PSCity *selectCity = selectProvince.citys[self.citySelectIndex];
            if (selectCity.jails.count > 0) {
                if (completed) {
                    completed(nil);
                }
            }else{
                [self.jailsRequest cancelRequest];
                self.jailsRequest = [[PSJailsRequest alloc] init];
                self.jailsRequest.provinces = selectProvince.id;
                self.jailsRequest.citys = selectCity.id;
                
                [self.jailsRequest send:^(PSRequest *request, PSResponse *response) {
                  
                    if (response.code == 200) {
                        PSJailsResponse *jailsResponse = (PSJailsResponse *)response;
                        selectCity.jails = jailsResponse.jails;
                        if (completed) {
                            completed(nil);
                        }
                    }else{
                        if (failed) {
                            failed(nil);
                        }
                    }
                } errorCallback:^(PSRequest *request, NSError *error) {
                    if (failed) {
                        failed(error);
                    }
                }];
            }
        }else{
            if (failed) {
                failed(nil);
            }
        }
    }else{
        if (failed) {
            failed(nil);
        }
    }
}

- (void)fetchDataWithParams:(id)params completed:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    
}

- (void)requestJailsProfileWithCompletion:(RequestDataCompleted)completed failed:(RequestDataFailed)failed{
    self.profileRequest=[PSProfileRequest new];
    self.profileRequest.jailId=self.jailId;
    [self.profileRequest send:^(PSRequest *request, PSResponse *response) {
        if (response.code==200) {
            PSProfileResponse*profileResponse=(PSProfileResponse*)response;
            self.profile=profileResponse.profile;
        }
        if (completed) {
            completed(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failed) {
            failed(error);
        }
    }];
}
-(void)requestDefaultJailConfigurations:(RequestDataCompleted)completed failed:(RequestDataFailed)failed{
    [self.jailRequest send:^(PSRequest *request, PSResponse *response) {
        if (response.code == 200) {
            PSDefaultJailResponse *jailResponse = (PSDefaultJailResponse *)response;
            self.defaultJailId = jailResponse.jailId;
            self.defaultJailName = jailResponse.jailName;
        }
        
    }];
    [self.jailRequest send:^(PSRequest *request, PSResponse *response) {
        if (response.code == 200) {
            PSDefaultJailResponse *jailResponse = (PSDefaultJailResponse *)response;
            self.defaultJailId = jailResponse.jailId;
            self.defaultJailName = jailResponse.jailName;
        }
        if (completed) {
            completed(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failed) {
            failed(error);
        }
    }];
}

@end
