//
//  PSPinmoneyViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/7/25.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPinmoneyViewController.h"
#import "PSPinmoneyViewModel.h"
#import "PSPocketMoney.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSPinmoneyTableViewCell.h"
#import "PSTipsConstants.h"

@interface PSPinmoneyViewController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,UIScrollViewDelegate>
@property (nonatomic , strong) UITableView *pinmoneyTableview;
@property (nonatomic , strong) NSArray *dataArray;
@property (nonatomic , strong) UILabel*moneyNumber ;
@property (nonatomic,assign) NSInteger indexRow;
@property (nonatomic , strong) UILabel *headerLab;
@end

@implementation PSPinmoneyViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*Pocket_money=NSLocalizedString(@"Pocket_money", @"零花钱情况");
        self.title = Pocket_money;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    [self refreshData];
    // Do any additional setup after loading the view.
}
- (void)loadMore {
    PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    @weakify(self)
    [PinmoneyViewModel loadMorePinmoneyCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}

- (void)refreshData {
    PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance]show];
    @weakify(self)
    [PinmoneyViewModel refreshPinmoneyCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
      
        if (PinmoneyViewModel.Pinmoneys.count) {
            PSPocketMoney *PocketMoney= PinmoneyViewModel.Pinmoneys[0];
            NSString*balance=[NSString stringWithFormat:@"%.2f",[PocketMoney.balance floatValue]];
            _moneyNumber.text=balance;
        }
        
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    }];
}

- (void)reloadContents {
    PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    if (PinmoneyViewModel.hasNextPage) {
        @weakify(self)
        self.pinmoneyTableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.pinmoneyTableview.mj_footer = nil;
    }
    [self.pinmoneyTableview.mj_header endRefreshing];
    [self.pinmoneyTableview.mj_footer endRefreshing];
    [self.pinmoneyTableview reloadData];
}
#pragma mark - UITableViewDataSource
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(15, 5, SCREEN_WIDTH-30, 30)];
    headerView.backgroundColor=UIColorFromRGB(249, 248, 254);
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 18, 20)];
    headerImageView.image = [UIImage imageNamed:@"日历"];
    [headerView addSubview:headerImageView];
    _headerLab = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 100, 20)];
    _headerLab.backgroundColor = [UIColor clearColor];
    _headerLab.textColor = AppBaseTextColor1;
    _headerLab.font = FontOfSize(14);
    PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    NSString*year;
    if (PinmoneyViewModel.Pinmoneys.count) {
        PSPocketMoney *PocketMoney= PinmoneyViewModel.Pinmoneys[_indexRow];
         year=[PocketMoney.accountDate substringToIndex:4];
    }
    
    _headerLab.text=year;
    [headerView addSubview:_headerLab];
    return headerView;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    return PinmoneyViewModel.Pinmoneys.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSPinmoneyTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PSPinmoneyTableViewCell"];
     PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
     PSPocketMoney *PocketMoney= PinmoneyViewModel.Pinmoneys[indexPath.row];
  
    NSString*expenditureText=NSLocalizedString(@"expenditure", @"支出");
    NSString* expenditure=[NSString stringWithFormat:expenditureText, PocketMoney.expenditure];
    NSMutableAttributedString *expenditurestring = [[NSMutableAttributedString alloc] initWithString:expenditure];
    [expenditurestring addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(255, 102, 17) range:NSMakeRange(3, expenditure.length-3)];
    cell.expenditureLabel.attributedText=expenditurestring;
    
    NSString*incomeText=NSLocalizedString(@"income", @"收入");
    NSString* income=[NSString stringWithFormat:incomeText,PocketMoney.income];
    NSMutableAttributedString *incomestring = [[NSMutableAttributedString alloc] initWithString:income];
    [incomestring addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(46, 215, 0) range:NSMakeRange(3, income.length-3)];
    cell.incomeLabel.attributedText=incomestring;
    
    NSString*balanceText=NSLocalizedString(@"balance", @"余额:");
    cell.balanceLabel.text=[NSString stringWithFormat:balanceText,PocketMoney.balance];

    self.dataArray=[NSArray array];
    self.dataArray=[PocketMoney.accountDate componentsSeparatedByString:@"-"];
    NSString*pinmoney_month=NSLocalizedString(@"pinmoney_month", @"%@月");
    NSString*month= [NSString stringWithFormat:pinmoney_month,self.dataArray[1]];
    NSMutableAttributedString *monthString = [[NSMutableAttributedString alloc] initWithString:month];
    [monthString addAttribute:NSFontAttributeName value:FontOfSize(16) range:NSMakeRange(2, month.length-2)];
    cell.dateLabel.attributedText=monthString;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.pinmoneyTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSIndexPath * indexPath = [self.pinmoneyTableview indexPathForRowAtPoint:scrollView.contentOffset];
    self.indexRow=indexPath.row;

    
    PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    if (PinmoneyViewModel.Pinmoneys.count<=3) {
        PSPocketMoney *PocketMoney= PinmoneyViewModel.Pinmoneys[_indexRow];
        _headerLab.text=[PocketMoney.accountDate substringToIndex:4];
    }
    else{
    PSPocketMoney *PocketMoney= PinmoneyViewModel.Pinmoneys[_indexRow+1];
    _headerLab.text=[PocketMoney.accountDate substringToIndex:4];
    }
}


