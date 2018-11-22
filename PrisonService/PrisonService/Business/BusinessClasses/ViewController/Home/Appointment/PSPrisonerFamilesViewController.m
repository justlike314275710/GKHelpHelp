//
//  PSPrisonerFamilesViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/9/14.
//  Copyright © 2018年 calvin. All rights reserved.
//
#define defaultTag 1990
#import "PSPrisonerFamilesViewController.h"
#import "PSAddFamiliesViewController.h"
#import "PSPrisonerFamliesViewModel.h"
#import "PSRegisterViewModel.h"
#import "VIRegisterViewModel.h"
#import "PSPrisonerFamily.h"
#import "PSFamilyTableViewCell.h"
#import "PSAlertView.h"
#import "PSAppointmentViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "VIAddFamilesViewController.h"

@interface PSPrisonerFamilesViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *prisonerFamilesTableView;
@property (nonatomic , strong) NSMutableArray *selectArray;
@property (nonatomic, assign) NSInteger btnTag;
@end

@implementation PSPrisonerFamilesViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*chose_family=NSLocalizedString(@"chose_family", @"寻找会见家属");
        self.title = chose_family;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnTag = defaultTag;
    [self renderContents];
    [self refreshData];
     _selectArray=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //注册检测网络通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nonetWork) name:NotificationNoNetwork object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNoNetwork object:nil];
}

#pragma mark - Notification
-(void)nonetWork {
    [self showInternetError];
}

- (void)renderContents {
    self.prisonerFamilesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.prisonerFamilesTableView.backgroundColor = [UIColor clearColor];
    self.prisonerFamilesTableView.dataSource = self;
    self.prisonerFamilesTableView.delegate = self;
//    [self.prisonerFamilesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    [self.prisonerFamilesTableView registerClass:[PSFamilyTableViewCell class] forCellReuseIdentifier:@"PSFamilyTableViewCell"];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    headerView.backgroundColor = [UIColor clearColor];
    UIButton*addFamilesButton=[[UIButton alloc]init];
     NSString*add_family=NSLocalizedString(@"add_family", @"添加家属");
    [addFamilesButton setTitle:add_family forState:UIControlStateNormal];
    [addFamilesButton setImage:[UIImage imageNamed:@"familyAdd"] forState:UIControlStateNormal];
    addFamilesButton.titleLabel.numberOfLines=0;
    addFamilesButton.titleLabel.font=AppBaseTextFont3;
    [addFamilesButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    [headerView addSubview:addFamilesButton];
    [addFamilesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    [addFamilesButton addTarget:self action:@selector(addFamilesAction) forControlEvents:UIControlEventTouchUpInside];
    UIView*lineView=[UIView new];
    lineView.backgroundColor=UIColorFromRGB(249, 248, 254);
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(10);
    }];
    
    self.prisonerFamilesTableView.tableHeaderView = headerView;
    self.prisonerFamilesTableView.tableFooterView = [UIView new];
    self.prisonerFamilesTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.view addSubview:self.prisonerFamilesTableView];
    [self.prisonerFamilesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT-150);
    }];
    
    CGSize buttonSize=CGSizeMake(SCREEN_WIDTH-30, 40);
    UIButton *applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [applyButton addTarget:self action:@selector(noticeTips) forControlEvents:UIControlEventTouchUpInside];
    applyButton.titleLabel.font = AppBaseTextFont1;
    UIImage *bgImage = [UIImage imageNamed:@"universalButtonBg"];
    [applyButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*chose_ok=NSLocalizedString(@"chose_ok", @"选好了");
    [applyButton setTitle:chose_ok forState:UIControlStateNormal];
    [self.view addSubview:applyButton];
    [applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(buttonSize);
    }];
    [applyButton.layer setMasksToBounds:YES];
    [applyButton.layer setCornerRadius:5.0f];
    
    
}

- (void)addFamilesAction {
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString*language = langArr.firstObject;
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-VN"]||[language isEqualToString:@"vi-CN"]) {
        [self.navigationController pushViewController:[[VIAddFamilesViewController alloc] initWithViewModel:[[VIRegisterViewModel alloc]init]] animated:YES];
    }
    else{
    [self.navigationController pushViewController:[[PSAddFamiliesViewController alloc] initWithViewModel:[[PSRegisterViewModel alloc]init]] animated:YES];
    }
}

-(void)noticeTips{

   PSPrisonerFamliesViewModel *prisonerFamliesViewModel = (PSPrisonerFamliesViewModel *)self.viewModel;
    if ([prisonerFamliesViewModel.face_recognition isEqualToString:@"0"]) {
        //[self appointmentAction];
        [self choseFamilyAction];
    }else{
        NSString*notice_title=NSLocalizedString(@"notice_title", @"提请注意");
        NSString*notice_agreed=NSLocalizedString(@"notice_agreed", @"同意");
        NSString*notice_disagreed=NSLocalizedString(@"notice_disagreed", @"不同意");
        NSString*add_notice_content=NSLocalizedString(@"add_notice_content", nil);
        [PSAlertView showWithTitle:notice_title message:add_notice_content messageAlignment:NSTextAlignmentCenter image:nil handler:^(PSAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [self choseFamilyAction];
            }
        } buttonTitles:notice_disagreed,notice_agreed, nil];
    }

}

