//
//  PSWechatHandler.m
//  Start
//
//  Created by calvin on 16/7/18.
//  Copyright © 2016年 DingSNS. All rights reserved.
//

#import "PSWechatHandler.h"
#import "WXApi.h"
#import "PSWechatPayRequest.h"
#import "PSRemittanceBusinessRequest.h"


@interface PSWechatHandler ()

@property (nonatomic, strong) PSPayInfo *payInfo;
@property (nonatomic, strong) PSWechatPayRequest *wechatPayRequest;
@property (nonatomic, strong) PSRemittanceBusinessRequest *remittanceBusinessRequest;
@property (nonatomic, strong) PSWechatInfo *wechatInfo;

@end

@implementation PSWechatHandler
@synthesize payCallback;
- (void)dealloc {
    
}

- (void)goPayWithPayInfo:(PSPayInfo *)payInfo {
    self.payInfo = payInfo;
    [self goPay];
}

//汇款
- (void)goRemittanceWithPayInfo:(PSPayInfo *)payInfo {
    self.payInfo = payInfo;
    [self goRemittance];
}

- (void)goRemittance {
    
    self.remittanceBusinessRequest = [PSRemittanceBusinessRequest new];
    self.remittanceBusinessRequest.jailId = self.payInfo.jailId;
    self.remittanceBusinessRequest.familyId = self.payInfo.familyId;
    self.remittanceBusinessRequest.prisonerId = self.payInfo.prisonerId;
    self.remittanceBusinessRequest.remitType = [self.payInfo.payment isEqualToString:@"WEIXIN"]?@"1":@"0";
    self.remittanceBusinessRequest.money = self.payInfo.money;
    @weakify(self)
    [self.remittanceBusinessRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSWechatPayResponse *payResponse = (PSWechatPayResponse *)response;
            if (payResponse.data) {
                self.wechatInfo = payResponse.data;
                [self wechatPay];
            }else{
                if (self.payCallback) {
                    self.payCallback(NO, [NSError errorWithDomain:@"微信支付接口数据异常" code:101 userInfo:nil]);
                }
            }
        }else{
            if (self.payCallback) {
                self.payCallback(NO, [NSError errorWithDomain:response.msg ? response.msg : @"微信支付接口异常" code:102 userInfo:nil]);
            }
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        @strongify(self)
        if (self.payCallback) {
            self.payCallback(NO, [NSError errorWithDomain:@"微信支付接口超时" code:103 userInfo:nil]);
        }
    }];
}

- (void)goPurchase {
    
    self.wechatPayRequest = [PSWechatPayRequest new];
    self.wechatPayRequest.jailId = self.payInfo.jailId;
    self.wechatPayRequest.familyId = self.payInfo.familyId;
    self.wechatPayRequest.itemName = self.payInfo.productName;
    self.wechatPayRequest.amount = self.payInfo.amount;
    self.wechatPayRequest.num = self.payInfo.quantity;
    self.wechatPayRequest.itemId = self.payInfo.productID;
    @weakify(self)
    [self.wechatPayRequest send:^(PSRequest *request, PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            PSWechatPayResponse *payResponse = (PSWechatPayResponse *)response;
            if (payResponse.data) {
                self.wechatInfo = payResponse.data;
                [self wechatPay];
            }else{
                if (self.payCallback) {
                    self.payCallback(NO, [NSError errorWithDomain:@"微信支付接口数据异常" code:101 userInfo:nil]);
                }
            }
        }else{
            if (self.payCallback) {
                self.payCallback(NO, [NSError errorWithDomain:response.msg ? response.msg : @"微信支付接口异常" code:102 userInfo:nil]);
            }
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        @strongify(self)
        if (self.payCallback) {
            self.payCallback(NO, [NSError errorWithDomain:@"微信支付接口超时" code:103 userInfo:nil]);
        }
    }];
}

#pragma mark - 调用微信支付
- (void)wechatPay {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = self.wechatInfo.partnerid;
    request.prepayId = self.wechatInfo.prepayid;
    request.package = self.wechatInfo.packageName;
    request.nonceStr = self.wechatInfo.noncestr;
    request.timeStamp = [self.wechatInfo.timestamp intValue];
    request.sign = self.wechatInfo.sign;
    [WXApi sendReq:request];
    
}



- (void)goPay {
    [self goPurchase];
}

@end
