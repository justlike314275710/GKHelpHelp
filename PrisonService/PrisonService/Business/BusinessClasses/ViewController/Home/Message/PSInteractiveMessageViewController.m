//
//  PSInteractiveMessageViewController.m
//  PrisonService
//
//  Created by kky on 2019/9/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSInteractiveMessageViewController.h"
#import "MJRefresh.h"
#import "PSMessageCell.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface PSInteractiveMessageViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
{
    BOOL isFirst;
}

@property (nonatomic, strong) UITableView *messageTableView;

@end

@implementation PSInteractiveMessageViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*title = NSLocalizedString(@"message", @"消息");
        self.title = title;
    }
    return self;
}

-(void)reloadDataReddot {
    self.dotIndex = 0;
    [self.messageTableView reloadData];
    
}

- (void)loadMore {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    @weakify(self)
    [messageViewModel loadMoreMessagesCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [messageViewModel refreshMessagesCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    }];
}

- (void)configureCell:(PSMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    PSMessage *message = messageViewModel.messages[indexPath.row];
    cell.titleLabel.text = message.title;
    cell.dateLabel.text = [message.createdAt timestampToDateString];
    cell.contentLabel.text = message.content;
    cell.iconImageView.image = IMAGE_NAMED(@"互动平台列表icon");
    if (indexPath.row<self.dotIndex) {
        cell.iconImageView.redDotNumber = 0;
        [cell.iconImageView ShowBadgeView];
    } else {
        [cell.iconImageView hideBadgeView];
    }
    
}

- (void)reloadContents {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    if (messageViewModel.hasNextPage) {
        @weakify(self)
        self.messageTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.messageTableView.mj_footer = nil;
    }
    [self.messageTableView.mj_header endRefreshing];
    [self.messageTableView.mj_footer endRefreshing];
    [self.messageTableView reloadData];
}

- (void)renderContents {
    self.messageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.messageTableView.dataSource = self;
    self.messageTableView.delegate = self;
    self.messageTableView.emptyDataSetSource = self;
    self.messageTableView.emptyDataSetDelegate = self;
    self.messageTableView.tableFooterView = [UIView new];
    @weakify(self)
    self.messageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.messageTableView registerClass:[PSMessageCell class] forCellReuseIdentifier:@"PSMessageCell"];
    [self.view addSubview:self.messageTableView];
    [self.messageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
//    [self refreshData];
    isFirst = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:KNotificationRefreshhd_message object:nil];
    //第一次刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData1) name:KNotificationRefreshhd_message_1 object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationRefreshhd_message object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationRefreshhd_message_1 object:nil];
}



-(void)refreshData1{
    if (isFirst==NO) {
       [self refreshData];
        isFirst = YES;
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    return messageViewModel.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"PSMessageCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSMessageCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    UIImage *emptyImage = messageViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return messageViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    NSString *tips = messageViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return messageViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSMessageViewModel *messageViewModel = (PSMessageViewModel *)self.viewModel;
    return messageViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
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



@end

