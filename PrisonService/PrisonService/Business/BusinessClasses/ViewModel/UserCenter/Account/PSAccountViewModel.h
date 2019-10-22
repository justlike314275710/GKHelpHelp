//
//  PSAccountViewModel.h
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSViewModel.h"
#import "PSAccountInfoItem.h"
#import "PSPrisonerDetail.h"
#import "PSUserSession.h"
typedef void (^SucessImageBlock)(UIImage *image);
@interface PSAccountViewModel : PSViewModel
@property (nonatomic , strong) NSString *gender;
@property (nonatomic , strong) NSString *postalCode;
@property (nonatomic , strong) NSString *homeAddress;
@property (nonatomic, strong)  PSUserSession *session;
@property (nonatomic, strong,  readonly) NSArray *infoItems;
@property (nonatomic, strong)  UIImage *avatarImage;

- (void)requestAccountBasicinfoCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback;
//上传头像
- (void)uploadUserAvatarImageCompleted:(CheckDataCallback)callback;

//获取我的头像
-(void)getUserAvatarImageCompleted:(SucessImageBlock)completedCallback
                            failed:(RequestDataFailed)failedCallback;

//获取用户头像
-(void)getAvatarImageUserName:(NSString *)username Completed:(SucessImageBlock)completedCallback
                            failed:(RequestDataFailed)failedCallback;

@end
