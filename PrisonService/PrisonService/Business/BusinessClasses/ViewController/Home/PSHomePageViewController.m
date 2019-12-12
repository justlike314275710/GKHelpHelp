//
//  PSAuthenticationHomePageViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/15.
//  Copyright © 2018年 calvin. All rights reserved.
//


#import "PSPrisonIntroduceViewController.h"
#import "PSPrisonContentViewController.h"
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
#import "PSCache.h"
#import "PSEcomLoginViewmodel.h"
#import "NSObject+version.h"
#import "WWWaterWaveView.h"
#import "PSAppointmentViewController.h"
#import "PSLocalMeetingViewController.h"
#import "PSFamilyServiceViewController.h"
#import "PrisonOpenViewController.h"
#import "PSLoginViewModel.h"
#import "PSUniversaLawViewController.h"
#import "UIButton+LZCategory.h"
#import "PSHomeFunctionView.h"
#import "PSHomeMoreFunctionView.h"
#import "InteractivePlatformViewController.h"
#import "PSAllMessageViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+other.h"

@interface PSHomePageViewController ()
@property (nonatomic, strong) PSDefaultJailRequest*jailRequest;
@property (nonatomic, strong) NSString *defaultJailId;
@property (nonatomic, strong) NSString *defaultJailName;
@property (nonatomic, strong) UIButton*addressButton;
@property (nonatomic, strong) UIButton*messageButton ;
@property (nonatomic, strong) UILabel *dotLable;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, strong) UIScrollView *myScrollview;
@property (nonatomic, strong) PSHomeFunctionView *homeFunctionView;
@property (nonatomic, strong) WWWaterWaveView *waterWaveView;
@property (nonatomic, strong) UIImageView *prisonIntroduceView; //监狱简介
@property (nonatomic, strong) UILabel *prisonTitleLable;
@property (nonatomic, strong) UILabel*prisonIntroduceContentLable;
@property (nonatomic, strong) PSHomeMoreFunctionView *moreServicesView; //更多服务
@property (nonatomic, strong) UIImageView *arcImageView;


@end

@implementation PSHomePageViewController

