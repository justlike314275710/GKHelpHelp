//
//  PSWriteFeedbackViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWriteFeedbackViewController.h"
#import "UITextView+Placeholder.h"
#import "FeedbackCell.h"
#import "FeedloadImgView.h"
#import "ReactiveObjC.h"
#import "PSFWriteFeedSuccessViewController.h"
#import "FeedbackTypeModel.h"
#import "PSRegisterViewModel.h"
#import "NSString+emoji.h"

@interface PSWriteFeedbackViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UITextView  *contentTextView;
@property (nonatomic, strong) UILabel *countLab; //字数
@property (nonatomic, assign) NSInteger selecldIndex;
@property (nonatomic, strong) NSMutableArray *imageUrls;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFeedbackTypes {
    
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    @weakify(self)
    [feedbackViewModel sendFeedbackTypesCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            [self.tableview reloadData];
        }else{
           [PSTipsView showTips:response.msg ? response.msg : @"获取反馈建议反馈类别失败"];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [self showNetError];
    }];
    
}
- (void)sendFeedback {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    @weakify(self)
    [feedbackViewModel sendFeedbackCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
//            NSString*feedback=NSLocalizedString(@"Thank you for your feedback", @"提交成功,感谢您的反馈");
//            [PSTipsView showTips:feedback];
            PSFWriteFeedSuccessViewController *storageViewController = [[PSFWriteFeedSuccessViewController alloc] initWithViewModel:[PSViewModel new]];
            [self.navigationController pushViewController:storageViewController animated:YES];
//            [self.navigationController popViewControllerAnimated:YES];
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
     FeedbackTypeModel *typeModel = feedbackViewModel.reasons[self.selecldIndex];
    feedbackViewModel.type = typeModel.id;
    feedbackViewModel.content = _contentTextView.text;
    if (self.imageUrls.count>0) {
        NSString *imageUrl = @"";
        for (NSString *url in self.imageUrls) {
            imageUrl = [NSString stringWithFormat:@"%@;%@",imageUrl,url];
        }
        if ([imageUrl hasPrefix:@";"]) {
            imageUrl = [imageUrl substringFromIndex:1];
        }
        feedbackViewModel.imageUrls = imageUrl;
        NSLog(@"%@",imageUrl);
    } else {
        feedbackViewModel.imageUrls = @"";
    }
    
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
//    [self renderContents];
    self.view.backgroundColor = AppBaseBackgroundColor2;
    self.selecldIndex = 0;
    [self getFeedbackTypes];
    [self p_setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
    
}

#pragma mark - Private Methods

- (void)p_setUI {
    
    [self.view addSubview:self.scrollview];
    
    UIView *oneView = [[UIView alloc] initWithFrame:CGRectMake(0,20 ,SCREEN_WIDTH,195)];
    oneView.backgroundColor = [UIColor clearColor];
    oneView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    oneView.layer.shadowOffset = CGSizeMake(0,3);
    oneView.layer.shadowOpacity = 1;
    oneView.layer.shadowRadius = 4;
    [self.scrollview addSubview:oneView];
    [oneView addSubview:self.tableview];

 
    
    UIView *secondeView = [[UIView alloc] initWithFrame:CGRectMake(0,oneView.bottom+18,self.scrollview.width, 160)];
    secondeView.backgroundColor = [UIColor whiteColor];
    secondeView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    secondeView.layer.shadowOffset = CGSizeMake(0,3);
    secondeView.layer.shadowOpacity = 1;
    secondeView.layer.shadowRadius = 4;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(18,8,secondeView.width-48, 30)];
    titleLab.text = @"请补充详细问题和意见";
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.textColor = UIColorFromRGB(51, 51, 51);
    titleLab.font = FontOfSize(12);
    [secondeView addSubview:titleLab];
    
    UIView *headLine = [[UIView alloc] initWithFrame:CGRectMake(15,titleLab.bottom+4, secondeView.width-30, 1)];
    headLine.backgroundColor = UIColorFromRGB(234, 235, 238);
    [secondeView addSubview:headLine];
    
    self.contentTextView.frame = CGRectMake(15,headLine.bottom+8,secondeView.width-30, 100);
    [secondeView addSubview:self.contentTextView];
    
    self.countLab.frame = CGRectMake(secondeView.width-75,secondeView.height-25, 60, 21);
    [secondeView addSubview:self.countLab];
    
    UIView *thirdView = [[UIView alloc] initWithFrame:CGRectMake(0, secondeView.bottom+18,self.scrollview.width, 130)];
    thirdView.backgroundColor = [UIColor whiteColor];
    thirdView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    thirdView.layer.shadowOffset = CGSizeMake(0,3);
    thirdView.layer.shadowOpacity = 1;
    thirdView.layer.shadowRadius = 4;
    [self.scrollview addSubview:thirdView];

    UILabel *thirdTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(18,8,secondeView.width-48, 30)];
    thirdTitleLab.text = @"请提供相关问题的截图或照片（最多4张）";
    thirdTitleLab.numberOfLines = 0;
    thirdTitleLab.textAlignment = NSTextAlignmentLeft;
    thirdTitleLab.textColor = UIColorFromRGB(51, 51, 51);
    thirdTitleLab.font = FontOfSize(12);
    [thirdView addSubview:thirdTitleLab];


    FeedloadImgView *loadImg = [[FeedloadImgView alloc] initWithFrame:CGRectMake(0,thirdTitleLab.bottom, thirdView.width,100) count:4];
    [thirdView addSubview:loadImg];
    loadImg.feedloadResultBlock = ^(NSMutableArray *result) {
        self.imageUrls = result;
    };

    [self.scrollview addSubview:secondeView];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(15,self.scrollview.bottom+13,self.view.width-30, 44);
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius= 4;
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    submitBtn.backgroundColor = UIColorFromRGB(83, 119, 185);
    [self.view addSubview:submitBtn];
    [submitBtn bk_whenTapped:^{
        [self submitContent];
    }];
}

