//
//  PSAuthenticationHomePageViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/15.
//  Copyright © 2018年 calvin. All rights reserved.
//


#import "PSPrisonIntroduceViewController.h"
#import "PSPrisonContentViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "PSHomePageViewController.h"
#import "PSMessageViewController.h"
#import "PSVisitorViewController.h"
#import "PSDynamicViewController.h"
#import "PSPublicViewController.h"
#import "PSDefaultJailResponse.h"
#import "PSDefaultJailRequest.h"
#import "PSBusinessConstants.h"
#import "PSLawViewController.h"
#import "PSRegisterViewModel.h"
#import "PSBusinessConstants.h"
#import "PSMessageViewModel.h"
#import "PSVisitorViewModel.h"
#import "PSSessionManager.h"
#import "PSVisitorManager.h"
#import "PSWorkViewModel.h"
#import "PSHomeViewModel.h"
#import "JXButton.h"
#import "PSCache.h"
#import "PSVersonUpdateViewModel.h"
#import "PSEcomLoginViewmodel.h"
#import "NSObject+version.h"
#import "WWWaterWaveView.h"
#import "PSAppointmentViewController.h"
#import "PSLocalMeetingViewController.h"
#import "PSFamilyServiceViewController.h"
#import "PrisonOpenViewController.h"
#import "PSLoginViewModel.h"
#import "PSSessionNoneViewController.h"
#import "PSUniversaLawViewController.h"


@interface PSHomePageViewController ()
@property (nonatomic, strong) PSDefaultJailRequest*jailRequest;
@property (nonatomic, strong) NSString *defaultJailId;
@property (nonatomic, strong) NSString *defaultJailName;
@property (nonatomic, strong) UIButton*addressButton;
@property (nonatomic, strong) UILabel*prisonIntroduceContentLable;
@property (nonatomic, strong) UIButton*messageButton ;
@property (nonatomic, strong) UILabel *dotLable;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, strong) UIScrollView *myScrollview;
//@property (nonatomic, strong) UIImageView *bgAdvBgView;
@property (nonatomic, assign) NSInteger getTokenCount;

@property (nonatomic,strong)UIView *prisonIntroduceView;
@property (nonatomic,strong)UIView *itemView;
@property (nonatomic,strong)JXButton *publicButton;
@property (nonatomic,strong)UIView *homeHallView;
@property (nonatomic,strong)UIButton *lawButton; //workButton
@property (nonatomic,strong)UIButton *workButton;
@property (nonatomic,strong)WWWaterWaveView *waterWaveView;
@property (nonatomic,strong)UIButton*prisonIntroduceButton;




@end

@implementation PSHomePageViewController

#pragma mark  - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.selectedIndex = 0;
    _getTokenCount = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //更新
    PSVersonUpdateViewModel *UpdateViewModel = [PSVersonUpdateViewModel new];
    [UpdateViewModel VersonUpdate];
    //没有网络下不能为空白
    [self.view addSubview:self.myScrollview];
    [self renderContents:NO];
    [self refreshDataFromLoginStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDot) name:AppDotChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:JailChange object:nil];
    //重新获取token
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOfRefreshToken) name:RefreshToken object:nil];

}

//重新获取TOKEN
-(void)requestOfRefreshToken{
    NSLog(@"token 失效");
    _getTokenCount ++;
    if (_getTokenCount<2) {
        PSEcomLoginViewmodel*ecomViewmodel=[[PSEcomLoginViewmodel alloc]init];
        [ecomViewmodel postRefreshEcomLogin:^(PSResponse *response) {
            //重新登陆
            [self refreshDataFromLoginStatus];
        } failed:^(NSError *error) {
            [self showNetError:error];
        }];
    } else {
        [self showTokenError];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDotChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JailChange object:nil];
    
}


#pragma mark  - notification
-(void)showDot{
    self.dotLable.hidden = NO;
}


-(void)refreshData{
     PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    NSInteger index = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = nil;
    
    if (index >= 0 && index < homeViewModel.passedPrisonerDetails.count) {
        prisonerDetail = homeViewModel.passedPrisonerDetails[index];
    }
    self.defaultJailName=prisonerDetail.jailName;
    self.defaultJailId=prisonerDetail.jailId;
    [self requestjailsDetailsWithJailId:prisonerDetail.jailId isShow:NO];
}

