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
@property (nonatomic, strong) UIImageView *bgAdvBgView;
@property (nonatomic, assign) NSInteger getTokenCount;


@end

@implementation PSHomePageViewController

#pragma mark  - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                    _prisonIntroduceContentLable.text = [[attrStr string] substringFromIndex:16];
                } else {
                    _prisonIntroduceContentLable.text = [attrStr string];
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
    
//    [self.view addSubview:self.myScrollview];
    [self.myScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.myScrollview.contentSize = CGSizeMake(SCREEN_WIDTH,603);
    });
    CGFloat sidePadding=19;
    CGFloat spacing=10;
    //广告图
    [self.myScrollview addSubview:self.advView];
    [self.advView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(244);
    }];
    
    //背景水波
    [self.myScrollview addSubview:self.bgAdvBgView];
    [self.bgAdvBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_advView.mas_bottom).offset(-44);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(SCREEN_WIDTH);
    } ];
    
 
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

    UIView*prisonIntroduceView=[UIView new];
    prisonIntroduceView.backgroundColor=[UIColor whiteColor];
    [self.myScrollview addSubview:prisonIntroduceView];
    
    [prisonIntroduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgAdvBgView.mas_bottom).offset(spacing);
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
    //详情背景,增大点击事件范围
    UIButton *prisonIntroduceButtonBg = [UIButton new];
    prisonIntroduceButtonBg.backgroundColor = [UIColor clearColor];
    [prisonIntroduceView addSubview:prisonIntroduceButtonBg];
    [prisonIntroduceButtonBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(prisonIntroduceView.mas_top).offset(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(60);
    }];
    
    UIButton*prisonIntroduceButton=[UIButton new];
    NSString*details=NSLocalizedString(@"details", @"详情");
    [prisonIntroduceButton setTitle:details forState:0];
    prisonIntroduceButton.titleLabel.font=FontOfSize(12);
    [prisonIntroduceButton setTitleColor:AppBaseTextColor3 forState:0];
    prisonIntroduceButton.enabled = NO;
    prisonIntroduceButton.userInteractionEnabled = NO;
    prisonIntroduceButton.contentHorizontalAlignment
    =UIControlContentHorizontalAlignmentRight;
    [prisonIntroduceView addSubview:prisonIntroduceButton];
    [prisonIntroduceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(prisonIntroduceView.mas_top).offset(spacing);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(50);
    }];
    //写成这样方便埋点
    [prisonIntroduceButtonBg addTarget:self action:@selector(p_InsertPrisonIntroduce:) forControlEvents:UIControlEventTouchUpInside];
    
//    [prisonIntroduceButtonBg bk_whenTapped:^{
//        PSPrisonIntroduceViewController *prisonViewController = [[PSPrisonIntroduceViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?t=%@",PrisonDetailUrl,self.defaultJailId,[NSDate getNowTimeTimestamp]]]];
//        [self.navigationController pushViewController:prisonViewController animated:YES];
//    }];
    
//    [prisonIntroduceButton bk_whenTapped:^{
//
//    }];
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
    [self.myScrollview addSubview:homeHallView];
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
    [publicButton addTarget:self action:@selector(p_InsertPrisonPublic:) forControlEvents:UIControlEventTouchUpInside];
    
//    [publicButton bk_whenTapped:^{
//        PSWorkViewModel *viewModel = [PSWorkViewModel new];
//        viewModel.newsType = PSNewsPrisonPublic;
//        PSPublicViewController *publicViewController = [[PSPublicViewController alloc] initWithViewModel:viewModel];
//        publicViewController.jailId=self.defaultJailId;
//        publicViewController.jailName=self.defaultJailName;
//        if (self.defaultJailId==nil||self.defaultJailName==nil) {
//            [PSTipsView showTips:@"当前网络不支持"];
//        } else {
//            publicViewController.hidesBottomBarWhenPushed=YES;
//            [self.navigationController pushViewController:publicViewController animated:YES];
//            publicViewController.hidesBottomBarWhenPushed=NO;
//        }
//    }];
    
    UIView *dashLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+1, 0, 1, 200)];
    dashLine.backgroundColor=AppBaseLineColor;
    [homeHallView addSubview:dashLine];
   
    UIButton*lawButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+2, 0, SCREEN_WIDTH/2-sidePadding, 100)];
    [homeHallView addSubview:lawButton];
     NSString*laws_regulations=NSLocalizedString(@"laws_regulations", @"法律法规");
    [lawButton setTitle:laws_regulations forState:0];
    [lawButton setTitleColor:[UIColor blackColor] forState:0];
    lawButton .titleLabel.font=  [NSObject judegeIsVietnamVersion]?FontOfSize(10):FontOfSize(12);
    lawButton.titleLabel.numberOfLines = 0;
    [lawButton setImage:[UIImage imageNamed:@"法律法规"] forState:0];
    [lawButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];//间距
    [lawButton addTarget:self action:@selector(p_insertLaw:) forControlEvents:UIControlEventTouchUpInside];
