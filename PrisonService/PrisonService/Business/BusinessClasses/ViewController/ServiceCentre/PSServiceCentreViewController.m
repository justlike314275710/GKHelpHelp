//
//  PSServiceCentreViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/17.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSServiceCentreViewController.h"
#import "PSServiceCentreTableViewCell.h"
#import "PSLegalServiceTableViewCell.h"
#import "PSPsychologicalCounselingTableViewCell.h"
#import "PSSessionNoneViewController.h"
#import "PSSessionManager.h"
#import "PSHomeViewModel.h"
#import "PSLocalMeetingViewController.h"
#import "PSAppointmentViewController.h"
#import "PSAppointmentViewModel.h"
#import "PSWorkViewModel.h"
#import "PSComplaintSuggestionViewController.h"
#import "PSLoginViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSMoreServiceViewController.h"
#import "PSMoreServiceViewModel.h"
#import "PSConsultationViewModel.h"
#import "PSConsultationViewController.h"
#import "PSFamilyServiceViewController.h"
#import "PSHomeFunctionView.h"
@interface PSServiceCentreViewController ()<PSServiceCentreTableViewCellDelegate>
@property (nonatomic,strong)UIView *headView;
@property (nonatomic,strong)UIImageView *arcImageView;

@end

@implementation PSServiceCentreViewController


#pragma mark  - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self renderContents];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark  - PrivateMethods
- (void)renderContents{
    
    _serviceCentreTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.serviceCentreTableView.dataSource = self;
    self.serviceCentreTableView.delegate = self;
    self.serviceCentreTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.serviceCentreTableView.showsVerticalScrollIndicator=NO;
    self.serviceCentreTableView.backgroundColor = [UIColor clearColor];

    [self.serviceCentreTableView registerClass:[PSServiceCentreTableViewCell class] forCellReuseIdentifier:@"PSServiceCentreTableViewCell"];
    [self.serviceCentreTableView registerClass:[PSLegalServiceTableViewCell class] forCellReuseIdentifier:@"PSLegalServiceTableViewCell"];
    [self.serviceCentreTableView registerClass:[PSPsychologicalCounselingTableViewCell class] forCellReuseIdentifier:@"PSPsychologicalCounselingTableViewCell"];
    self.serviceCentreTableView.backgroundColor = [UIColor whiteColor];
    self.serviceCentreTableView.tableFooterView = [UIView new];
    
    [self.view addSubview:self.serviceCentreTableView];
    [self.serviceCentreTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-64);
    }];
    //广告图
    self.serviceCentreTableView.tableHeaderView = self.headView;
    
}

//MARK:加载广告页
-(void)loadAdvertisingPage{
    PSWorkViewModel *workViewModel = [PSWorkViewModel new];
    [workViewModel requestAdvsCompleted:^(PSResponse *response) {
        _advView.imageURLStringsGroup = workViewModel.advUrls;
    } failed:^(NSError *error) {
        
    }];
}

#pragma mark  - notification

#pragma mark  - action
- (void)choseTerm:(NSInteger)tag{
    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:
            if (tag==0) {
                [self appointmentPrisoner];
            }
            else if (tag==1){
                [self requestLocalMeeting];
            }
            else if (tag==2){
                [self showPrisonLimits:@"电子商务" limitBlock:^{
                    NSLog(@"Push电子商务");
                }];
            }
            else if (tag==3){
                [self psFamilyService];
            }
            else if (tag==4){
                PSWorkViewModel *viewModel = [PSWorkViewModel new];
                viewModel.newsType = PSNewsPublicShow;
                PSComplaintSuggestionViewController *compaintSuggestionViewController = [[PSComplaintSuggestionViewController alloc] initWithViewModel:viewModel];
                [self.navigationController pushViewController:compaintSuggestionViewController animated:YES];
            }
            break;
            
        default:
            if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]) {
                [[PSSessionManager sharedInstance]doLogout];
            } else {
                self.hidesBottomBarWhenPushed=YES;
                PSLoginViewModel*viewModel=[[PSLoginViewModel alloc]init];
                [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]initWithViewModel:viewModel] animated:YES];
                self.hidesBottomBarWhenPushed=NO;
            }
            break;
    }
}