#pragma mark  - action and request
-(void)refreshDataFromLoginStatus{
    switch ([PSSessionManager sharedInstance].loginStatus) {
        case PSLoginPassed:{
            PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
            [[PSLoadingView sharedInstance] show];
            [LXFileManager removeUserDataForkey:@"isVistor"];
            @weakify(self)
            [homeViewModel requestHomeDataCompleted:^(id data) {
                @strongify(self)
                //回到主线程刷新界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[PSLoadingView sharedInstance] dismiss];
                });
                NSInteger index = homeViewModel.selectedPrisonerIndex;
                PSPrisonerDetail *prisonerDetail = nil;
                if (index >= 0 && index < homeViewModel.passedPrisonerDetails.count) {
                    prisonerDetail = homeViewModel.passedPrisonerDetails[index];
                }
                self.defaultJailName=prisonerDetail.jailName;
                self.defaultJailId=prisonerDetail.jailId;
                [self requestjailsDetailsWithJailId:prisonerDetail.jailId isShow:NO];
                
            }];
        }
            break;

        default:
           [self synchronizeDefaultJailConfigurations];
           
            break;
    }
  
   
}

- (void)synchronizeDefaultJailConfigurations {
    self.jailRequest=[PSDefaultJailRequest new];
    [self.jailRequest send:^(PSRequest *request, PSResponse *response) {
        if (response.code == 200) {
            PSDefaultJailResponse *jailResponse = (PSDefaultJailResponse *)response;
            self.defaultJailId = jailResponse.jailId;
            self.defaultJailName =[NSString stringWithFormat:@"%@▼", jailResponse.jailName];
            [self requestjailsDetailsWithJailId:self.defaultJailId isShow:YES];
        }
        else{
            [self showNetError:nil];
            [self renderContents:YES];
        }
    }];
    
    
}

- (void)messageAction{
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    if (homeViewModel.selectedPrisonerIndex >= 0 && homeViewModel.selectedPrisonerIndex < homeViewModel.passedPrisonerDetails.count) {
        PSMessageViewModel *viewModel = [[PSMessageViewModel alloc] init];
        viewModel.prisonerDetail = homeViewModel.passedPrisonerDetails[homeViewModel.selectedPrisonerIndex];
        PSMessageViewController *messageViewController = [[PSMessageViewController alloc] initWithViewModel:viewModel];
        [self.navigationController pushViewController:messageViewController animated:YES];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dot"];
    self.dotLable.hidden=YES;
    
}


- (void)selectJails{
    PSVisitorViewController*vistorViewController=[[PSVisitorViewController alloc]initWithViewModel:[[PSVisitorViewModel alloc] init]];
    @weakify(self);
    [vistorViewController setCallback:^(PSJail *selectedJail) {
        @strongify(self);
        [_addressButton setTitle:[NSString stringWithFormat:@"%@▼",selectedJail.title] forState:0];
        self.defaultJailName= [NSString stringWithFormat:@"%@▼",selectedJail.title];
        self.defaultJailId=selectedJail.id;
        [self requestjailsDetailsWithJailId:selectedJail.id isShow:YES];
        
    }];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:vistorViewController animated:YES];
     self.hidesBottomBarWhenPushed=NO;
}

-(void)requestjailsDetailsWithJailId:(NSString*)jailId isShow:(BOOL)isShow{
    PSVisitorViewModel*vistorViewModel=[[PSVisitorViewModel alloc]init];
    vistorViewModel.jailId=jailId;
    [[PSLoadingView sharedInstance]show];
    @weakify(self)
    [vistorViewModel requestJailsProfileWithCompletion:^(PSResponse *response) {
        @strongify(self)
        if (response.code==200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self renderContents:isShow];
                NSString*profileSting= vistorViewModel.profile;
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithData:[profileSting dataUsingEncoding:NSUnicodeStringEncoding]options:@{
                                                                                                                                NSDocumentTypeDocumentAttribute:
                                                                                                                                                                           NSHTMLTextDocumentType
                                                                                                                                                                       }documentAttributes:nil error:nil];
                if ([[attrStr string]containsString:@"您的浏览器不支持Video标签。"]) {
                    self.prisonIntroduceContentLable.text = [[attrStr string] substringFromIndex:16];
                } else {
                    self.prisonIntroduceContentLable.text = [attrStr string];
                }
                [[PSLoadingView sharedInstance]dismiss];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [PSTipsView showTips:response.msg];
                [self renderContents:isShow];
                [[PSLoadingView sharedInstance]dismiss];
            });
        }
       

       
    } failed:^(NSError *error) {
        //TOKEN 失效
        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:RefreshToken object:nil];
        } else {
            [self showNetError:error];
        }
    }];
}

