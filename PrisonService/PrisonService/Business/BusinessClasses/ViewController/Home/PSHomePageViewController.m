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
#import "PSUniversaLawViewController.h"
#import "UIButton+LZCategory.h"

#import "PSLocateManager.h"

@interface PSHomePageViewController ()
@property (nonatomic, strong) PSDefaultJailRequest*jailRequest;
@property (nonatomic, strong) NSString *defaultJailId;
@property (nonatomic, strong) NSString *defaultJailName;
@property (nonatomic, strong) UIButton*addressButton;
@property (nonatomic, strong) UIButton*messageButton ;
@property (nonatomic, strong) UILabel *dotLable;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, strong) UIScrollView *myScrollview;
@property (nonatomic, assign) NSInteger getTokenCount;
@property (nonatomic, strong)UIImageView *itemView;
@property (nonatomic, strong)WWWaterWaveView *waterWaveView;
@property (nonatomic, strong)UIImageView *prisonIntroduceView; //监狱简介
@property (nonatomic, strong)UILabel *prisonTitleLable;
@property (nonatomic, strong)UILabel*prisonIntroduceContentLable;
@property (nonatomic, strong)UIView *moreServicesView; //更多服务


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
    self.view.backgroundColor=UIColorFromRGBA(253, 253, 253, 1);
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
    //获取到定位信息刷新广告页
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAdvertisingPage) name:KNotificationRefreshAdvertisement object:nil];
  
    

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

//MARK:重新获取TOKEN
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

//MARK:加载广告页
-(void)loadAdvertisingPage{
    /*
     PSWorkViewModel *workViewModel = [PSWorkViewModel new];
     [workViewModel requestAdvsCompleted:^(PSResponse *response) {
     _advView.imageURLStringsGroup = workViewModel.advUrls;
     } failed:^(NSError *error) {
     
     }];/
     */
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

//MARK:系统消息
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
//    [self.myScrollview addSubview:self.waterWaveView];
//    self.waterWaveView.frame = CGRectMake(0,_advView.bottom-44, SCREEN_WIDTH, 44);
    
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

    //监狱背景
    [self.myScrollview addSubview:self.prisonIntroduceView];
    _prisonIntroduceView.frame = CGRectMake(sidePadding,_itemView.bottom+spacing,SCREEN_WIDTH-2*sidePadding,107);
    //监狱简介标题
    self.prisonTitleLable.frame = CGRectMake((_prisonIntroduceView.width-100)/2,spacing,100, 15);
    [_prisonIntroduceView addSubview:self.prisonTitleLable];
    //监狱简介内容
    [_prisonIntroduceView addSubview:self.prisonIntroduceContentLable];
    _prisonIntroduceContentLable.frame = CGRectMake(30, 28,_prisonIntroduceView.width-60,63);
    //更多服务
    [self.myScrollview addSubview:self.moreServicesView];
    self.moreServicesView.frame = CGRectMake(0,_prisonIntroduceView.bottom+spacing,KScreenWidth,180);
    
    
    if ([[LXFileManager readUserDataForKey:@"isVistor"]isEqualToString:@"YES"]){
        _messageButton.hidden=YES;
    }
    
}

