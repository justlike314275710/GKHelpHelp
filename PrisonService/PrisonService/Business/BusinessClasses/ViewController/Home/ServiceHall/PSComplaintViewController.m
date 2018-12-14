//
//  PSComplaintViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSComplaintViewController.h"
#import "PSComplaintSuggestionCell.h"
#import "NSString+Date.h"
#import "NSDate+Components.h"
#import "PSCommentsViewController.h"
#import "PSContentManager.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"

@interface PSComplaintViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *complaintTableView;

@end

@implementation PSComplaintViewController
- (void)loadMore {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    @weakify(self)
    [suggestionViewModel loadMoreSuggestionsCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [suggestionViewModel refreshSuggestionsCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    }];
}

- (void)reloadContents {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    if (suggestionViewModel.hasNextPage) {
        @weakify(self)
        self.complaintTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.complaintTableView.mj_footer = nil;
    }
    [self.complaintTableView.mj_header endRefreshing];
    [self.complaintTableView.mj_footer endRefreshing];
    [self.complaintTableView reloadData];
}

- (void)renderContents {
    _complaintTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.complaintTableView.dataSource = self;
    self.complaintTableView.delegate = self;
    self.complaintTableView.emptyDataSetSource = self;
    self.complaintTableView.emptyDataSetDelegate = self;
    self.complaintTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.complaintTableView.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.complaintTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.complaintTableView registerClass:[PSComplaintSuggestionCell class] forCellReuseIdentifier:@"PSComplaintSuggestionCell"];
    self.complaintTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.complaintTableView];
    [self.complaintTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
    [self refreshData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    return suggestionViewModel.suggestions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 145;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSComplaintSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSComplaintSuggestionCell"];
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    PSSuggestion *suggestion = suggestionViewModel.suggestions[indexPath.row];
    cell.contentLabel.text = suggestion.contents;
    NSDate *date = [suggestion.createdAt stringToDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    cell.timeLabel.text = [date yearMonthDay];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    PSSuggestion *suggestion = suggestionViewModel.suggestions[indexPath.row];
    PSCommentsViewModel *viewModel = [[PSCommentsViewModel alloc] initWithSuggestion:suggestion];
    PSCommentsViewController *commentsViewController = [[PSCommentsViewController alloc] initWithViewModel:viewModel];
    [[PSContentManager sharedInstance].currentNavigationController pushViewController:commentsViewController animated:YES];
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    UIImage *emptyImage = suggestionViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return suggestionViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    NSString *tips = suggestionViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return suggestionViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSSuggestionViewModel *suggestionViewModel = (PSSuggestionViewModel *)self.viewModel;
    return suggestionViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
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
