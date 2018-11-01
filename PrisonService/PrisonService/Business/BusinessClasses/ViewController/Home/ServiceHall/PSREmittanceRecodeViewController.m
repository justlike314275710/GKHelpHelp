//
//  PSREmittanceRecodeViewController.m
//  PrisonService
//
//  Created by kky on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSREmittanceRecodeViewController.h"
#import "PSRemittanceRecordCell.h"
#import "PSRemittancePayStateViewController.h"
#import "AFNetworking.h"
#import "PSBusinessConstants.h"
#import "PSUserSession.h"
#import "PSCache.h"
#import "RemittanceRecode.h"
#import "MJExtension.h"
#import "PSRemittanceRecodeViewModel.h"
#import "PSTipsConstants.h"
#import "XXEmptyView.h"
#import "UIView+Empty.h"
@interface PSREmittanceRecodeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *myTableview;

@end

@implementation PSREmittanceRecodeViewController

#pragma mark - CycleLife
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString * remittance=NSLocalizedString(@"remittance_record", @"汇款记录");
        self.title = remittance;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setUI];
    [self reachability];
    [self p_refreshData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - PrivateMethods


- (void)reachability {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                self.view.ly_emptyView = [XXEmptyView emptyViewWithImageStr:@"universalNetErrorIcon" titleStr:NET_ERROR detailStr:nil];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
            break; } }];
    [mgr startMonitoring];
    
}
- (void)p_setUI {
    
    [self.view addSubview:self.myTableview];
    [self.myTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0,0,0,0));
    }];
    [self.myTableview registerClass:PSRemittanceRecordCell.class forCellReuseIdentifier:@"PSRemittanceRecordCell"];
    @weakify(self)
    self.myTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self p_refreshData];
    }];
    
}
- (void)p_refreshData {
    PSRemittanceRecodeViewModel *RemittanceRecodeViewModel  =(PSRemittanceRecodeViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance]show];
    @weakify(self)
    [RemittanceRecodeViewModel refreshPinmoneyCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self p_reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self p_reloadContents];
    }];
}

- (void)p_loadMore {
    PSRemittanceRecodeViewModel *RemittanceRecodeViewModel  =(PSRemittanceRecodeViewModel *)self.viewModel;
    @weakify(self)
    [RemittanceRecodeViewModel loadMorePinmoneyCompleted:^(PSResponse *response) {
        @strongify(self)
        [self p_reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self p_reloadContents];
    }];
}

- (void)p_reloadContents {
    PSRemittanceRecodeViewModel *RemittanceRecodeViewModel  =(PSRemittanceRecodeViewModel *)self.viewModel;
    if (RemittanceRecodeViewModel.hasNextPage) {
        @weakify(self)
        self.myTableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self p_loadMore];
        }];
    }else{
        self.myTableview.mj_footer = nil;
    }
    [self.myTableview.mj_header endRefreshing];
    [self.myTableview.mj_footer endRefreshing];
    [self.myTableview reloadData];
}


#pragma mark - TouchEvent

#pragma mark - Delegate
//MARK:UITableViewDelegate&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSRemittanceRecodeViewModel *RemittanceRecodeViewModel  =(PSRemittanceRecodeViewModel *)self.viewModel;
    return RemittanceRecodeViewModel.Recodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSRemittanceRecordCell *recordCell = [[PSRemittanceRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PSRemittanceRecordCell"];
    PSRemittanceRecodeViewModel *RemittanceRecodeViewModel  =(PSRemittanceRecodeViewModel *)self.viewModel;
    RemittanceRecode *model = RemittanceRecodeViewModel.Recodes[indexPath.row];
    recordCell.model = model;
    return recordCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - Setting&&Getting
- (UITableView *)myTableview {
    if (!_myTableview) {
        _myTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _myTableview.tableFooterView = [UIView new];
        _myTableview.backgroundColor = [UIColor clearColor];
//        _myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableview.dataSource = self;
        _myTableview.delegate = self;
    }
    return _myTableview;
}




@end
