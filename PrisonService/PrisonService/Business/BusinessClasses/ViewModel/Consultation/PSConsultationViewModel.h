//
//  PSConsultationViewModel.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"

@interface PSConsultationViewModel : PSViewModel
@property (nonatomic , strong) NSData *consultaionData;
@property (nonatomic , strong) UIImage* consultaionImage;
@property (nonatomic , assign) NSInteger statusCode;
@property (nonatomic , assign) NSInteger code;
@property (nonatomic , strong) NSString *consultaionId;


@property (nonatomic , strong) NSArray  *categories;
@property (nonatomic , strong) NSString *lawyerId;
@property (nonatomic , strong) NSString *describe;
@property (nonatomic , strong) NSArray  *attachments;
@property (nonatomic , assign) int reward;

@property (nonatomic , strong) NSArray *myAdviceArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasNextPage;

- (void)checkDataWithCallback:(CheckDataCallback)callback ;
- (void)uploadConsultationImagesCompleted:(CheckDataCallback)callback;
-(void)requestAddConsultationCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;

- (void)refreshMyAdviceCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
- (void)loadMyAdviceCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
@end
