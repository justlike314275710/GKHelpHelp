//
//  PSWriteComplaintViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWriteComplaintViewController.h"
#import "PSUnderlineTextField.h"
#import "UITextView+Placeholder.h"

@interface PSWriteComplaintViewController () <UITextViewDelegate>

@property (nonatomic, strong) PSUnderlineTextField *titleTextField;
@property (nonatomic, strong) UITextView *contentTextView;

@end

@implementation PSWriteComplaintViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*complain_advice=NSLocalizedString(@"complain_advice", @"投诉建议");
        self.title = complain_advice;
    }
    return self;
}

- (void)sendSuggestion {
    PSWriteSuggestionViewModel *suggestionViewModel = (PSWriteSuggestionViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [suggestionViewModel sendSuggestionCompleted:^(PSResponse *response) {
        [[PSLoadingView sharedInstance] dismiss];
        if (response.code == 200) {
            NSString*prison_reply=NSLocalizedString(@"prison_reply", @"提交成功,请耐心等待监狱回复");
            [PSTipsView showTips:prison_reply];
            if (self.sendCompleted) {
                self.sendCompleted();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString *msg = NSLocalizedString(@"submission Failed", @"提交失败");
            [PSTipsView showTips:response.msg ? response.msg :msg];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}

- (void)submitContent {
    PSWriteSuggestionViewModel *suggestionViewModel = (PSWriteSuggestionViewModel *)self.viewModel;
    @weakify(self)
    [suggestionViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            [self sendSuggestion];
        }else{
            [PSTipsView showTips:tips];
        }
    }];
}

- (void)renderContents {
    CGFloat horizontalSpace = 15;
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = FontOfSize(27);
    titleLabel.textColor = UIColorFromHexadecimalRGB(0x333333);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    NSString*complain_advice=NSLocalizedString(@"complain_advice", @"投诉建议");
    titleLabel.text = complain_advice;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(30);
    }];
    self.titleTextField = [PSUnderlineTextField new];
    NSString*Please_enter_title=NSLocalizedString(@"Please_enter_title", @"请输入标题");
    self.titleTextField.placeholder = Please_enter_title;
    self.titleTextField.font = FontOfSize(12);
    PSWriteSuggestionViewModel *suggestionViewModel = (PSWriteSuggestionViewModel *)self.viewModel;
    [self.titleTextField setBk_didEndEditingBlock:^(UITextField *textField) {
        suggestionViewModel.title = textField.text;
    }];
    [self.view addSubview:self.titleTextField];
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(35);
    }];
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton addTarget:self action:@selector(submitContent) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = AppBaseTextFont1;
    UIImage *bgImage = [UIImage imageNamed:@"universalBtGradientBg"];
    [submitButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*submit=NSLocalizedString(@"submit", @"提交");
    [submitButton setTitle:submit forState:UIControlStateNormal];
    [self.view addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(bgImage.size);
    }];
    self.contentTextView = [UITextView new];
    self.contentTextView.font = FontOfSize(12);
NSString*Please_enter_your_complaint=NSLocalizedString(@"Please_enter_your_complaint", @"请输入您的投诉意见，我们将不断为您改进。");
    self.contentTextView.placeholder = Please_enter_your_complaint;
    self.contentTextView.delegate = self;
    [self.view addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(self.titleTextField.mas_bottom);
        make.height.mas_equalTo(200);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    PSWriteSuggestionViewModel *suggestionViewModel = (PSWriteSuggestionViewModel *)self.viewModel;
    suggestionViewModel.contents = textView.text;
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
