//
//  PSMessageViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/12.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMessageViewController.h"
#import "MJRefresh.h"
#import "PSMessageCell.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSTipsConstants.h"
#import "UITableView+FDTemplateLayoutCell.h"


@interface PSMessageViewController ()<UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
{

}

@property (nonatomic, strong) UITableView *messageTableView;

@end

@implementation PSMessageViewController
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
    [self refreshData];
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
    cell.dateLabel.text = [message.createdAt timestampToDateDetailSecondString];
    cell.contentLabel.text = message.content;
    cell.iconImageView.image = IMAGE_NAMED(@"探视消息列表icon");
    if ([message.isNoticed isEqualToString:@"0"]) {
        cell.iconImageView.redDotNumber = 0;
        [cell.iconImageView ShowBadgeView];
        cell.titleLabel.textColor = UIColorFromRGB(51,51,51);
        cell.dateLabel.textColor =  UIColorFromRGB(51,51,51);
        cell.contentLabel.textColor = UIColorFromRGB(51,51,51);
    } else {
        [cell.iconImageView hideBadgeView];
        cell.titleLabel.textColor = UIColorFromRGB(153, 153, 153);
        cell.dateLabel.textColor = UIColorFromRGB(153, 153, 153);
        cell.contentLabel.textColor = UIColorFromRGB(153, 153, 153);
    }
}

- (void)reloadContents {
    
    self.view.backgroundColor = UIColorFromRGB(249, 248, 254);
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
        self.dotIndex = 0;
        if (self.reloaDot) {
            self.reloaDot();
        }
    }];
    [self.messageTableView registerClass:[PSMessageCell class] forCellReuseIdentifier:@"PSMessageCell"];
    [self.view addSubview:self.messageTableView];
    [self.messageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
        make.top.mas_equalTo(10);
        make.right.left.bottom.mas_equalTo(0);
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
    [self refreshData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiRefreshData:) name:KNotificationRefreshts_message object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationRefreshts_message object:nil];
}

-(void)notiRefreshData:(NSNotification*)noti{
    [self refreshData];
    if (self.reloaDot) {
        self.reloaDot();
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
