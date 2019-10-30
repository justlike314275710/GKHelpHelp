//
//  PSReportArticleViewController.m
//  PrisonService
//
//  Created by kky on 2019/10/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSReportArticleViewController.h"
#import "PSArticleReportCell.h"
#import "PSReportScuessViewController.h"
#import "PSReportArticleViewModel.h"
#import <RZColorful/RZColorful.h>

@interface PSReportArticleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UILabel *penNameLab;
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIButton *reportBtn;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *reportReason;
@property(nonatomic,strong)NSMutableArray *seletedReasonAry;



@end

@implementation PSReportArticleViewController

#pragma mark ---------- LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"举报";
    self.view.backgroundColor = UIColorFromRGB(249, 248, 254);
    PSReportArticleViewModel *viewModel = (PSReportArticleViewModel *)self.viewModel;
    [self setupUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark ---------- Private Method
/** 视图初始化 */
- (void)setupUI {
    [self.view addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(IS_iPhone_5?380:436);
    }];
    
    [self setupShadow];
    
    [self.bgView addSubview:self.penNameLab];
    [self.penNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    [self.bgView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.penNameLab.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(32);
    }];
    [self.bgView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.top.mas_equalTo(self.titleLab.mas_bottom);
    }];
    
    [self.view addSubview:self.reportBtn];
    [self.reportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(44);
    }];
    
    
}
-(void)setupShadow{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CALayer *subLayer      =[CALayer layer];
        CGRect fixframe        = self.bgView.frame;
        subLayer.frame         = fixframe;
        subLayer.cornerRadius  = 4;
        subLayer.backgroundColor=[UIColor whiteColor].CGColor;
        subLayer.masksToBounds = NO;
        subLayer.shadowColor   = UIColorFromRGBA(0, 41, 108, 0.18).CGColor;
        subLayer.shadowOffset  = CGSizeMake(0,4);//shadowOffset阴影偏移,x向右偏移3，y向下偏移2，默认(0, -3),这个跟shadowRadius配合使用
        subLayer.shadowOpacity = 12;//阴影透明度，默认0
        subLayer.shadowRadius  = 3;//阴影半径，默认3
        [self.view.layer insertSublayer:subLayer below:self.bgView.layer];
        
    });
}
/** 加载数据 */
- (void)loadData {
    _reportReason = @[@"色情淫秽",@"垃圾营销",@"谣言",@"政治敏感",@"政治敏感",@"侵权（肖像、诽谤等）",@"售假举报",@"其他"];
    [self.tableView reloadData];
    
    PSReportArticleViewModel *viewModel = (PSReportArticleViewModel *)self.viewModel;
    NSString *penName                   = viewModel.detailModel.penName;
    NSString *title                     = viewModel.detailModel.title;
    NSString *penNameStr                = [NSString stringWithFormat:@"@%@",penName];
    NSString *titleStr                  = [NSString stringWithFormat:@"【%@】",title];
    [_penNameLab rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.paragraphStyle.alignment(NSTextAlignmentLeft);
        confer.text(@"举报 ");
        confer.text(penNameStr).textColor(UIColorFromRGB(38,76,144));
        confer.text(@" 的文章");
    }];
    self.titleLab.text = titleStr;
}

#pragma mark ---------- Target Mehtods
-(void)reportAction:(UIButton *)sender {
    PSReportScuessViewController *reportScuessVC = [[PSReportScuessViewController alloc] init];
    PushVC(reportScuessVC);
}
#pragma mark ---------- UITableView Delegate &Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reportReason.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSArticleReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSArticleReportCell"];
    cell.reasonLab.text = _reportReason[indexPath.row];
    if ([self.seletedReasonAry containsObject:indexPath]) {
        cell.seletedBtn.selected = YES;
    } else {
        cell.seletedBtn.selected = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.seletedReasonAry containsObject:indexPath]) {
        [self.seletedReasonAry removeObject:indexPath];
    } else {
        if (self.seletedReasonAry.count>2) {
            [PSTipsView showTips:@"最多选择三个举报原因!"];
        } else {
            [self.seletedReasonAry addObject:indexPath];
        }
    }
    self.reportBtn.selected = self.seletedReasonAry.count>0?YES:NO;
    self.reportBtn.enabled = self.reportBtn.selected;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    NSLog(@"%@",_seletedReasonAry);
}
#pragma mark ---------- Setter & Getter
-(UIView *)bgView{
    if(_bgView==nil){
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 4;
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}
-(UILabel *)penNameLab{
    if(_penNameLab==nil){
        _penNameLab = [[UILabel alloc] init];
        _penNameLab.text = @"举报@张三丰的文章";
        _penNameLab.textAlignment = NSTextAlignmentLeft;
        _penNameLab.textColor = UIColorFromRGB(51, 51, 51);
        _penNameLab.font = FontOfSize(14);
    }
    return _penNameLab;
}

-(UILabel *)titleLab{
    if(_titleLab==nil){
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"【那是在被人们感觉遗弃的地方大马路矮平房黄梅】";
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.textColor = UIColorFromRGB(38, 76, 144);
        _titleLab.backgroundColor = UIColorFromRGB(235, 235, 235);
        _titleLab.layer.cornerRadius = 5;
        _titleLab.font = FontOfSize(12);
    }
    return _titleLab;
}
-(UIButton *)reportBtn{
    if(_reportBtn==nil){
        _reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reportBtn.enabled = NO;
        [_reportBtn setBackgroundImage:IMAGE_NAMED(@"Graysubmit") forState:UIControlStateNormal];
        [_reportBtn setBackgroundImage:IMAGE_NAMED(@"提交按钮底框") forState:UIControlStateSelected];
        [_reportBtn setTitle:@"举报" forState:UIControlStateNormal];
        _reportBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_reportBtn addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reportBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.width,KScreenHeight-164) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PSArticleReportCell class] forCellReuseIdentifier:@"PSArticleReportCell"];
    }
    return _tableView;
}
-(NSMutableArray *)seletedReasonAry {
    if (!_seletedReasonAry) {
        _seletedReasonAry = [NSMutableArray array];
    }
    return _seletedReasonAry;
}



@end