-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }

    return html;
}

- (BOOL)showAdv {
    return YES;
}

- (BOOL)hiddenNavigationBar{
    return YES;
}
#pragma mark  - UI
-(void)renderContents:(BOOL)isShow{
    
    self.myScrollview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.myScrollview.contentSize = CGSizeMake(SCREEN_WIDTH,660);
    });
    CGFloat sidePadding=19;
    CGFloat spacing=10;
    //广告图
    [self.myScrollview addSubview:self.advView];
    //背景水波
    [self.myScrollview addSubview:self.waterWaveView];
    self.waterWaveView.frame = CGRectMake(0,_advView.bottom-44, SCREEN_WIDTH, 44);
    
    [self.myScrollview addSubview:self.addressButton];
    [self.addressButton setTitle:self.defaultJailName forState:0];
    self.addressButton.userInteractionEnabled=isShow;
    [self.myScrollview addSubview:self.messageButton];
    self.messageButton.hidden=isShow;
    //消息红点
    [self.myScrollview addSubview:self.dotLable];
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString *dot = self.session.families.isNoticed;
    if ([dot isEqualToString:@"0"]) {
        self.dotLable.hidden = NO;
    }
    
    [self.myScrollview addSubview:self.itemView];
    self.prisonIntroduceView.backgroundColor=[UIColor whiteColor];
    [self.myScrollview addSubview:_prisonIntroduceView];
    
    [_prisonIntroduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_itemView.mas_bottom).offset(spacing);
        make.left.mas_equalTo(sidePadding);
        make.height.mas_equalTo(107);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
    }];
    _prisonIntroduceView.layer.cornerRadius=4;
    _prisonIntroduceView.layer.masksToBounds=YES;
    UILabel*prisonTitleLable=[UILabel new];
    NSString*prison_introduction=
    NSLocalizedString(@"prison_introduction", @"监狱简介");
    prisonTitleLable.text=prison_introduction;
    prisonTitleLable.font=AppBaseTextFont3;
    prisonTitleLable.textColor=[UIColor blackColor];
    prisonTitleLable.textAlignment=NSTextAlignmentLeft;
    [_prisonIntroduceView addSubview:prisonTitleLable];
    [prisonTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_prisonIntroduceView.mas_top).offset(spacing);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(100);
    }];
    //详情背景,增大点击事件范围
    UIButton *prisonIntroduceButtonBg = [UIButton new];
    prisonIntroduceButtonBg.backgroundColor = [UIColor clearColor];
    [_prisonIntroduceView addSubview:prisonIntroduceButtonBg];
    [prisonIntroduceButtonBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_prisonIntroduceView.mas_top).offset(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(60);
    }];
    
 
    NSString*details=NSLocalizedString(@"details", @"详情");
    [self.prisonIntroduceButton setTitle:details forState:0];
    _prisonIntroduceButton.titleLabel.font=FontOfSize(14);
    [_prisonIntroduceButton setTitleColor:AppBaseTextColor3 forState:0];
    _prisonIntroduceButton.enabled = NO;
    _prisonIntroduceButton.userInteractionEnabled = NO;
    _prisonIntroduceButton.contentHorizontalAlignment
    =UIControlContentHorizontalAlignmentRight;
    [_prisonIntroduceView addSubview:_prisonIntroduceButton];
    [_prisonIntroduceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_prisonIntroduceView.mas_top).offset(spacing);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(50);
    }];
    //写成这样方便埋点
    [prisonIntroduceButtonBg addTarget:self action:@selector(p_InsertPrisonIntroduce:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.prisonIntroduceContentLable.font=FontOfSize(12);
    _prisonIntroduceContentLable.textColor=AppBaseTextColor1;
    _prisonIntroduceContentLable.textAlignment=NSTextAlignmentLeft;
    [_prisonIntroduceView addSubview:_prisonIntroduceContentLable];
    [_prisonIntroduceContentLable mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.mas_equalTo(_prisonIntroduceButton.mas_bottom).offset(spacing);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(63);
        make.left.mas_equalTo(15);
    }];
    _prisonIntroduceContentLable.numberOfLines=0;
    
    
    self.homeHallView.backgroundColor=[UIColor whiteColor];
    [self.myScrollview addSubview:self.homeHallView];
    [_homeHallView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_prisonIntroduceView.mas_bottom).offset(spacing);
        make.left.mas_equalTo(sidePadding);
        make.height.mas_equalTo(200);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
    }];
    _homeHallView.layer.cornerRadius=2;
    _homeHallView.layer.masksToBounds=YES;
    
    self.publicButton.frame =CGRectMake(0, 0, SCREEN_WIDTH/2-sidePadding, 200);
    [_homeHallView addSubview:_publicButton];
    NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
    _publicButton.titleLabel.font = AppBaseTextFont1;
    [_publicButton setTitle:prison_opening forState:0];
    [_publicButton setTitleColor:[UIColor blackColor] forState:0];
    [_publicButton setImage:[UIImage imageNamed:@"狱务公开"] forState:0];
    [_publicButton addTarget:self action:@selector(p_InsertPrisonPublic:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *dashLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+1, 0, 1, 200)];
    dashLine.backgroundColor=AppBaseLineColor;
    [_homeHallView addSubview:dashLine];
    
   
    self.lawButton.frame = CGRectMake(SCREEN_WIDTH/2-sidePadding+2, 0, SCREEN_WIDTH/2-sidePadding, 100);
    
    [_homeHallView addSubview:_lawButton];
     NSString*laws_regulations=NSLocalizedString(@"laws_regulations", @"全民普法");
    [_lawButton setTitle:laws_regulations forState:0];
    [_lawButton setTitleColor:[UIColor blackColor] forState:0];
    _lawButton .titleLabel.font=  [NSObject judegeIsVietnamVersion]?FontOfSize(10):FontOfSize(15);
    _lawButton.titleLabel.numberOfLines = 0;
    [_lawButton setImage:[UIImage imageNamed:@"法律法规"] forState:0];
    [_lawButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];//间距
    [_lawButton addTarget:self action:@selector(p_insertLaw:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *verDashLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+1, 100, SCREEN_WIDTH/2-sidePadding-2, 1)];
    [_homeHallView addSubview:verDashLine];
    verDashLine.backgroundColor=AppBaseLineColor;
    self.workButton.frame = CGRectMake(SCREEN_WIDTH/2-sidePadding+2, 100, SCREEN_WIDTH/2-sidePadding, 100);
    [_homeHallView addSubview:_workButton];
    NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
    _workButton.titleLabel.numberOfLines = 0;
    [_workButton setTitle:work_dynamic forState:0];
    [_workButton setTitleColor:[UIColor blackColor] forState:0];
    _workButton .titleLabel.font=  [NSObject judegeIsVietnamVersion]?FontOfSize(10):FontOfSize(15);
    [_workButton setImage:[UIImage imageNamed:@"工作动态"] forState:0];
    [_workButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    [_workButton addTarget:self action:@selector(p_inserDynamic:) forControlEvents:UIControlEventTouchUpInside];

    
    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]){
        _messageButton.hidden=YES;
    }
    
}

