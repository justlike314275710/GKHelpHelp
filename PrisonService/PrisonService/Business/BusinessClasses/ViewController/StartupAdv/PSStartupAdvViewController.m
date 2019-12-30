//
//  PSStartupAdvViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/28.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSStartupAdvViewController.h"
#import "PSCountdownManager.h"

@interface PSStartupAdvViewController ()<PSCountdownObserver,PSCountdownObserver>

@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, strong) UIButton *skipButton;

@end

@implementation PSStartupAdvViewController
- (id)init {
    self = [super init];
    if (self) {
        [[PSCountdownManager sharedInstance] addObserver:self];
    }
    return self;
}
    
- (void)dealloc {
    [[PSCountdownManager sharedInstance] removeObserver:self];
}

- (void)advDisplayCompleted {
    if (self.completed) {
        self.completed();
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)updateButtonTitle {
    [self.skipButton setTitle:[NSString stringWithFormat:@"跳过 %ld",(long)self.seconds] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.displayScrollView.autoScrollTimeInterval = 3;
    self.displayScrollView.infiniteLoop = NO;
    self.displayScrollView.mainView.bounces = NO;
    self.displayScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    NSInteger pages = self.displayScrollView.imageURLStringsGroup.count;
    NSTimeInterval timeInterval = self.displayScrollView.autoScrollTimeInterval;
    self.seconds = pages * timeInterval;
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skipButton.titleLabel.font = AppBaseTextFont1;
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.skipButton.layer.cornerRadius = 5.0;
    self.skipButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self updateButtonTitle];
    @weakify(self)
    [self.skipButton bk_whenTapped:^{
        @strongify(self)
        [self advDisplayCompleted];
    }];
    [self.view addSubview:self.skipButton];
    [self.skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - PSCountdownObserver
- (void)countdown {
    _seconds --;
    if (_seconds > 0) {
        [self updateButtonTitle];
    }else{
        [self advDisplayCompleted];
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