//    [lawButton bk_whenTapped:^{
//        PSLawViewController *lawViewController = [[PSLawViewController alloc] init];
//        [self.navigationController pushViewController:lawViewController animated:YES];
//    }];
    
    
    UIView *verDashLine = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+1, 100, SCREEN_WIDTH/2-sidePadding-2, 1)];
    [homeHallView addSubview:verDashLine];
    verDashLine.backgroundColor=AppBaseLineColor;
    UIButton*workButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-sidePadding+2, 100, SCREEN_WIDTH/2-sidePadding, 100)];
    [homeHallView addSubview:workButton];
    NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
    workButton.titleLabel.numberOfLines = 0;
    [workButton setTitle:work_dynamic forState:0];
    [workButton setTitleColor:[UIColor blackColor] forState:0];
    workButton .titleLabel.font=  [NSObject judegeIsVietnamVersion]?FontOfSize(10):FontOfSize(12);
    [workButton setImage:[UIImage imageNamed:@"工作动态"] forState:0];
    [workButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    [workButton addTarget:self action:@selector(p_inserDynamic:) forControlEvents:UIControlEventTouchUpInside];
//    [workButton bk_whenTapped:^{
//        PSWorkViewModel *viewModel = [PSWorkViewModel new];
//        viewModel.newsType = PSNewsWorkDynamic;
//        PSDynamicViewController *dynamicViewController = [[PSDynamicViewController alloc] initWithViewModel:viewModel];
//        dynamicViewController.jailId=self.defaultJailId;
//        dynamicViewController.jailName=self.defaultJailName;
//        if (self.defaultJailName==nil||self.defaultJailId==nil) {
//            [PSTipsView showTips:@"当前网络不支持"];
//        } else {
//            [self.navigationController pushViewController:dynamicViewController animated:YES];
//        }
//    }];
    
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
}
//法律法规
-(void)p_insertLaw:(UIButton *)senser {
    PSLawViewController *lawViewController = [[PSLawViewController alloc] init];
    [self.navigationController pushViewController:lawViewController animated:YES];
}
//工作动态
-(void)p_inserDynamic:(UIButton *)sender {
    
    PSWorkViewModel *viewModel = [PSWorkViewModel new];
    viewModel.newsType = PSNewsWorkDynamic;
    PSDynamicViewController *dynamicViewController = [[PSDynamicViewController alloc] initWithViewModel:viewModel];
    dynamicViewController.jailId=self.defaultJailId;
    dynamicViewController.jailName=self.defaultJailName;
//    if (self.defaultJailName==nil||self.defaultJailId==nil) {
//        [PSTipsView showTips:@"当前网络不支持"];
//    } else {
        [self.navigationController pushViewController:dynamicViewController animated:YES];
//    }
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
        self.view.backgroundColor=UIColorFromRGBA(248, 247, 254, 1);
        _advView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 244) imageURLStringsGroup:nil];
        NSString *imageName = [NSObject judegeIsVietnamVersion]?@"v广告图":@"广告图";
        _advView.placeholderImage = [UIImage imageNamed:imageName];
        _advView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    }
    return _advView;
}
- (UIImageView *)bgAdvBgView {
    if (!_bgAdvBgView) {
        _bgAdvBgView=[[UIImageView alloc]init];
        [_bgAdvBgView setImage:[UIImage imageNamed:@"水波"]];
    }
    return _bgAdvBgView;
}
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





@end