#pragma mark - TouchEvent
//MARK:监狱简介
-(void)p_InsertPrisonIntroduce {
    PSPrisonIntroduceViewController *prisonViewController = [[PSPrisonIntroduceViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?t=%@",PrisonDetailUrl,self.defaultJailId,[NSDate getNowTimeTimestamp]]]];
    [self.navigationController pushViewController:prisonViewController animated:YES];
}
//MARK:狱务公开
-(void)p_InsertPrisonPublic:(UIButton *)sender {
    PrisonOpenViewController *prisonVC = [[PrisonOpenViewController alloc] init];
    prisonVC.jailId=self.defaultJailId;
    prisonVC.jailName=self.defaultJailName;
    [self.navigationController pushViewController:prisonVC animated:YES];
}
//MARK:法律法规
-(void)p_insertLaw:(UIButton *)senser {
    PSUniversaLawViewController *PSUniversaLaw = [[PSUniversaLawViewController alloc] init];
    [self.navigationController pushViewController:PSUniversaLaw animated:YES];
}
//MARK:工作动态
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
    [self showPrisonLimits:@"电子商务" limitBlock:^{
        
    }];
}
#pragma mark ——————— 家属服务
-(void)psFamilyService {
    PSFamilyServiceViewController *serviceViewController = [[PSFamilyServiceViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
    [self.navigationController pushViewController:serviceViewController animated:YES];
}
#pragma mark ——————— 互动平台
-(void)interactive_platform {
    [self showPrisonLimits:@"互动平台" limitBlock:^{
        
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
        _dotLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-15,20, 6, 6)];
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
        UIImageView *messageImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 15, 15)];
        messageImg.image = [UIImage imageNamed:@"消息"];
        _messageButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-50,7,50,50)];
        [_messageButton addSubview:messageImg];
        @weakify(self)
        [_messageButton bk_whenTapped:^{
            @strongify(self)
            [self messageAction];
        }];
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
-(UIImageView *)itemView {
    if (!_itemView) {
        _itemView = [UIImageView new];
        _itemView.image = IMAGE_NAMED(@"commonBg");
        _itemView.frame = CGRectMake(4,self.advView.bottom-60,SCREEN_WIDTH-8,124);
        _itemView.userInteractionEnabled = YES;
         NSArray *titles = @[@"远程探视",@"实地会见",@"电子商务",@"家属服务",@"互动平台"];
         NSArray *imgs =   @[@"远程探视",@"实地会见icon",@"电子商务icon",@"家属服务icon",@"互动平台icon"];
        for (int i=0; i<titles.count; i++) {
            CGFloat width = (_itemView.width-20)/titles.count;
            UIButton *itemBtn = [UIButton new];
            itemBtn.frame = CGRectMake(width*i+10,0,width,88);
            [_itemView addSubview:itemBtn];
            [itemBtn setImage:IMAGE_NAMED(imgs[i]) forState:UIControlStateNormal];
            [itemBtn setTitle:titles[i] forState:UIControlStateNormal];
            [itemBtn setTitleColor:UIColorFromRGB(51,51,51) forState:UIControlStateNormal];
            itemBtn.titleLabel.font = FontOfSize(12);
//            [itemBtn setbuttonType:LZCategoryTypeBottom];
            itemBtn.tag = 10088+i;
            [itemBtn lz_initButton:itemBtn];
            [itemBtn bk_whenTapped:^{
                if ([PSSessionManager sharedInstance].loginStatus==PSLoginPassed) {
                    NSInteger tag = itemBtn.tag-10088;
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
                        case 4:
                        {
                            [self interactive_platform];
                        }
                            break;
                            
                        default:
                            break;
                    }
                } else {
                    [self doNotLoginPassed];
                }
            }];
        }
    }
    return _itemView;
}


//MARK:更多服务
- (UIView *)moreServicesView {
    if (!_moreServicesView) {
        _moreServicesView = [UIView new];
        
        UILabel *label = [UILabel new];
        label.text = @"更多服务";
        label.font = boldFontOfSize(13);
        label.textColor = UIColorFromRGB(51, 51,51);
        label.textAlignment=NSTextAlignmentLeft;
        label.frame = CGRectMake(18,2, 100, 20);
        [_moreServicesView addSubview:label];
        NSString*prison_opening=NSLocalizedString(@"prison_opening", @"狱务公开");
        NSString*laws_regulations=NSLocalizedString(@"laws_regulations", @"全民普法");
        NSString*work_dynamic=NSLocalizedString(@"work_dynamic", @"工作动态");
        NSArray *moreItmetitles = @[prison_opening,laws_regulations,work_dynamic];
        NSArray *imgs = @[@"狱务公开icon",@"全民普法icon",@"工作动态icon"];
        int moreItemWidth = (KScreenWidth)/moreItmetitles.count;
        for (int i = 0; i<moreItmetitles.count; i++) {
            UIImageView *moreItemBg = [UIImageView new];
            moreItemBg.userInteractionEnabled = YES;
            moreItemBg.image = IMAGE_NAMED(@"更多服务单个底");
            moreItemBg.frame = CGRectMake(i*moreItemWidth,22,moreItemWidth,160);
            [_moreServicesView addSubview:moreItemBg];
            UIButton *moreBtnItem = [UIButton new];
            moreBtnItem.frame = CGRectMake(0, 0,moreItemBg.width,moreItemBg.width);
            moreBtnItem.tag = 1000+i;
            [moreBtnItem setImage:IMAGE_NAMED(imgs[i]) forState:UIControlStateNormal];
            [moreBtnItem setTitle:moreItmetitles[i] forState:UIControlStateNormal];
            [moreBtnItem setTitleColor:UIColorFromRGB(51,51,51) forState:UIControlStateNormal];
            moreBtnItem.titleLabel.font = FontOfSize(12);
            [moreBtnItem setbuttonType:LZCategoryTypeBottom spaceHeght:15];
            [moreItemBg addSubview:moreBtnItem];
            [moreBtnItem bk_whenTapped:^{
                if ([PSSessionManager sharedInstance].loginStatus==PSLoginPassed) {
                    NSInteger tag = moreBtnItem.tag-1000;
                    switch (tag) {
                        case 0:
                        {
                            [self p_InsertPrisonPublic:moreBtnItem];
                        }
                            break;
                        case 1:
                        {
                            [self p_insertLaw:moreBtnItem];
                        }
                            break;
                        case 2:
                        {
                            [self p_inserDynamic:moreBtnItem];
                        }
                            break;
                        default:
                            break;
                    }
                } else {
                    [self doNotLoginPassed];
                }
            }];
            
        }
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