-(void)choseFamilyAction{
    NSString*add_max=NSLocalizedString(@"add_max", @"最多可选择三位亲属");
    if (_selectArray.count>2) {
        [PSTipsView showTips: add_max];
    }
//    else if (_selectArray.count==1){
//        __weak typeof(self) weakself = self;
//        if (weakself.returnValueBlock) {
//            weakself.returnValueBlock(_selectArray);
//        }
//        [self.navigationController popViewControllerAnimated:YES];
//        
//        if (self.completion) {
//            self.completion(YES);
//        }
//    }
    else{
        PSPrisonerFamliesViewModel *prisonerFamliesViewModel = (PSPrisonerFamliesViewModel *)self.viewModel;
        PSPrisonerFamily*familesModel=prisonerFamliesViewModel.prisonerFamlies[0];
        [_selectArray addObject:familesModel];
            __weak typeof(self) weakself = self;
            if (weakself.returnValueBlock) {
                weakself.returnValueBlock(_selectArray);
            }
            [self.navigationController popViewControllerAnimated:YES];
        
            if (self.completion) {
                self.completion(YES);
            }
       }
}


- (void)refreshData {
    PSPrisonerFamliesViewModel *prisonerFamliesViewModel = (PSPrisonerFamliesViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [prisonerFamliesViewModel requestOfPrisonerFamliesCompleted:^(PSResponse *response) {
        //@strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self.prisonerFamilesTableView reloadData];
        [self setNoticeTips];
        //[self renderContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError];
       
    }];
}

-(void)setNoticeTips{
    PSPrisonerFamliesViewModel *prisonerFamliesViewModel = (PSPrisonerFamliesViewModel *)self.viewModel;
    CGFloat height=(prisonerFamliesViewModel.prisonerFamlies.count+1)*44;
    UILabel*noticeLable=[UILabel new];
    noticeLable.textColor=AppBaseTextColor3;
    noticeLable.font=AppBaseTextFont3;
    NSString*add_family_tips=NSLocalizedString(@"add_family_tips", @"提示:最多可选择三位亲属");
    noticeLable.text=add_family_tips;
    [self.prisonerFamilesTableView addSubview:noticeLable];
    noticeLable.frame=CGRectMake(15, height+15, SCREEN_WIDTH-30, 20);

}


#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSPrisonerFamliesViewModel *prisonerFamliesViewModel = (PSPrisonerFamliesViewModel *)self.viewModel;
    return prisonerFamliesViewModel.prisonerFamlies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSFamilyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSFamilyTableViewCell"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.textLabel.font = AppBaseTextFont1;
     PSPrisonerFamliesViewModel *prisonerFamliesViewModel = (PSPrisonerFamliesViewModel *)self.viewModel;
    PSPrisonerFamily*familesModel=prisonerFamliesViewModel.prisonerFamlies[indexPath.row];
        cell.textLabel.textColor = AppBaseTextColor1;
        cell.textLabel.text = familesModel.familyName;
        cell.selectBtn.tag = defaultTag+indexPath.row;
    if (indexPath.row==0) {
        cell.isSelect=YES;
        cell.selectBtn.userInteractionEnabled=NO;
             NSString*me=NSLocalizedString(@"me", @"我");
        cell.textLabel.text = me;
    }
    
    if (cell.isSelect==NO) {
         [cell.selectBtn setImage:[UIImage imageNamed:@"homeManageNormal"] forState:UIControlStateNormal];
    } else {
        [cell.selectBtn setImage:[UIImage imageNamed:@"homeManageSelected"] forState:UIControlStateNormal];
    }

    __weak PSFamilyTableViewCell *weakCell =cell;
    [weakCell setQhxSelectBlock:^(BOOL choice,NSInteger btnTag){
        if (choice) {
            [weakCell.selectBtn setImage:[UIImage imageNamed:@"homeManageSelected"] forState:UIControlStateNormal];
            self.btnTag = btnTag;
             PSPrisonerFamily*familesModel=prisonerFamliesViewModel.prisonerFamlies[btnTag-defaultTag];
                [_selectArray addObject:familesModel];
            [self.prisonerFamilesTableView reloadData];
    
            NSLog(@"***%ld",(long)btnTag);
            NSLog(@"选中%@",_selectArray);
        }
        else{
            //选中一个之后，再次点击，是未选中状态，图片仍然设置为选中的图片，记录下tag，刷新tableView，这个else 也可以注释不用，tag只记录选中的就可以
            [weakCell.selectBtn setImage:[UIImage imageNamed:@"homeManageSelected"] forState:UIControlStateNormal];
            self.btnTag = btnTag;
            PSPrisonerFamily*familesModel=prisonerFamliesViewModel.prisonerFamlies[btnTag-defaultTag];
            [_selectArray removeObject:familesModel];
            [self.prisonerFamilesTableView reloadData];
            NSLog(@"###%ld",(long)btnTag);
            NSLog(@"取消%@",_selectArray);

        }

    }];
 
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
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