#pragma mark - TouchEvent
//监狱简介
-(void)p_InsertPrisonIntroduce:(UIButton *)sender {
    PSPrisonIntroduceViewController *prisonViewController = [[PSPrisonIntroduceViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?t=%@",PrisonDetailUrl,self.defaultJailId,[NSDate getNowTimeTimestamp]]]];
    [self.navigationController pushViewController:prisonViewController animated:YES];
}
//狱务公开
-(void)p_InsertPrisonPublic:(UIButton *)sender {
    PrisonOpenViewController *prisonVC = [[PrisonOpenViewController alloc] init];
    prisonVC.jailId=self.defaultJailId;
    prisonVC.jailName=self.defaultJailName;
    [self.navigationController pushViewController:prisonVC animated:YES];
    /*
    PSWorkViewModel *viewModel = [PSWorkViewModel new];
    viewModel.newsType = PSNewsPrisonPublic;
    PSPublicViewController *publicViewController = [[PSPublicViewController alloc] initWithViewModel:viewModel];
    publicViewController.jailId=self.defaultJailId;
    publicViewController.jailName=self.defaultJailName;
//    if (self.defaultJailId==nil||self.defaultJailName==nil) {
//        [PSTipsView showTips:@"当前网络不支持"];
//    } else {
        publicViewController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:publicViewController animated:YES];
        publicViewController.hidesBottomBarWhenPushed=NO;
//    }
     */
}
//法律法规
-(void)p_insertLaw:(UIButton *)senser {
    PSUniversaLawViewController *PSUniversaLaw = [[PSUniversaLawViewController alloc] init];
    [self.navigationController pushViewController:PSUniversaLaw animated:YES];
}
//工作动态
-(void)p_inserDynamic:(UIButton *)sender {
    
    PSWorkViewModel *viewModel = [PSWorkViewModel new];
    viewModel.newsType = PSNewsWorkDynamic;
    PSDynamicViewController *dynamicViewController = [[PSDynamicViewController alloc] initWithViewModel:viewModel];
    dynamicViewController.jailId=self.defaultJailId;
    dynamicViewController.jailName=self.defaultJailName;
    [self.navigationController pushViewController:dynamicViewController animated:YES];
   
}

#pragma mark ——————— 远程探视
- (void)appointmentPrisoner {
    
    PSAppointmentViewController *appointmentViewController = [[PSAppointmentViewController alloc] initWithViewModel:[PSAppointmentViewModel new]];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}
#pragma mark ——————— 实地会见

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
#pragma mark ——————— 电子商务
-(void)e_commerce {
    NSString*coming_soon=
    NSLocalizedString(@"coming_soon", @"该监狱暂未开通此功能");
    [PSTipsView showTips:coming_soon];
}

#pragma mark ——————— 家属服务
-(void)psFamilyService {
    PSFamilyServiceViewController *serviceViewController = [[PSFamilyServiceViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
    [self.navigationController pushViewController:serviceViewController animated:YES];
}
#pragma mark - setting&getting
- (UIScrollView *)myScrollview {
    if (!_myScrollview) {
        _myScrollview = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _myScrollview.showsVerticalScrollIndicator = NO;
        _myScrollview.showsHorizontalScrollIndicator = NO;
        _myScrollview.scrollEnabled = YES;
    }
    return _myScrollview;
}
//加载广告页
-(void)loadAdvertisingPage{
    PSWorkViewModel *workViewModel = [PSWorkViewModel new];
    [workViewModel requestAdvsCompleted:^(PSResponse *response) {
        _advView.imageURLStringsGroup = workViewModel.advUrls;
    } failed:^(NSError *error) {
        
    }];
}
//广告图
- (SDCycleScrollView *)advView {
    if (!_advView) {
        self.view.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
        _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,200) imageURLStringsGroup:nil];
        NSString *imageName = [NSObject judegeIsVietnamVersion]?@"v广告图":@"广告图";
        _advView.placeholderImage = [UIImage imageNamed:imageName];
        _advView.bannerImageViewContentMode = UIViewContentModeScaleToFill;
        [self loadAdvertisingPage];
    }
    return _advView;
}
- (WWWaterWaveView *)waterWaveView{
    if (!_waterWaveView) {
        _waterWaveView=[[WWWaterWaveView alloc] init];
        _waterWaveView.firstWaveColor =AppBaseTextColor3;
        //[UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:0.30];
        //第二个波浪颜色
        _waterWaveView.secondWaveColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:0.30];
        // 百分比
        _waterWaveView.percent = 0.5;
        [_waterWaveView startWave];
    }
    return _waterWaveView;
}

//- (UIImageView *)bgAdvBgView {
//    if (!_bgAdvBgView) {
//        _bgAdvBgView=[[UIImageView alloc]init];
//        [_bgAdvBgView setImage:[UIImage imageNamed:@"水波"]];
//
//    }
//    return _bgAdvBgView;
//}
- (UILabel *)dotLable {
    if (!_dotLable) {
        _dotLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-15, 30, 6, 6)];
        _dotLable.backgroundColor = [UIColor redColor];
        _dotLable.layer.cornerRadius = 3;
        _dotLable.clipsToBounds = YES;
        _dotLable.hidden=YES;
    }
    return _dotLable;
}

