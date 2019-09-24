//
//  PSImageDisplayViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSImageDisplayViewController.h"

@interface PSImageDisplayViewController ()


@end

@implementation PSImageDisplayViewController

- (void)renderContents {
    NSArray *namesGroup = nil;
    if (self.namesGroup) {
        namesGroup = self.namesGroup();
    }
    NSArray *urlsGroup = nil;
    if (self.urlsGroup) {
        urlsGroup = self.urlsGroup();
    }
    if (namesGroup.count > 0) {
        _displayScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero imageNamesGroup:namesGroup];
    }else if (urlsGroup.count > 0) {
        _displayScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero imageURLStringsGroup:urlsGroup];
    }
    if (_displayScrollView) {
        [self.view addSubview:_displayScrollView];
        [_displayScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
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
