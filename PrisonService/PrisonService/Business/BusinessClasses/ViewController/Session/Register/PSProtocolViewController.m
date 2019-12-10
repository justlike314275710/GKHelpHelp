//
//  PSProtocolViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/11.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSProtocolViewController.h"
#import "PSBusinessConstants.h"

@interface PSProtocolViewController ()

@end

@implementation PSProtocolViewController
- (id)init {
    self = [super initWithURL:[NSURL URLWithString:ProtocolUrl]];
    if (self) {
        
    }
    return self;
}

- (UIImage *)leftItemImage {
    return [UIImage imageNamed:@"universalBackIcon"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

//  UIView*backview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
//  [self.view addSubview:backview];
//  backview.backgroundColor=[UIColor redColor];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    int height = kTabBarHeight==83?23:10;
    backButton.frame = CGRectMake(10,height, 44, 44);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton be_setEnlargeEdgeWithTop:10 right:5 bottom:5 left:5];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIImage *lImage = [UIImage imageNamed:@"universalBackIcon"];
    [backButton setImage:lImage forState:UIControlStateNormal];
    [self.view addSubview:backButton];

    
}

-(void)backAction{
   
    [self dismissViewControllerAnimated:YES completion:nil];
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