- (UIButton *)addressButton {
    if (!_addressButton) {
        _addressButton=[[UIButton alloc]initWithFrame:CGRectMake(15, 35, 150, 14)];
        [_addressButton setImage:[UIImage imageNamed:@"定位"] forState:0];
        _addressButton.titleLabel.font=FontOfSize(12);
        _addressButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _addressButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        @weakify(self)
        [_addressButton bk_whenTapped:^{
            @strongify(self)
            [self selectJails];
        }];
    }
    return _addressButton;
}

- (UIButton *)messageButton {
    if (!_messageButton) {
        
        UIImageView *messageImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 15, 15)];
        messageImg.image = [UIImage imageNamed:@"消息"];
        _messageButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-50,20,50,50)];
        [_messageButton addSubview:messageImg];
//        [_messageButton setImage:[UIImage imageNamed:@"消息"] forState:0];
        @weakify(self)
        [_messageButton bk_whenTapped:^{
            @strongify(self)
            [self messageAction];
        }];
    }
    return _messageButton;
}

-(UIView *)prisonIntroduceView {
    if (!_prisonIntroduceView) {
        _prisonIntroduceView = [UIView new];
    }
    return _prisonIntroduceView;
}

-(UIView *)itemView {
    if (!_itemView) {
        _itemView = [UIView new];
        _itemView.layer.cornerRadius=4;
        _itemView.layer.masksToBounds=YES;
        _itemView.backgroundColor = [UIColor whiteColor];
        _itemView.frame = CGRectMake(19,self.advView.bottom+15,SCREEN_WIDTH-2*19, 88);
        NSArray *titles = @[@"远程探视",@"实地会见",@"电子商务",@"家属服务"];
        NSArray *imgs = @[@"远程探视",@"实地会见icon",@"电子商务icon",@"家属服务icon"];
        
        for (int i=0; i<4; i++) {
            CGFloat width = _itemView.width/4;
            UIView *view = [UIView new];
            view.frame = CGRectMake(width*i,0,width,88);
            [_itemView addSubview:view];
            UIImageView *iconImg = [UIImageView new];
            iconImg.image = [UIImage imageNamed:imgs[i]];
            iconImg.frame = CGRectMake((width-27)/2,20,27,27);
            [view addSubview:iconImg];

            UILabel *funLab = [UILabel new];
            funLab.frame=CGRectMake(0,55,view.width,20);
            funLab.text = titles[i];
            funLab.textAlignment = NSTextAlignmentCenter;
            funLab.textColor = UIColorFromRGB(102,102,102);
            funLab.font = FontOfSize(12);
            [view addSubview:funLab];
            view.tag = 10088+i;
            [view bk_whenTapped:^{
                if ([PSSessionManager sharedInstance].loginStatus==PSLoginPassed) {
                    NSInteger tag = view.tag-10088;
                    switch (tag) {
                        case 0:
                        {
                            [self appointmentPrisoner];
                        }
                            break;
                        case 1:
                        {
                            [self requestLocalMeeting];
                        }
                            break;
                        case 2:
                        {
                            [self e_commerce];
                        }
                            break;
                        case 3:
                        {
                            [self psFamilyService];
                        }
                            break;
                            
                        default:
                            break;
                    }
                } else {
                    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]) {
                        [[PSSessionManager sharedInstance]doLogout];
                    } else {
                        self.hidesBottomBarWhenPushed=YES;
                        PSLoginViewModel*viewModel=[[PSLoginViewModel alloc]init];
                        [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]initWithViewModel:viewModel] animated:YES];
                        self.hidesBottomBarWhenPushed=NO;
                    }
                }
            }];
        }
    }
    return _itemView;
}
-(UIView *)homeHallView {
    if (!_homeHallView) {
        _homeHallView = [UIView new];
    }
    return _homeHallView;
}
- (JXButton *)publicButton {
    if (!_publicButton) {
        _publicButton = [JXButton new];
    }
    return _publicButton;
}
-(UILabel *)prisonIntroduceContentLable{
    if (!_prisonIntroduceContentLable) {
        _prisonIntroduceContentLable = [UILabel new];
    }
    return _prisonIntroduceContentLable;
}

-(UIButton *)lawButton {
    if (!_lawButton) {
        _lawButton = [[UIButton alloc] init];
    }
    return _lawButton;
}
-(UIButton *)workButton {
    if (!_workButton) {
        _workButton = [[UIButton alloc] init];
    }
    return _workButton;
}
-(UIButton *)prisonIntroduceButton {
    if (!_prisonIntroduceButton) {
        _prisonIntroduceButton = [[UIButton alloc] init];
    }
    return _prisonIntroduceButton;
}







@end
