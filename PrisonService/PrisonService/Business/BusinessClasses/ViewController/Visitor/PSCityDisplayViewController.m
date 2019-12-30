//
//  PSCityDisplayViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/8.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSCityDisplayViewController.h"

@interface PSCityDisplayViewController ()

@end

@implementation PSCityDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark -delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    return visitorViewModel.currentCitys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self displayCell];
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    PSCity *city = visitorViewModel.currentCitys[indexPath.row];
    if (indexPath.row == visitorViewModel.citySelectIndex) {
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = AppBaseTextColor1;
    }
    cell.textLabel.text = city.name;
    return cell;
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
