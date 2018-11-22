//
//  PSWriteFeedbackViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWriteFeedbackViewController.h"
#import "UITextView+Placeholder.h"

@interface PSWriteFeedbackViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *contentTextView;

@end

@implementation PSWriteFeedbackViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*feedback=NSLocalizedString(@"feedback", @"意见反馈");
        self.title = feedback;
    }
    return self;
}

- (void)sendFeedback {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    @weakify(self)
    [feedbackViewModel sendFeedbackCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            NSString*feedback=NSLocalizedString(@"Thank you for your feedback", @"提交成功,感谢您的反馈");
            [PSTipsView showTips:feedback];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [PSTipsView showTips:response.msg ? response.msg : @"提交失败"];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [self showNetError];
    }];
}

- (void)submitContent {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    @weakify(self)
    [feedbackViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            [self sendFeedback];
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
    NSString*feedback=NSLocalizedString(@"feedback", @"意见反馈");
    titleLabel.text = feedback;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(30);
    }];
    
    self.contentTextView = [UITextView new];
    self.contentTextView.font = FontOfSize(12);
    self.contentTextView.delegate = self;
    NSString*input_yourfeedback=NSLocalizedString(@"input_yourfeedback", @"请输入您的意见反馈");
    self.contentTextView.placeholder = input_yourfeedback;
    [self.view addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(200);
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    feedbackViewModel.content = textView.text;
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