#pragma mark ——————— 家属服务
-(void)psFamilyService {
    PSFamilyServiceViewController *serviceViewController = [[PSFamilyServiceViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
    [self.navigationController pushViewController:serviceViewController animated:YES];
}

- (void)appointmentPrisoner {
 
    PSAppointmentViewController *appointmentViewController = [[PSAppointmentViewController alloc] initWithViewModel:[PSAppointmentViewModel new]];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}

- (void)requestLocalMeeting {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    @weakify(self)
    [homeViewModel requestLocalMeetingDetailCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code==-100) {
            NSString*coming_soon=
            NSLocalizedString(@"coming_soon", @"该监狱暂未开通此功能");
            [PSTipsView showTips:coming_soon];
        }
        else{
            PSLocalMeetingViewController *meetingViewController = [[PSLocalMeetingViewController alloc] initWithViewModel:[PSLocalMeetingViewModel new]];
            [self.navigationController pushViewController:meetingViewController animated:YES];
        }
    } failed:^(NSError *error) {
        [self showNetError:error];
    }];
}

#pragma mark  - UITableViewDelegate OR otherDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height=0;
    switch (indexPath.row){
        case 0:{ height=220;} break;
        case 1:{ height=100; } break;
        default:{}break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==0){
         PSLegalServiceTableViewCell*cell= [tableView dequeueReusableCellWithIdentifier:@"PSLegalServiceTableViewCell"];
        [cell.moreButton bk_whenTapped:^{
             [self p_insertMoreServiceVC];
        }];
        [cell.FinanceButton bk_whenTapped:^{
            [self showPrisonLimits:@"财产纠纷" limitBlock:^{
                PSConsultationViewModel*viewModel=[[PSConsultationViewModel alloc]init];
                PSConsultationViewController*consultationViewController
                =[[PSConsultationViewController alloc]initWithViewModel:viewModel];
                viewModel.category=@"财产纠纷";
                consultationViewController.title=@"发布抢单";
                [self.navigationController pushViewController:consultationViewController animated:YES];
            }];
        }];
        [cell.MarriageButton bk_whenTapped:^{
            
            [self showPrisonLimits:@"婚姻家庭" limitBlock:^{
                PSConsultationViewModel*viewModel=[[PSConsultationViewModel alloc]init];
                PSConsultationViewController*consultationViewController
                =[[PSConsultationViewController alloc]initWithViewModel:viewModel];
                viewModel.category=@"婚姻家庭";
                consultationViewController.title=@"发布抢单";
                [self.navigationController pushViewController:consultationViewController animated:YES];
                
            }];
        }];
        
        return cell;
    }

    else{
        PSPsychologicalCounselingTableViewCell*cell= [tableView dequeueReusableCellWithIdentifier:@"PSPsychologicalCounselingTableViewCell"];
        [cell.goButton bk_whenTapped:^{
             NSString*coming_soon=
            NSLocalizedString(@"coming_soon", @"敬请期待");
            [PSTipsView showTips:coming_soon];
        }];
        return cell;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}
//MARK:更多
- (void)p_insertMoreServiceVC {
    [self showPrisonLimits:@"更多" limitBlock:^{
        PSMoreServiceViewController *PSMoreServiceVC = [[PSMoreServiceViewController alloc] initWithViewModel:[PSMoreServiceViewModel new]];
        [self.navigationController pushViewController:PSMoreServiceVC animated:YES];
    }];
}

- (BOOL)hiddenNavigationBar{
    return YES;
}

- (BOOL)showAdv {
    return YES;
}

#pragma mark  - setter & getter
- (SDCycleScrollView *)advView {
    if (!_advView) {
        _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,220) imageURLStringsGroup:nil];
        NSString *imageName = [NSObject judegeIsVietnamVersion]?@"v广告图":@"广告图";
        _advView.placeholderImage = [UIImage imageNamed:imageName];
        _advView.bannerImageViewContentMode = UIViewContentModeScaleToFill;
        [self loadAdvertisingPage];
    }
    return _advView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 284)];
        [_headView addSubview:self.advView];
        
        [_headView addSubview:self.arcImageView];
        self.arcImageView.frame = CGRectMake(0,220, KScreenWidth,26);
        self.arcImageView.top = self.advView.bottom-12;

        NSArray *titles = @[@"远程探视",@"实地会见",@"电子商务",@"家属服务",@"投诉建议"];
        NSArray *imageIcons = @[@"远程探视",@"实地会见",@"电子商务",@"家属服务icon",@"投诉建议"];
        PSHomeFunctionView *homeFunctionView = [[PSHomeFunctionView alloc] initWithFrame:CGRectMake(4,160,KScreenWidth-8,120) titles:titles imageIcons:imageIcons];
        @weakify(self);
        homeFunctionView.homeFunctionBlock = ^(NSInteger index) {
            @strongify(self);
            [self choseTerm:index];
        };
        [_headView addSubview:homeFunctionView];
    }
    return _headView;
}

- (UIImageView *)arcImageView {
    if (!_arcImageView) {
        _arcImageView = [UIImageView new];
        _arcImageView.image = IMAGE_NAMED(@"弧形背景");
    }
    return _arcImageView;
}





@end
