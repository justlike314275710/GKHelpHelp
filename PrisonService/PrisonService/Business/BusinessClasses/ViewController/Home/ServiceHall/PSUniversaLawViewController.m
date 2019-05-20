//
//  PSUniversaLawViewController.m
//  PrisonService
//
//  Created by kky on 2019/4/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSUniversaLawViewController.h"
#import "PSUniversalLawCell.h"
#import "PSLawViewController.h"
@interface PSUniversaLawViewController()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)NSArray *datalist;

@end

@implementation PSUniversaLawViewController
#pragma mark - LifeCycle
-(void)viewDidLoad {
    [super viewDidLoad];
    NSString*universal_law=NSLocalizedString(@"Universal law", @"全民普法");
    self.title = universal_law;
    self.view.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
    [self setupUI];
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSUniversalLawCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSUniversalLawCell"];
    cell.data = self.datalist[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 165;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showPrisonLimits:@"法律服务" limitBlock:^{
            
        }];
    } else {
        PSLawViewController *lawViewController = [[PSLawViewController alloc] init];
        [self.navigationController pushViewController:lawViewController animated:YES];
    }
}

#pragma mark - PrivateMethods
-(void)setupUI {
    [self.view addSubview:self.tableview];
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.view);
    }];
    [self.tableview registerClass:[PSUniversalLawCell class] forCellReuseIdentifier:@"PSUniversalLawCell"];
    
}

-(void)setupData{
    NSDictionary *item1 = @{@"icon":@"LawAdvice",@"titleChina":@"法律服务",
                            @"titleEnglish":@"Legal service"};
    NSDictionary *item2 = @{@"icon":@"LawsRegulations",@"titleChina":@"法律法规",@"titleEnglish":@"Laws and regulations"};
    self.datalist = [NSArray arrayWithObjects:item1,item2, nil];
    [self.tableview reloadData];
}

#pragma mark - Setting&Getting
- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview.tableFooterView = [UIView new];
        _tableview.backgroundColor = [UIColor clearColor];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.dataSource = self;
        _tableview.delegate = self;
    }
    return _tableview;
}
- (NSArray *)datalist {
    if (!_datalist) {
        _datalist = [NSArray array];
    }
    return _datalist;
}

@end
