//
//  PSPrisonerManageViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonerManageViewController.h"
#import "PSBindPrisonerViewController.h"
#import "PSBusinessConstants.h"
#import <AFNetworking/AFNetworking.h>
#import "PSUserSession.h"
#import "PSCache.h"
#import "PSSessionManager.h"
@interface PSPrisonerManageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *manageTableView;

@end

@implementation PSPrisonerManageViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*prison_manager=NSLocalizedString(@"prison_manager", nil);
        self.title = prison_manager;
    }
    return self;
}

- (void)renderContents {
    self.manageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.manageTableView.backgroundColor = [UIColor clearColor];
    self.manageTableView.dataSource = self;
    self.manageTableView.delegate = self;
    [self.manageTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
    headerView.backgroundColor = [UIColor clearColor];
    self.manageTableView.tableHeaderView = headerView;
    self.manageTableView.tableFooterView = [UIView new];
    self.manageTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.view addSubview:self.manageTableView];
    @weakify(self);
    self.manageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshData];
    }];
    [self.manageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}
- (void)refreshData {
    //app 登陆流程
    [[PSLoadingView sharedInstance] show];
    @weakify(self);
    [[PSSessionManager sharedInstance] synchronizePrisonerDetailsCompletion:^() {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
            [self.manageTableView .mj_header endRefreshing];
            [self.manageTableView .mj_footer endRefreshing];
            [self.manageTableView reloadData];
        });
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
    [self refreshData];
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}


#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    return homeViewModel.passedPrisonerDetails.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.font = AppBaseTextFont1;
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    if (indexPath.row == homeViewModel.passedPrisonerDetails.count) {
        cell.imageView.image = [UIImage imageNamed:@"homeManageAdd"];
        cell.textLabel.textColor = AppBaseTextColor3;
        NSString*add_inmates=NSLocalizedString(@"add_inmates", @"添加绑定服刑人员");
        cell.textLabel.text = add_inmates;
    }else{
//        if (indexPath.row == homeViewModel.selectedPrisonerIndex) {
//            cell.imageView.image = [UIImage imageNamed:@"homeManageSelected"];
//        }else{
//            cell.imageView.image = [UIImage imageNamed:@"homeManageNormal"];
//        }
        cell.textLabel.textColor = AppBaseTextColor1;
        PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails[indexPath.row];
        cell.textLabel.text = prisonerDetail.name;
        if ([prisonerDetail.prisonerId isEqualToString:self.prisonerDetail.prisonerId]) {
            cell.imageView.image = [UIImage imageNamed:@"homeManageSelected"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"homeManageNormal"];
        }
            
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    if (indexPath.row == homeViewModel.passedPrisonerDetails.count) {
        PSBindPrisonerViewController *bindViewController = [[PSBindPrisonerViewController alloc] initWithViewModel:[[PSBindPrisonerViewModel alloc] init]];
        [self.navigationController pushViewController:bindViewController animated:YES];
    }else{
        
        PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails[indexPath.row];
        if (![prisonerDetail.prisonerId isEqualToString:self.prisonerDetail.prisonerId]) {

            homeViewModel.selectedPrisonerIndex = indexPath.row;
            [tableView reloadData];
            if (self.didManaged) {
                self.didManaged();
            }
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];

        }
//        if (indexPath.row != homeViewModel.selectedPrisonerIndex) {
//            homeViewModel.selectedPrisonerIndex = indexPath.row;
//
//            [tableView reloadData];
//            if (self.didManaged) {
//                self.didManaged();
//            }
//            [self.navigationController popViewControllerAnimated:YES];
//            [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
//        }
    }
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
