//
//  UIViewController+Author.m
//  PrisonService
//
//  Created by kky on 2019/5/20.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "UIViewController+Author.h"
#import "Authorization.h"
#import "PSSessionManager.h"
#import "PSLoginViewModel.h"
#import "PSSessionNoneViewController.h"

@implementation UIViewController (Author)

- (NSDictionary *)getAuthorDict
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Jurisdiction" ofType:@"plist"];
    NSDictionary *alldic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *selfClassName = NSStringFromClass([self class]);
    NSDictionary *dic = [alldic valueForKey:selfClassName];
    return dic;
}
//事件权限处理
- (void)showPrisonLimits:(NSString *)key limitBlock:(limitBlock)block {
    NSDictionary *dic = [self getAuthorDict];
    if (dic) {
        NSString * limit = [dic valueForKey:key];
        if ([limit isEqualToString:@"0"]) {
            if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]) {
                
                [[PSSessionManager sharedInstance]doLogout];
            } else {
            NSString*coming_soon=NSLocalizedString(@"coming_soon", @"该监狱暂未开通此功能");
                [PSTipsView showTips:coming_soon];}
        } else {
            if (block){
                block(YES);
            }
        }
    }
}

//游客和未认证状态处理
- (void)doNotLoginPassed{
    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]) {
        [[PSSessionManager sharedInstance]doLogout];
    } else {
        self.hidesBottomBarWhenPushed=YES;
        PSLoginViewModel*viewModel=[[PSLoginViewModel alloc]init];
        [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]initWithViewModel:viewModel] animated:YES];
        self.hidesBottomBarWhenPushed=NO;
    }
}

@end
