//
//  PrisonOpenViewController.m
//  PrisonService
//
//  Created by kky on 2019/2/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PrisonOpenViewController.h"
#import "PSPrisonOpenCell.h"
#import "PSPublicViewController.h"

@interface PrisonOpenViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *datalist;
@property(nonatomic,strong) UIImageView *contentImg;

@end

@implementation PrisonOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
    self.title = prison_opening;
    
    [self setupUI];
    [self setupData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self shakeToShow:self.contentImg];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)setupUI{
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self.tableView registerClass:[PSPrisonOpenCell class] forCellReuseIdentifier:@"PSPrisonOpenCell"];
    [self.view addSubview:self.tableView];
}
-(void)setupData{
    NSDictionary *indexData1 = @{@"imageicon":@"减刑假释icon",@"title":@"减刑假释",};
    NSDictionary *indexData2 = @{@"imageicon":@"暂予监外执行icon",@"title":@"暂予监外执行",};
    NSDictionary *indexData3 = @{@"imageicon":@"社会帮教icon",@"title":@"社会帮教",};
    _datalist = @[indexData1,indexData2,indexData3];
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.55467)];
    UIImageView *headImag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,view.height)];
    headImag.image = [UIImage imageNamed:@"狱务公开头图1"];
    self.contentImg.frame = CGRectMake((view.width-217)/2,(view.height-34)/2,217,34);
    [self shakeToShow:self.contentImg];
    self.contentImg.image = [UIImage imageNamed:@"为了公平正义"];
    [view addSubview:headImag];
    [view addSubview:self.contentImg];
    return view;
}

-(UIImageView *)contentImg{
    if (!_contentImg) {
        _contentImg = [UIImageView new];
    }
    return _contentImg;
}

- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 4;// 动画时间
    animation.repeatCount = 1000;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SCREEN_WIDTH * 0.55467+10;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSPrisonOpenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSPrisonOpenCell"];
    NSDictionary *data = _datalist[indexPath.row];
    cell.data = data;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSWorkViewModel *viewModel = [PSWorkViewModel new];
    PSPublicViewController *publicViewController = [[PSPublicViewController alloc] initWithViewModel:viewModel];
    publicViewController.jailId = self.jailId;
    publicViewController.jailName = self.jailName;
    switch (indexPath.row) {
        case 0:
        {
            viewModel.newsType = PSNesJxJs;
        }
            break;
        case 1:
        {
            viewModel.newsType = PSNesZyjwzx;
        }
            break;
        case 2:
        {
            viewModel.newsType = PSNesShbj;
        }
            break;
      
        default:
            break;
    }
    [self.navigationController pushViewController:publicViewController animated:YES];
}

#pragma mark - Setting&&Getting
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}



@end
