//
//  PSAccountAddressViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/23.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "UITextView+Placeholder.h"
#import "PSAccountAddressViewController.h"
#import "PSRoundRectTextField.h"
#import "PSUnderlineTextField.h"
#import "PSAccountEditAddressViewModel.h"
@interface PSAccountAddressViewController ()<UITextViewDelegate>
@property (nonatomic , strong) UITextView *accountAddressTextfield;
@end

@implementation PSAccountAddressViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
         NSString*Home_address=NSLocalizedString(@"Home_address", @"家庭地址");
        self.title =Home_address;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    // Do any additional setup after loading the view.
}
- (void)renderContents {
    NSString*save=NSLocalizedString(@"save", @"保存");
    [self createRightBarButtonItemWithTarget:self action:@selector(SaveAccountAddressAction) title:save];
    CGFloat horizontalSpace = 15;
    self.accountAddressTextfield=[[UITextView alloc]initWithFrame:CGRectMake(horizontalSpace,horizontalSpace, SCREEN_WIDTH-2*horizontalSpace, 60)];
    //self.accountAddressTextfield.borderStyle=UITextBorderStyleRoundedRect;
     NSString*enter_Home_address=NSLocalizedString(@"enter_Home_address", @"请输入家庭地址");
    self.accountAddressTextfield.placeholder=enter_Home_address;
    self.accountAddressTextfield.font=AppBaseTextFont3;
    self.accountAddressTextfield.delegate=self;
    [self.view addSubview:self.accountAddressTextfield];
    
    self.accountAddressTextfield.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.accountAddressTextfield.layer.borderColor = [AppBaseLineColor CGColor]; self.accountAddressTextfield.layer.borderWidth = 1.0;
    [self.accountAddressTextfield.layer setMasksToBounds:YES];
    
    
    NSString*historyAddress=[[NSUserDefaults standardUserDefaults] objectForKey:@"historyAddress"];

    if (historyAddress.length!=0) {
        self.accountAddressTextfield.text=historyAddress;
    }
    
}

- (void)SaveAccountAddressAction {
    [self.view endEditing:YES];
    [[PSLoadingView sharedInstance]show];
    PSAccountEditAddressViewModel*accountEditViewModel=(PSAccountEditAddressViewModel *)self.viewModel;
    if (accountEditViewModel.address.length==0) {
         [[PSLoadingView sharedInstance]dismiss];
        [PSTipsView showTips:@"请输入家庭地址"];
    } else {
           [[NSUserDefaults standardUserDefaults]setObject:self.accountAddressTextfield.text forKey:@"historyAddress"];
        [accountEditViewModel requestAccountAdressCompleted:^(PSResponse *response) {
            [[PSLoadingView sharedInstance]dismiss];
            [PSTipsView showTips:accountEditViewModel.msg];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } failed:^(NSError *error) {
            [[PSLoadingView sharedInstance]dismiss];
            [self showNetError:error];
        }];
    }
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    PSAccountEditAddressViewModel *accountEditViewModel = (PSAccountEditAddressViewModel *)self.viewModel;
    accountEditViewModel.address=textView.text;
  
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
