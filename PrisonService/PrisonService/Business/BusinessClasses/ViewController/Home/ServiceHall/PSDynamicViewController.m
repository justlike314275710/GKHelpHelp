//
//  PSDynamicViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSDynamicViewController.h"

@interface PSDynamicViewController ()

@end

@implementation PSDynamicViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
   // self.title = work_dynamic;
    self.title =work_dynamic;
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"userCenterAccountBack"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        //        make.size.mas_equalTo(CGSizeMake(44, CGRectGetHeight(navBar.frame)));
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(StatusHeight);
    }];
    
}

- (BOOL)hiddenNavigationBar{
    return YES;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
