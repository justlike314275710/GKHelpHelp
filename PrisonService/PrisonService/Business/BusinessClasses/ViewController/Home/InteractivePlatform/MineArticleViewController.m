//
//  MineArticleViewController.m
//  PrisonService
//
//  Created by kky on 2019/8/2.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "MineArticleViewController.h"
#import "PSPlatformArticleCell.h"
#import "PSMyTotalArtcleListViewModel.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "PSTipsConstants.h"
#import "PSPlatformHeadView.h"
#import "PSArticleStateViewController.h"
#import "PSArticleStateViewModel.h"
#import "PSArticleDetailViewModel.h"
#import "PSDetailArticleViewController.h"

@interface MineArticleViewController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>{
    BOOL _isFirst;
}
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation MineArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的文章";
    self.view.backgroundColor = [UIColor clearColor];
    [self setupUI];
//    [self refreshData];
    _isFirst = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:KNotificationRefreshMyArticle object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(coverWindowClick) name:@"statusBarTappedNotification" object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)coverWindowClick {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    if (messageViewModel.articles.count>1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - PrivateMethods
- (void)setupUI {
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
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    @weakify(self)
    [messageViewModel loadMoreMessagesCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

-(void)firstRefreshData {
    if (!_isFirst) {
        [self refreshData];
        _isFirst = YES;
    }
}

- (void)refreshData {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
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
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
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

#pragma mark - Setting&&Getting
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.width,KScreenHeight-164) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColorFromRGB(249,248,254);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
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

#pragma mark - Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    return [messageViewModel.articles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    NSArray *models = [messageViewModel.articles objectAtIndex:section];
    return models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSPlatformArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSPlatformArticleCell"];
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    NSArray *models = [messageViewModel.articles objectAtIndex:indexPath.section];
    cell.model = [models objectAtIndex:indexPath.row];
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
    
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    NSArray *models = [messageViewModel.articles objectAtIndex:indexPath.section];
    PSArticleDetailModel*model = [models objectAtIndex:indexPath.row];
    
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
    };
    
    //热度刷新
    DetailArticleVC.hotChangeBlock = ^(NSString *clientNum) {
        model.clientNum = clientNum;
        //刷新
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        KPostNotification(KNotificationRefreshInteractiveArticle, nil);
        KPostNotification(KNotificationRefreshCollectArticle, nil);
    };
    [self.navigationController pushViewController:DetailArticleVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 175;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    NSArray *models = [messageViewModel.articles objectAtIndex:section];
    PSArticleDetailModel *model = [models objectAtIndex:0];
    PSArticleStateViewModel *viewModel = [PSArticleStateViewModel new];
    NSString *title = @"";
    if ([model.status isEqualToString:@"pass"]) {
        title = @"已发布";
        viewModel.status = @"published";
    } else if ([model.status isEqualToString:@"publish"]||[model.status isEqualToString:@"shelf"]) {
        title = @"未发布";
        viewModel.status = @"not-published";
    } else if([model.status isEqualToString:@"reject"]) {
        title = @"未通过";
        viewModel.status = @"not-pass";
    }
    
    PSPlatformHeadView *headView = [[[PSPlatformHeadView alloc] init] initWithFrame:CGRectMake(0, 0, KScreenWidth,40) title:title];
    headView.block = ^(NSString * _Nonnull title) {
        PSArticleStateViewController *ArticleStateVC = [[PSArticleStateViewController alloc] initWithViewModel:viewModel];
        [self.navigationController pushViewController:ArticleStateVC  animated:YES];
    };
    return headView;
}


#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    UIImage *emptyImage = messageViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return messageViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    NSString *tips = messageViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return messageViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSMyTotalArtcleListViewModel *messageViewModel = (PSMyTotalArtcleListViewModel *)self.viewModel;
    return messageViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}



@end