#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
   PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    UIImage *emptyImage = PinmoneyViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return PinmoneyViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
   PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    NSString *tips = PinmoneyViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return PinmoneyViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
    
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
     PSPinmoneyViewModel *PinmoneyViewModel  =(PSPinmoneyViewModel *)self.viewModel;
    return PinmoneyViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:@"点击加载" attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)renderContents {
    CGFloat horSpace =15;
    CGFloat topSpace =10;
    UIImage *bgImage = [UIImage imageNamed:@"当前余额背景"];
    UIImageView*MoneyBgView=[UIImageView new];
    MoneyBgView.image=bgImage;
    [self.view addSubview:MoneyBgView];
    [MoneyBgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(topSpace);
    make.left.mas_equalTo(horSpace);
    make.right.mas_equalTo(-horSpace);
    make.height.mas_equalTo(MoneyBgView.mas_width).multipliedBy(bgImage.size.height/bgImage.size.width);
    }];
    
    UILabel*moneyTitle=[UILabel new];
    [self.view addSubview:moneyTitle];
    moneyTitle.font=FontOfSize(14);
    moneyTitle.textColor=AppBaseTextColor1;
    [moneyTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(MoneyBgView.mas_top).mas_offset(36);
        make.centerX.mas_equalTo(MoneyBgView.mas_centerX);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(14);
    }];
    NSString*Current_balance=NSLocalizedString(@"Current_balance", @"当前余额(元)");
    moneyTitle.text=Current_balance;
    
    
    _moneyNumber=[UILabel new];
    [self.view addSubview:_moneyNumber];
    _moneyNumber.font=FontOfSize(30);
    _moneyNumber.textColor=[UIColor whiteColor];
    _moneyNumber.textAlignment=NSTextAlignmentCenter;
    [_moneyNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(moneyTitle.mas_bottom).mas_offset(horSpace);
        make.centerX.mas_equalTo(MoneyBgView.mas_centerX);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(23);
    }];

    _moneyNumber.text=@"0.00";
    
    self.pinmoneyTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.pinmoneyTableview.dataSource = self;
    self.pinmoneyTableview.delegate = self;
    self.pinmoneyTableview.emptyDataSetDelegate=self;
    self.pinmoneyTableview.emptyDataSetSource=self;
    self.pinmoneyTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pinmoneyTableview.backgroundColor=[UIColor clearColor];
    //  self.pinmoneyTableview.separatorInset = UIEdgeInsetsMake(0, horSpace, 0, horSpace);
    
    @weakify(self)
    self.pinmoneyTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.pinmoneyTableview registerClass:[PSPinmoneyTableViewCell class] forCellReuseIdentifier:@"PSPinmoneyTableViewCell"];
    self.pinmoneyTableview.tableFooterView = [UIView new];
    [self.view addSubview:self.pinmoneyTableview];
    [self.pinmoneyTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(MoneyBgView.mas_bottom).mas_offset(topSpace);
        
    }];
    
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