#pragma mark  - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.selectedIndex = 0;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor=UIColorFromRGBA(253, 253, 253, 1);
    //没有网络下不能为空白
    [self.view addSubview:self.myScrollview];
    [self renderContents:NO];
    [self refreshDataFromLoginStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDot) name:AppDotChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:JailChange object:nil];
    //重新获取token
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOfRefreshToken) name:RefreshToken object:nil];
    //获取到定位信息刷新广告页
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAdvertisingPage) name:KNotificationRefreshAdvertisement object:nil];
    //调用未读数量接口
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCountVisit) name:KNOtificationALLMessagejudgeToken object:nil];
    //获取未读消息数
    [self getCountVisit];
    //定位
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate checkAuthorizationWithLocation];
    
    //测试环境
    if (UAT==1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth-70,0, 50, 20)];
            label.textColor = [UIColor redColor];
            label.text = @"测试";
            label.font = FontOfSize(10);
            UIWindow *wd = [UIApplication sharedApplication].keyWindow;
            [wd addSubview:label];
        });
    }
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDotChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JailChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RefreshToken object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationRefreshAdvertisement object:nil];
}
#pragma mark  - notification
-(void)showDot{
    self.dotLable.hidden = NO;
    [self getCountVisit];
}
-(void)refreshData{
    PSHomeViewModel *homeViewModel   = (PSHomeViewModel *)self.viewModel;
    NSInteger index                  = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = nil;
    if (index >= 0 && index < homeViewModel.passedPrisonerDetails.count) {
    prisonerDetail                   = homeViewModel.passedPrisonerDetails[index];
    }
    self.defaultJailName             = prisonerDetail.jailName;
    self.defaultJailId               = prisonerDetail.jailId;
    [self requestjailsDetailsWithJailId:prisonerDetail.jailId isShow:NO];
}
//MARK:重新获取TOKEN
-(void)requestOfRefreshToken{
    
    AppDelegate *appDelegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.getTokenCount ++;
    if (appDelegate.getTokenCount<2) {
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
//MARK:加载广告页
-(void)loadAdvertisingPage{
     PSWorkViewModel *workViewModel = [PSWorkViewModel new];
     [workViewModel requestAdvsCompleted:^(PSResponse *response) {
     _advView.imageURLStringsGroup  = workViewModel.advUrls;
     } failed:^(NSError *error) {

     }];
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
//MARK:获取系统消息数
- (void)getCountVisit{
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    [homeViewModel getRequestCountVisitCompleted:^(PSResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([homeViewModel.messageCountModel.total integerValue]>0) {
                _messageButton.redDotNumber = [homeViewModel.messageCountModel.total integerValue];
                _messageButton.redDotBorderWidth = 1.0;
                _messageButton.redDotBorderColor = [UIColor magentaColor];
                [_messageButton ShowBadgeView];
            } else {
                [_messageButton hideBadgeView];
            }
        });
    } failed:^(NSError *error) {
        //TOKEN失效
        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:RefreshToken object:nil];
        } else {
            [self showNetError:error isShowTokenError:NO];
        }
    }];
}
//MARK:系统消息
- (void)messageAction:(UIButton *)sender{
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    PSAllMessageViewController *allMessageVC = [[PSAllMessageViewController alloc] init];
    if ([homeViewModel.messageCountModel.lastNewsType isEqualToString:@"0"]) { //没有新消息
        allMessageVC.current = 0;
    } else if([homeViewModel.messageCountModel.lastNewsType isEqualToString:@"4"]) { //互动文章
        allMessageVC.current= 2;
    } else {
        allMessageVC.current= 1;
    }
    allMessageVC.model = homeViewModel.messageCountModel;
    @weakify(self);
    allMessageVC.backBlock = ^{
        @strongify(self);
        [self getCountVisit];
    };
    [self.navigationController pushViewController:allMessageVC animated:YES];
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
                NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithData:[profileSting dataUsingEncoding:NSUnicodeStringEncoding]options:@{NSDocumentTypeDocumentAttribute:
                                                                                            NSHTMLTextDocumentType
                                                                                }documentAttributes:nil error:nil];
                if ([[attrStr string]containsString:@"您的浏览器不支持Video标签。"]) {
                    self.prisonIntroduceContentLable.text = [[attrStr string] substringFromIndex:16];
                } else {
                    self.prisonIntroduceContentLable.text = [attrStr string];
                }
                self.prisonIntroduceContentLable.lineSpace = @"4";//行距
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
        [self showNetError:error isShowTokenError:NO];
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
//    [self.myScrollview addSubview:self.waterWaveView];
//    self.waterWaveView.frame = CGRectMake(0,_advView.bottom-44, SCREEN_WIDTH, 44);
    [self.myScrollview addSubview:self.arcImageView];
    self.arcImageView.frame = CGRectMake(0,200, KScreenWidth,26);
    self.arcImageView.top = self.advView.bottom-12;
    
    [self.myScrollview addSubview:self.addressButton];
    [self.addressButton setTitle:self.defaultJailName forState:0];
    self.addressButton.userInteractionEnabled=isShow;
    [self.myScrollview addSubview:self.messageButton];
//    self.messageButton.hidden=isShow;
    //消息红点
    [self.myScrollview addSubview:self.dotLable];
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString *dot = self.session.families.isNoticed;
    if ([dot isEqualToString:@"0"]) {
        self.dotLable.hidden = NO;
    }
    [self.myScrollview addSubview:self.homeFunctionView];
    //监狱简介背景
    [self.myScrollview addSubview:self.prisonIntroduceView];
    
    _prisonIntroduceView.frame = CGRectMake(sidePadding,_homeFunctionView.bottom+spacing,SCREEN_WIDTH-2*sidePadding,107);
    //监狱简介标题
    self.prisonTitleLable.frame = CGRectMake((_prisonIntroduceView.width-100)/2,spacing,100, 15);
    [_prisonIntroduceView addSubview:self.prisonTitleLable];
    //监狱简介内容
    [_prisonIntroduceView addSubview:self.prisonIntroduceContentLable];
    _prisonIntroduceContentLable.frame = CGRectMake(30, 28,_prisonIntroduceView.width-60,63);
    //更多服务
    [self.myScrollview addSubview:self.moreServicesView];
    self.moreServicesView.frame = CGRectMake(0,_prisonIntroduceView.bottom+15,KScreenWidth,180);
    
    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]){
        _messageButton.hidden=YES;
    }
    
}

