//
//  PSTransactionRecord.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSInteger, PSRefundType) {
    PSRefundRecharge = 0,//充值收入
    PSRefundMeeting = 1,//会见扣款
    PSRefundRefund = 2,//退款申请
    PSRefundSuccess=3,//退款成功
    PSRefundFail=4,//退款失败
    PSRefundCardRecharge=5,//亲情卡充值
};


@protocol PSTransactionRecord <NSObject>
@end

@interface PSTransactionRecord : JSONModel

@property (nonatomic, strong)  NSString<Optional>* familyId;
@property (nonatomic, strong)  NSString<Optional>* reason;
@property (nonatomic, strong)  NSString<Optional>* createdAt;
@property (nonatomic, strong)  NSString<Optional>* money;
@property (nonatomic, strong)  NSString<Optional>* id;
@property (nonatomic, strong)  NSString<Optional>* jailId;
@property (nonatomic, assign)  PSRefundType type;
@property (nonatomic, strong)  NSString<Optional>* rechargeTotal;
@property (nonatomic, strong)  NSString<Optional>* refundTotal;
@property (nonatomic, strong)  NSString<Optional>* createdMonth;
@property (nonatomic, strong)  NSString<Optional>* consumeTotal;
@property (nonatomic, strong)  NSString<Optional>* orderNo;
@property (nonatomic, strong)  NSString<Optional>* paymentType;


@end


@interface PSTransactionSuperRecord : JSONModel

@property (nonatomic, strong)  NSString<Optional>* rechargeTotal;
@property (nonatomic, strong)  NSString<Optional>* refundTotal;
@property (nonatomic, strong)  NSArray<PSTransactionRecord,Optional> *details;
@property (nonatomic, strong)  NSString<Optional>* createdMonth;
@property (nonatomic, strong)  NSString<Optional>* consumeTotal;


@end


