//
//  PSSelectDisplayViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/8.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSSelectDisplayViewController.h"

@interface PSSelectDisplayViewController ()

@property (nonatomic, strong) UITableView *displayTableView;

@end

@implementation PSSelectDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.displayTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.displayTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SelectDisplayCell"];
    self.displayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.displayTableView.dataSource = self;
    self.displayTableView.delegate = self;
    [self.view addSubview:self.displayTableView];
    [self.displayTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (UITableViewCell *)displayCell {
    UITableViewCell *cell = [self.displayTableView dequeueReusableCellWithIdentifier:@"SelectDisplayCell"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.font = AppBaseTextFont1;
    return cell;
}

#pragma mark -delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
    if (self.callback) {
        self.callback(indexPath.row);
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