#pragma mark - Delegate
#pragma mark  UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    feedbackViewModel.content = textView.text;
    if ([NSString hasEmoji:textView.text]||[NSString stringContainsEmoji:textView.text]) {
        [PSTipsView showTips:@"不能输入表情！"];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isFirstResponder]) {
        
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            [PSTipsView showTips:@"不能输入表情！"];
            return NO;
        }
        //判断键盘是不是九宫格键盘
        if ([NSString isNineKeyBoard:text] ){
            return YES;
        }else{
            if ([NSString hasEmoji:text] || [NSString stringContainsEmoji:text]){
                [PSTipsView showTips:@"不能输入表情！"];
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark UITableViewDelegate&&UITableViewDatalist
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSFeedbackViewModel *viewModel = (PSFeedbackViewModel *)self.viewModel;
    return viewModel.reasons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedbackCell *cell = [[FeedbackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FeedbackCell"];
    PSFeedbackViewModel *viewModel = (PSFeedbackViewModel *)self.viewModel;
    FeedbackTypeModel *typeModel = viewModel.reasons[indexPath.row];
    NSString *title = typeModel.desc?[NSString stringWithFormat:@"%@: %@",typeModel.name,typeModel.desc]:typeModel.name;
    cell.titleLab.text = title;
    if (indexPath.row == viewModel.reasons.count-1) cell.lineImg.hidden = YES;
    if (self.selecldIndex == indexPath.row) {
        cell.seleImg.image = [UIImage imageNamed:@"writeFeedsel"];
    } else {
        cell.seleImg.image = [UIImage imageNamed:@"writeFeednosel"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selecldIndex = indexPath.row;
    [self.tableview reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [UIView new];
    headView.frame = CGRectMake(0, 0,tableView.width, 44);
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, (headView.height-30)/2,headView.width-20, 30)];
    titleLab.text = @"（单选）请选择您想反馈的问题点";
    titleLab.font = FontOfSize(12);
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.textColor = UIColorFromRGB(51, 51, 51);
    
    UIView *headLine = [[UIView alloc] initWithFrame:CGRectMake(20,headView.height-1, headView.width-40, 1)];
    headLine.backgroundColor = UIColorFromRGB(234, 235, 238);
    [headView addSubview:headLine];
    [headView addSubview:titleLab];
    return headView;
}

#pragma mark Setting&&Getting
- (UIScrollView *)scrollview {
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT-138)];
        _scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    return _scrollview;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,195)];
        [_tableview registerClass:[FeedbackCell class] forCellReuseIdentifier:@"FeedbackCell"];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.scrollEnabled = NO;
    }
    return _tableview;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.placeholder = @"请输入不少于10个字的描述";
        _contentTextView.delegate = self;
        @weakify(self);
        [_contentTextView.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            if (x.length>300) {
                _contentTextView.text = [x substringToIndex:299];
                [PSTipsView showTips:@"请输入不多于300个字的描述"];
            }
            self.countLab.text = [NSString stringWithFormat:@"%lu/300",_contentTextView.text.length];
        }];
    }
    return _contentTextView;
}

- (UILabel *)countLab {
    if (!_countLab) {
        _countLab = [[UILabel alloc] init];
        _countLab.text = @"0/300";
        _countLab.textColor = UIColorFromRGB(153, 153, 153);
        _countLab.font = FontOfSize(11);
        _countLab.textAlignment = NSTextAlignmentRight;
    }
    return _countLab;
}

- (NSMutableArray *)imageUrls {
    if (!_imageUrls) {
        _imageUrls = [NSMutableArray array];
    }
    return _imageUrls;
}





@end
