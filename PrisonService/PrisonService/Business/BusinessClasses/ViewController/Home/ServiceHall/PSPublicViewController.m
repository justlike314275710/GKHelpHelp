//
//  PSPublicViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPublicViewController.h"

@interface PSPublicViewController ()

@end

@implementation PSPublicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
    self.title =prison_opening;
//    self.titleLabel.text=prison_opening;
    PSWorkViewModel *viewModel = (PSWorkViewModel *)self.viewModel;
    if (viewModel.newsType==PSNesJxJs) {
        prison_opening = @"减刑假释";
    } else if (viewModel.newsType==PSNesZyjwzx) {
        prison_opening = @"暂予监外执行";
    }  else if (viewModel.newsType==PSNesShbj) {
        prison_opening = @"社会帮教";
    }
       self.title =prison_opening;
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
