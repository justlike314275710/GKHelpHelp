//
//  PSMemberViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/10.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMemberViewController.h"
#import "PSRoundRectTextField.h"
#import "PSRegisterViewModel.h"
#import "PSRegisterPrisonView.h"
#import "PSPrisonContentViewController.h"
#import "MemberGuideVC.h"


@interface PSMemberViewController ()

@property (nonatomic, strong) PSRegisterPrisonView *prisonView;

@end

@implementation PSMemberViewController
#pragma mark - Event
- (void)selectAction {
    [self.view endEditing:YES];
    PSPrisonContentViewController *prisonSelectViewController = [[PSPrisonContentViewController alloc] initWithViewModel:self.viewModel];
    [prisonSelectViewController setSelectedJailCallback:^{
        [self visitorDidSelectedJail];
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:prisonSelectViewController animated:YES completion:nil];
}

- (void)visitorDidSelectedJail {
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    self.prisonView.proviceLabel.text = registerViewModel.selectedProvince.name;
    self.prisonView.cityLabel.text = registerViewModel.selectedCity.name;
    self.prisonView.prisonLabel.text = registerViewModel.selectedJail.title;
}

#pragma mark - UI
- (void)renderContents {
    CGFloat sidePadding = 40;
    CGFloat vHeight = 44;
    CGFloat verticalPadding = RELATIVE_HEIGHT_VALUE(25);
    UIFont *textFont = AppBaseTextFont2;
    UIColor *textColor = AppBaseTextColor1;
    
    PSRoundRectTextField *relationTextField = [[PSRoundRectTextField alloc] init];
    relationTextField.font = textFont;
    relationTextField.placeholder = @"囚号";
    relationTextField.textColor = textColor;
    [self.view addSubview:relationTextField];
    [relationTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(vHeight);
        make.top.mas_equalTo(0);
    }];
    PSRegisterViewModel *registerViewModel = (PSRegisterViewModel *)self.viewModel;
    [relationTextField setBk_didEndEditingBlock:^(UITextField *textField) {
         registerViewModel.prisonerNumber = textField.text;
        //registerViewModel.relationShip = textField.text;
    }];
    
    PSRoundRectTextField *prisonerTextField = [[PSRoundRectTextField alloc] init];
    prisonerTextField.font = textFont;
    prisonerTextField.placeholder = @"与服刑人员关系";
    prisonerTextField.textColor = textColor;
    [self.view addSubview:prisonerTextField];
    [prisonerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.height.mas_equalTo(vHeight);
        make.top.mas_equalTo(relationTextField.mas_bottom).offset(verticalPadding);
    }];
    [prisonerTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        //registerViewModel.prisonerNumber = textField.text;
         registerViewModel.relationShip = textField.text;
    }];
    
    self.prisonView = [PSRegisterPrisonView new];
    @weakify(self)
    [self.prisonView.proviceButton bk_whenTapped:^{
        @strongify(self)
        [self selectAction];
    }];
    [self.prisonView.cityButton bk_whenTapped:^{
        @strongify(self)
        [self selectAction];
    }];
    [self.prisonView.prisonButton bk_whenTapped:^{
        @strongify(self)
        [self selectAction];
    }];
    [self.view addSubview:self.prisonView];
    [self.prisonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sidePadding);
        make.right.mas_equalTo(-sidePadding);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(prisonerTextField.mas_bottom).offset(verticalPadding);
    }];
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
    //[self presentViewController:[[MemberGuideVC alloc]init] animated:YES completion:nil];
  
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
