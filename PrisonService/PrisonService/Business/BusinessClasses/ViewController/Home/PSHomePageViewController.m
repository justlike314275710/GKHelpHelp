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




@interface PSHomePageViewController ()
@property (nonatomic, strong) PSDefaultJailRequest*jailRequest;
@property (nonatomic, strong) NSString *defaultJailId;
@property (nonatomic, strong) NSString *defaultJailName;
@property (nonatomic , strong) UIButton*addressButton;
@property (nonatomic , strong) UILabel*prisonIntroduceContentLable;
@property (nonatomic , strong) UIButton*messageButton ;
@property (nonatomic , strong) UILabel *dotLable;
@property (nonatomic, strong) PSUserSession *session;
@end

@implementation PSHomePageViewController

#pragma mark  - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reachability];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshDataFromLoginStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDot) name:AppDotChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:JailChange object:nil];

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
                [[PSLoadingView sharedInstance] dismiss];
            
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
            [self showNetError];
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
            [self renderContents:isShow];
            NSString*profileSting= vistorViewModel.profile;
            NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithData:[profileSting dataUsingEncoding:NSUnicodeStringEncoding]options:@{
                                                                                                                                                                   NSDocumentTypeDocumentAttribute:
                                                                                                                                                                       NSHTMLTextDocumentType
                                                                                                                                                                   }documentAttributes:nil error:nil];
            if ([[attrStr string]containsString:@"您的浏览器不支持Video标签。"]) {
                _prisonIntroduceContentLable.text = [[attrStr string] substringFromIndex:16];
            } else {
                _prisonIntroduceContentLable.text = [attrStr string];
            }
        
            [[PSLoadingView sharedInstance]dismiss];

        } else {
            [PSTipsView showTips:response.msg];
            [self renderContents:isShow];
            [[PSLoadingView sharedInstance]dismiss];
        }
       

       
    } failed:^(NSError *error) {
        [self showNetError];
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


#pragma mark  - Delegate

- (BOOL)showAdv {
    return YES;
}

- (BOOL)hiddenNavigationBar{
    return YES;
}

#pragma mark  - UI
-(void)renderContents:(BOOL)isShow{
    
    CGFloat sidePadding=19;
    CGFloat spacing=10;
    self.view.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
    _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 244) imageURLStringsGroup:nil];
    _advView.placeholderImage = [UIImage imageNamed:@"广告图"];
    _advView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_advView];
    
    UIImageView*bgAdvBgView=[[UIImageView alloc]init];
    [bgAdvBgView setImage:[UIImage imageNamed:@"水波"]];
    [self.view addSubview:bgAdvBgView];
    [bgAdvBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_advView.mas_bottom).offset(-44);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(SCREEN_WIDTH);
    } ];
    
    _addressButton=[[UIButton alloc]initWithFrame:CGRectMake(15, 35, 150, 14)];
    [_addressButton setImage:[UIImage imageNamed:@"定位"] forState:0];
    [_addressButton setTitle:self.defaultJailName forState:0];
    _addressButton.titleLabel.font=FontOfSize(12);
    [self.view addSubview:_addressButton];
    _addressButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _addressButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    @weakify(self)
      _addressButton.userInteractionEnabled=isShow;
    [_addressButton bk_whenTapped:^{
        @strongify(self)
        [self selectJails];
    }];
    
    
    _messageButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-30, 35, 15, 15)];
    [_messageButton setImage:[UIImage imageNamed:@"消息"] forState:0];
    [self.view addSubview:_messageButton];
    [_messageButton bk_whenTapped:^{
        @strongify(self)
        [self messageAction];
    }];
    _messageButton.hidden=isShow;

    self.dotLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-15, 30, 6, 6)];
    self.dotLable.backgroundColor = [UIColor redColor];
    self.dotLable.layer.cornerRadius = 3;
    self.dotLable.clipsToBounds = YES;
    self.dotLable.hidden=YES;
    [self.view addSubview:self.dotLable];
    
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString *dot = self.session.families.isNoticed;
    if ([dot isEqualToString:@"0"]) {
        self.dotLable.hidden = NO;
    }
    
    
    
    UIView*prisonIntroduceView=[UIView new];
    prisonIntroduceView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:prisonIntroduceView];
    [prisonIntroduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgAdvBgView.mas_bottom).offset(spacing);
        make.left.mas_equalTo(sidePadding);
        make.height.mas_equalTo(107);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
    }];
    prisonIntroduceView.layer.cornerRadius=4;
    prisonIntroduceView.layer.masksToBounds=YES;
    UILabel*prisonTitleLable=[UILabel new];
    NSString*prison_introduction=
    NSLocalizedString(@"prison_introduction", @"监狱简介");
    prisonTitleLable.text=prison_introduction;
    prisonTitleLable.font=AppBaseTextFont3;
    prisonTitleLable.textColor=[UIColor blackColor];
    prisonTitleLable.textAlignment=NSTextAlignmentLeft;
    [prisonIntroduceView addSubview:prisonTitleLable];
    [prisonTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(prisonIntroduceView.mas_top).offset(spacing);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(100);
    }];
    
    UIButton*prisonIntroduceButton=[UIButton new];
    NSString*details=NSLocalizedString(@"details", @"详情");
    [prisonIntroduceButton setTitle:details forState:0];
    prisonIntroduceButton.titleLabel.font=FontOfSize(12);
    [prisonIntroduceButton setTitleColor:AppBaseTextColor3 forState:0];
    prisonIntroduceButton.contentHorizontalAlignment
    =UIControlContentHorizontalAlignmentRight;
    [prisonIntroduceView addSubview:prisonIntroduceButton];
    [prisonIntroduceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(prisonIntroduceView.mas_top).offset(spacing);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(50);
    }];
    [prisonIntroduceButton bk_whenTapped:^{
        PSPrisonIntroduceViewController *prisonViewController = [[PSPrisonIntroduceViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PrisonDetailUrl,self.defaultJailId]]];
        [self.navigationController pushViewController:prisonViewController animated:YES];
    }];
    _prisonIntroduceContentLable=[UILabel new];
    _prisonIntroduceContentLable.font=FontOfSize(10);
    _prisonIntroduceContentLable.textColor=AppBaseTextColor1;
    _prisonIntroduceContentLable.textAlignment=NSTextAlignmentLeft;
    [prisonIntroduceView addSubview:_prisonIntroduceContentLable];
    [_prisonIntroduceContentLable mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.mas_equalTo(prisonIntroduceButton.mas_bottom).offset(spacing);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(15);
    }];
    _prisonIntroduceContentLable.numberOfLines=0;
    
    
    UIView*homeHallView=[UIView new];
    homeHallView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:homeHallView];
    [homeHallView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(prisonIntroduceView.mas_bottom).offset(spacing);
        make.left.mas_equalTo(sidePadding);
        make.height.mas_equalTo(200);
        make.width.mas_equalTo(SCREEN_WIDTH-2*sidePadding);
    }];
    homeHallView.layer.cornerRadius=2;
    homeHallView.layer.masksToBounds=YES;
    
    JXButton*publicButton=[[JXButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-sidePadding, 200)];
    [homeHallView addSubview:publicButton];
    NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
    [publicButton setTitle:prison_opening forState:0];
    [publicButton setTitleColor:[UIColor blackColor] forState:0];
    [publicButton setImage:[UIImage imageNamed:@"狱务公开"] forState:0];
    [publicButton bk_whenTapped:^{
        PSWorkViewModel *viewModel = [PSWorkViewModel new];
        viewModel.newsType = PSNewsPrisonPublic;
        PSPublicViewController *publicViewController = [[PSPublicViewController alloc] initWithViewModel:viewModel];
        publicViewController.jailId=self.defaultJailId;
        publicViewController.jailName=self.defaultJailName;
        publicViewController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:publicViewController animated:YES];
        publicViewController.hidesBottomBarWhenPushed=NO;
    }];
    
    UIView *dashLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+1, 0, 1, 200)];
    dashLine.backgroundColor=AppBaseLineColor;
    [homeHallView addSubview:dashLine];
   
    UIButton*lawButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+2, 0, SCREEN_WIDTH/2-sidePadding, 100)];
    [homeHallView addSubview:lawButton];
     NSString*laws_regulations=NSLocalizedString(@"laws_regulations", @"法律法规");
    [lawButton setTitle:laws_regulations forState:0];
    [lawButton setTitleColor:[UIColor blackColor] forState:0];
    lawButton .titleLabel.font=FontOfSize(12);
    [lawButton setImage:[UIImage imageNamed:@"法律法规"] forState:0];
    [lawButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];//间距
    [lawButton bk_whenTapped:^{
        PSLawViewController *lawViewController = [[PSLawViewController alloc] init];
        //lawViewController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:lawViewController animated:YES];
    }];
    
    
    
    UIView *verDashLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+1, 100, SCREEN_WIDTH/2-sidePadding-2, 1)];
    [homeHallView addSubview:verDashLine];
    verDashLine.backgroundColor=AppBaseLineColor;
    UIButton*workButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+2, 100, SCREEN_WIDTH/2-sidePadding, 100)];
    [homeHallView addSubview:workButton];
    NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
    [workButton setTitle:work_dynamic forState:0];
    [workButton setTitleColor:[UIColor blackColor] forState:0];
    workButton .titleLabel.font=FontOfSize(12);
    [workButton setImage:[UIImage imageNamed:@"工作动态"] forState:0];
    [workButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    [workButton bk_whenTapped:^{
        PSWorkViewModel *viewModel = [PSWorkViewModel new];
        viewModel.newsType = PSNewsWorkDynamic;
        PSDynamicViewController *dynamicViewController = [[PSDynamicViewController alloc] initWithViewModel:viewModel];
        dynamicViewController.jailId=self.defaultJailId;
        dynamicViewController.jailName=self.defaultJailName;
       // dynamicViewController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:dynamicViewController animated:YES];
    }];
    
    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]){
        _messageButton.hidden=YES;
    }
    
}



#pragma mark  - setter & getter

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDotChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JailChange object:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 网络检测
- (void)reachability {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                [KGStatusBar dismiss];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                //[self showInternetError];
                [KGStatusBar showWithStatus:@"当前网络不可用,请检查你的网络设置"];
                [self renderContents:YES];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [KGStatusBar dismiss];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [KGStatusBar dismiss];
            break; } }];
    [mgr startMonitoring];
    
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
