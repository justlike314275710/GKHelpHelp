//
//  PSAccountEmailViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/23.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSAccountEmailViewController.h"
#import "PSRoundRectTextField.h"
#import "PSUnderlineTextField.h"
#import "PSAccountEditEmailViewModel.h"
#import "PSLoadingView.h"
@interface PSAccountEmailViewController ()<UITextFieldDelegate>
@property (nonatomic , strong) PSUnderlineTextField *accountEmailTextfield;
@end

@implementation PSAccountEmailViewController

- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*Zip_code=NSLocalizedString(@"Zip_code", @"邮编");
       self.title = Zip_code;
    }
    return self;
}



- (void)renderContents {
    NSString*save=NSLocalizedString(@"save", @"保存");
    [self createRightBarButtonItemWithTarget:self action:@selector(SaveEmailAction) title:save];
    CGFloat horizontalSpace = 15;
    self.accountEmailTextfield=[[PSUnderlineTextField alloc]initWithFrame:CGRectMake(horizontalSpace, horizontalSpace, SCREEN_WIDTH-2*horizontalSpace, 30)];
    NSString*enter_Zipcode=NSLocalizedString(@"enter_Zipcode", @"请输入邮编");
    self.accountEmailTextfield.placeholder=enter_Zipcode;
    self.accountEmailTextfield.borderStyle=UITextBorderStyleRoundedRect;
    self.accountEmailTextfield.keyboardType = UIKeyboardTypeNumberPad;
    self.accountEmailTextfield.delegate = self;
    self.accountEmailTextfield.font=AppBaseTextFont3;
    
    [self.view addSubview:self.accountEmailTextfield];
    PSAccountEditEmailViewModel *accountEditViewModel = (PSAccountEditEmailViewModel *)self.viewModel;
    [self.accountEmailTextfield setBk_didEndEditingBlock:^(UITextField *textField) {
        accountEditViewModel.email=textField.text;
    }];

    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *toString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (toString.length) {
        NSString *stringRegex;
        if (textField == self.accountEmailTextfield) {
            stringRegex = @"[0-9]\\d{0,5}?";
        }
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
        BOOL flag = [phoneTest evaluateWithObject:toString];
        if (flag==NO) {
            [PSTipsView showTips:@"请输入正确不超过6位数的邮编！"];
        }
        return flag;
    }
    return YES;
}

- (BOOL)p_judge:(NSString *)emailStr {
    
    BOOL flag = false;
    NSString *stringRegex = @"[0-9]\\d{0,5}?";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
    flag = [phoneTest evaluateWithObject:emailStr];
    return flag;
}

- (void)SaveEmailAction {
    [self.view endEditing:YES];
    [[PSLoadingView sharedInstance]show];
    PSAccountEditEmailViewModel*accountEditViewModel=(PSAccountEditEmailViewModel *)self.viewModel;
    if (accountEditViewModel.email.length==0) {
         [[PSLoadingView sharedInstance]dismiss];
        NSString*enter_Zipcode=NSLocalizedString(@"enter_Zipcode", @"请输入邮编");
        [PSTipsView showTips:enter_Zipcode];
    } else {
        [accountEditViewModel requestAccountEmailCompleted:^(PSResponse *response) {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    // Do any additional setup after loading the view.
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
