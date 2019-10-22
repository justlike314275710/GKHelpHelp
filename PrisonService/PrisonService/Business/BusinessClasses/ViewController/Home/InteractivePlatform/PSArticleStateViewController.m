//
//  PSArticleStateViewController.m
//  PrisonService
//
//  Created by kky on 2019/8/6.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleStateViewController.h"
#import "PSPlatformArticleCell.h"
#import "PSArticleStateViewModel.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PSTipsConstants.h"
#import "PSArticleDetailViewModel.h"
#import "PSDetailArticleViewController.h"

@interface PSArticleStateViewController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation PSArticleStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收藏文章";
    self.view.backgroundColor = [UIColor clearColor];
    [self setupUI];
    [self refreshData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
}

#pragma mark - PrivateMethods
- (void)setupUI {
    
    PSArticleStateViewModel *viewModel = (PSArticleStateViewModel *)self.viewModel;
    NSString *title = @"";
    if ([viewModel.status isEqualToString:@"published"]) {
        title = @"我的文章-已发布";
    } else if ([viewModel.status isEqualToString:@"not-published"]) {
        title = @"我的文章-未发布";
    } else if([viewModel.status isEqualToString:@"not-pass"]) {
        title = @"我的文章-未通过";
    }
    self.title = title;
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[PSPlatformArticleCell class] forCellReuseIdentifier:@"PSPlatformArticleCell"];
    self.tableView.tableFooterView = [UIView new];
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    
}

- (void)loadMore {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
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
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
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

- (void)reloadContents {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    if (messageViewModel.hasNextPage) {
        @weakify(self)
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.tableView.mj_footer = nil;
    }
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
}

//点赞
-(void)praiseActionid:(NSString *)id result:(PSPraiseResult)result {
    PSArticleDetailViewModel *viewModel = [PSArticleDetailViewModel new];
    viewModel.id = id;
    [viewModel praiseArticleCompleted:^(PSResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = [response msg];
            [PSTipsView showTips:msg];
            if (response.code == 200){
                result(YES);
            } else {
                result(NO);
            }
        });
    } failed:^(NSError *error) {
        [PSTipsView showTips:@"点赞失败"];
        result(NO);
    }];
}
//取消点赞
-(void)deletePraiseActionid:(NSString *)id result:(PSPraiseResult)result {
    PSArticleDetailViewModel *viewModel = [PSArticleDetailViewModel new];
    viewModel.id = id;
    [viewModel deletePraiseArticleCompleted:^(PSResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = [response msg];
            [PSTipsView showTips:msg];
            if (response.code == 200){
                result(YES);
            } else {
                result(NO);
            }
        });
    } failed:^(NSError *error) {
        [PSTipsView showTips:@"取消点赞失败"];
        result(NO);
    }];
}

#pragma mark - Setting&&Getting
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.width,KScreenHeight-kTopHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(249,248,254);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    return messageViewModel.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSPlatformArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSPlatformArticleCell"];
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    cell.model = [messageViewModel.messages objectAtIndex:indexPath.row];
    @weakify(self);
    cell.praiseBlock = ^(BOOL action, NSString *id, PSPraiseResult result) {
        @strongify(self);
        if (action) {
            [self praiseActionid:id result:result];
        } else {
            [self deletePraiseActionid:id result:result];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    PSArticleDetailModel*model = [messageViewModel.messages objectAtIndex:indexPath.row];
    
    PSArticleDetailViewModel *viewModel = [PSArticleDetailViewModel new];
    viewModel.id = model.id;
    PSDetailArticleViewController *DetailArticleVC = [[PSDetailArticleViewController alloc] initWithViewModel:viewModel];
    //点赞回调刷新
    DetailArticleVC.praiseBlock = ^(BOOL isPraise, NSString *id, BOOL result) {
        if (isPraise) {
            model.praiseNum = [NSString stringWithFormat:@"%ld",[model.praiseNum integerValue]+1];
            model.ispraise = @"1";
        } else {
            model.praiseNum = [NSString stringWithFormat:@"%ld",[model.praiseNum integerValue]-1];
            model.ispraise = @"0";
        }
        //刷新
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        KPostNotification(KNotificationRefreshInteractiveArticle, nil);
        KPostNotification(KNotificationRefreshCollectArticle, nil);
        KPostNotification(KNotificationRefreshMyArticle, nil);
        
    };
    
    //热度刷新
    DetailArticleVC.hotChangeBlock = ^(NSString *clientNum) {
        model.clientNum = clientNum;
        //刷新
        KPostNotification(KNotificationRefreshInteractiveArticle, nil);
        KPostNotification(KNotificationRefreshCollectArticle, nil);
        KPostNotification(KNotificationRefreshMyArticle, nil);
    };
    [self.navigationController pushViewController:DetailArticleVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 175;
}

#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    UIImage *emptyImage = messageViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return messageViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    NSString *tips = messageViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return messageViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSArticleStateViewModel *messageViewModel = (PSArticleStateViewModel *)self.viewModel;
    return messageViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}

@end