#pragma mark - TouchEvent
//MARK:顶部Item事件
- (void)dicHomeFuctionItem:(NSInteger)index {
    
    if ([PSSessionManager sharedInstance].loginStatus==PSLoginPassed) {
        switch (index) {
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
            case 4:
            {
                [self interactive_platform];
            }
                break;
                
            default:
                break;
        }
    } else {
        if (index==4) {
            [self interactive_platform];
        } else {
            [self doNotLoginPassed];
        }
    }
}

- (void)clickHomeMoreFunctionItem:(NSInteger)index {
    if ([PSSessionManager sharedInstance].loginStatus==PSLoginPassed) {
        switch (index) {
            case 0:
            {
                [self p_InsertPrisonPublic:nil];
            }
                break;
            case 1:
            {
                [self p_insertLaw:nil];
            }
                break;
            case 2:
            {
                [self p_inserDynamic:nil];
            }
                break;
            default:
                break;
        }
    } else {
        [self doNotLoginPassed];
    }
}

#pragma mark ———————监狱简介
-(void)p_InsertPrisonIntroduce {
    [SDTrackTool logEvent:CLICK_JAIL_DETAIL];
    PSPrisonIntroduceViewController *prisonViewController = [[PSPrisonIntroduceViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?t=%@",PrisonDetailUrl,self.defaultJailId,[NSDate getNowTimeTimestamp]]]];
    [self.navigationController pushViewController:prisonViewController animated:YES];
}
#pragma mark ——————— 狱务公开
-(void)p_InsertPrisonPublic:(UIButton *)sender {
    PrisonOpenViewController *prisonVC = [[PrisonOpenViewController alloc] init];
    prisonVC.jailId=self.defaultJailId;
    prisonVC.jailName=self.defaultJailName;
    [self.navigationController pushViewController:prisonVC animated:YES];
}
#pragma mark ——————— 法律法规
-(void)p_insertLaw:(UIButton *)senser {
    PSUniversaLawViewController *PSUniversaLaw = [[PSUniversaLawViewController alloc] init];
    [self.navigationController pushViewController:PSUniversaLaw animated:YES];
}
#pragma mark ——————— 工作动态
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
    [SDTrackTool logEvent:HOME_PAGE_YCTS];
    PSAppointmentViewController *appointmentViewController = [[PSAppointmentViewController alloc] initWithViewModel:[PSAppointmentViewModel new]];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}
#pragma mark ——————— 实地会见
- (void)requestLocalMeeting {
    [SDTrackTool logEvent:HOME_PAGE_SDHJ];
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
        [self showNetError:error isShowTokenError:NO];
    }];
}
#pragma mark ——————— 电子商务
-(void)e_commerce {
    [SDTrackTool logEvent:CLICK_E_MALL];
    [self showPrisonLimits:@"电子商务" limitBlock:^{
        
    }];
}
#pragma mark ——————— 家属服务
-(void)psFamilyService {
    [SDTrackTool logEvent:HOME_PAGE_JSFW];
    PSFamilyServiceViewController *serviceViewController = [[PSFamilyServiceViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
    [self.navigationController pushViewController:serviceViewController animated:YES];
}
#pragma mark ——————— 互动平台
-(void)interactive_platform {
    [self showPrisonLimits:@"互动平台" limitBlock:^{
        InteractivePlatformViewController *platformVC = [[InteractivePlatformViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
        [self.navigationController pushViewController:platformVC animated:YES];
    }];
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
//广告图
- (SDCycleScrollView *)advView {
    if (!_advView) {
        _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,220) imageURLStringsGroup:nil];
        NSString *imageName = [NSObject judegeIsVietnamVersion]?@"vbanner":@"banner";
        _advView.placeholderImage = [UIImage imageNamed:imageName];
        _advView.bannerImageViewContentMode = UIViewContentModeScaleToFill;
        _advView.backgroundColor = [UIColor whiteColor];
        [self loadAdvertisingPage];
    }
    return _advView;
}

- (UIImageView *)arcImageView {
    if (!_arcImageView) {
        _arcImageView = [UIImageView new];
        _arcImageView.image = IMAGE_NAMED(@"弧形背景");
    }
    return _arcImageView;
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
//红点
- (UILabel *)dotLable {
    if (!_dotLable) {
//        _dotLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-15,20, 6, 6)];
        _dotLable.backgroundColor = [UIColor redColor];
        _dotLable.layer.cornerRadius = 3;
        _dotLable.clipsToBounds = YES;
        _dotLable.hidden=YES;
    }
    return _dotLable;
}

//监狱地址
- (UIButton *)addressButton {
    if (!_addressButton) {
        _addressButton=[[UIButton alloc]initWithFrame:CGRectMake(15,25, 150, 14)];
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
        _messageButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-30,22,15,15)];
        [_messageButton be_setEnlargeEdgeWithTop:10 right:15 bottom:10 left:15];
        [_messageButton setImage:IMAGE_NAMED(@"消息") forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

//监狱简介底
-(UIImageView *)prisonIntroduceView {
    if (!_prisonIntroduceView) {
        _prisonIntroduceView = [UIImageView new];
        _prisonIntroduceView.userInteractionEnabled = YES;
        _prisonIntroduceView.image = IMAGE_NAMED(@"监狱简介底");
        [_prisonIntroduceView bk_whenTapped:^{
            [self p_InsertPrisonIntroduce];
        }];
    }
    return _prisonIntroduceView;
}
//MARK:常用功能
-(PSHomeFunctionView *)homeFunctionView {
    if (!_homeFunctionView) {
        NSArray *titles =  @[@"远程探视",@"实地会见",@"电子商务",@"家属服务",@"互动平台"];
        NSArray *imageIcons = @[@"远程探视",@"实地会见icon",@"电子商务icon",@"家属服务icon",@"互动平台icon"];
        _homeFunctionView = [[PSHomeFunctionView alloc] initWithFrame:CGRectMake(4,self.advView.bottom-60,SCREEN_WIDTH-8, 120) titles:titles imageIcons:imageIcons];
        @weakify(self);
        _homeFunctionView.homeFunctionBlock = ^(NSInteger index) {
            @strongify(self);
            [self dicHomeFuctionItem:index];
        };
    }
    return _homeFunctionView;
}

//MARK:更多服务
-(PSHomeMoreFunctionView *)moreServicesView {
    if (!_moreServicesView) {
        _moreServicesView = [[PSHomeMoreFunctionView alloc] init];
        @weakify(self);
        _moreServicesView.moreFunctionBlock = ^(NSInteger index) {
            @strongify(self);
            [self clickHomeMoreFunctionItem:index];
        };
    }
    return _moreServicesView;
}
//监狱简介内容
-(UILabel *)prisonIntroduceContentLable{
    if (!_prisonIntroduceContentLable) {
        _prisonIntroduceContentLable = [UILabel new];
        _prisonIntroduceContentLable.numberOfLines=0;
        _prisonIntroduceContentLable.font=FontOfSize(12);
        _prisonIntroduceContentLable.textColor=AppBaseTextColor1;
        _prisonIntroduceContentLable.textAlignment=NSTextAlignmentLeft;
    }
    return _prisonIntroduceContentLable;
}

- (UILabel *)prisonTitleLable {
    if (!_prisonTitleLable) {
        _prisonTitleLable = [UILabel new];
        NSString*prison_introduction=
        NSLocalizedString(@"prison_introduction", @"监狱简介");
        _prisonTitleLable.text=prison_introduction;
        _prisonTitleLable.font = boldFontOfSize(13);
        _prisonTitleLable.textColor=[UIColor blackColor];
        _prisonTitleLable.textColor = UIColorFromRGB(51, 51,51);
        _prisonTitleLable.textAlignment=NSTextAlignmentCenter;
    }
    return _prisonTitleLable;
}


@end
