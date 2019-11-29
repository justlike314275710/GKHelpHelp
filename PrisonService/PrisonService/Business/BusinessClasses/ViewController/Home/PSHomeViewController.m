//
//  PSHomeViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/3.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSHomeViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "PSMessageViewController.h"
#import "PSAppointmentInfoCell.h"
#import "PSHomeHallSectionView.h"
#import "PSHallFunctionCell.h"
#import "PSCommerceViewController.h"
#import "PSLawViewController.h"
#import "PSPrisonIntroduceViewController.h"
#import "PSFamilyServiceViewController.h"
#import "PSDynamicViewController.h"
#import "PSPublicViewController.h"
#import "PSComplaintSuggestionViewController.h"
#import "PSAppointmentViewController.h"
#import "PSPrisonerCell.h"
#import "NSDate+Components.h"
#import "PSPrisonerManageViewController.h"
#import "PSBusinessConstants.h"
#import "PSLocalMeetingViewController.h"
#import "PSUserSession.h"
#import "PSCache.h"
#import "PSBusinessConstants.h"
#import "PSSessionManager.h"
#import <AFNetworking/AFNetworking.h>
#import "XXEmallViewController.h"
#import "PSContentManager.h"
#import "PSUniversaLawViewController.h"


@interface PSHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *homeCollectionView;
@property(nonatomic , strong) UILabel *dotLable;
@property (nonatomic, strong) PSUserSession *session;
@property (nonatomic, strong) NSString* localCode;

@end

@implementation PSHomeViewController

- (IBAction)actionOfLeftItem:(id)sender {
    MMDrawerController *drawerController = self.mm_drawerController;
    if (drawerController.openSide == MMDrawerSideNone) {
        [drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            
        }];
    }
}

- (IBAction)messageAction:(id)sender {
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

- (void)requestLocalMeeting {
   PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    //[[PSLoadingView sharedInstance] show];
    @weakify(self)
    [homeViewModel requestLocalMeetingDetailCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code==-100) {
            [PSTipsView showTips:@"该监狱未开通网上预约功能"];
        }
        else{
        PSLocalMeetingViewController *meetingViewController = [[PSLocalMeetingViewController alloc] initWithViewModel:[PSLocalMeetingViewModel new]];
            [self.navigationController pushViewController:meetingViewController animated:YES];
        }
    } failed:^(NSError *error) {
        [self showNetError:error isShowTokenError:NO];
    }];
}

- (void)selectHallFunctionAtIndex:(NSInteger)index {
    NSString*prison_introduction=NSLocalizedString(@"prison_introduction", nil);
    NSString*prison_opening=NSLocalizedString(@"prison_opening", nil);
    NSString*work_dynamic=NSLocalizedString(@"work_dynamic", nil);
    NSString*laws_regulations=NSLocalizedString(@"laws_regulations", nil);
    NSString*family_server=NSLocalizedString(@"family_server", nil);
    NSString*local_meetting=NSLocalizedString(@"local_meetting", nil);
    NSString*e_mall=NSLocalizedString(@"e_mall", nil);
    NSString*complain_advice=NSLocalizedString(@"complain_advice", nil);
    //NSString*more_server=NSLocalizedString(@"more_server", nil);
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    if (index >= 0 && index < homeViewModel.functions.count) {
        PSHallFunction *function = homeViewModel.functions[index];
        if ([function.itemName isEqualToString:@"语音盒子"]) {
            [PSTipsView showTips:@"该监狱暂未开通此功能"];
        }else if ([function.itemName isEqualToString:local_meetting]) {
            [self requestLocalMeeting];
        }else if ([function.itemName isEqualToString:e_mall]) {
//                XXEmallViewController*commerceViewController=[[XXEmallViewController alloc]init];
//                [self.navigationController pushViewController:commerceViewController animated:YES];
            XXEmallViewController*commerceViewController=[[XXEmallViewController alloc]init];
            [self.navigationController pushViewController:commerceViewController animated:YES];

        }else if ([function.itemName isEqualToString:family_server]) {
            PSFamilyServiceViewController *serviceViewController = [[PSFamilyServiceViewController alloc] initWithViewModel:[PSFamilyServiceViewModel new]];
            [self.navigationController pushViewController:serviceViewController animated:YES];
        }else if ([function.itemName isEqualToString:prison_introduction]) {
             PSPrisonIntroduceViewController *prisonViewController = [[PSPrisonIntroduceViewController alloc] init];
            [self.navigationController pushViewController:prisonViewController animated:YES];
        }else if ([function.itemName isEqualToString:work_dynamic]) {
            PSWorkViewModel *viewModel = [PSWorkViewModel new];
            viewModel.newsType = PSNewsWorkDynamic;
            PSDynamicViewController *dynamicViewController = [[PSDynamicViewController alloc] initWithViewModel:viewModel];
            [self.navigationController pushViewController:dynamicViewController animated:YES];
        }else if ([function.itemName isEqualToString:laws_regulations]) {
            PSLawViewController *lawViewController = [[PSLawViewController alloc] init];
            [self.navigationController pushViewController:lawViewController animated:YES];
        }else if ([function.itemName isEqualToString:prison_opening]) {
            PSWorkViewModel *viewModel = [PSWorkViewModel new];
            viewModel.newsType = PSNewsPrisonPublic;
            PSPublicViewController *publicViewController = [[PSPublicViewController alloc] initWithViewModel:viewModel];
            [self.navigationController pushViewController:publicViewController animated:YES];
        }else if ([function.itemName isEqualToString:complain_advice]) {
            PSWorkViewModel *viewModel = [PSWorkViewModel new];
            viewModel.newsType = PSNewsPublicShow;
            PSComplaintSuggestionViewController *compaintSuggestionViewController = [[PSComplaintSuggestionViewController alloc] initWithViewModel:viewModel];
            [self.navigationController pushViewController:compaintSuggestionViewController animated:YES];
        }else if ([function.itemName isEqualToString:@"更多服务"]) {
        }
    }
}

#pragma mark - 顶部罪犯数据管理
- (void)appointmentPrisoner {
    PSAppointmentViewController *appointmentViewController = [[PSAppointmentViewController alloc] initWithViewModel:[PSAppointmentViewModel new]];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}

- (NSString *)nameOfPrisoner {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    NSInteger index = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = nil;
    
    if (index >= 0 && index < homeViewModel.passedPrisonerDetails.count) {
      prisonerDetail = homeViewModel.passedPrisonerDetails[index];
    }
    return prisonerDetail ? prisonerDetail.name : @"";
    return @"";
}
- (void)updateContent {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    NSInteger selectedIndex = homeViewModel.selectedPrisonerIndex;
    PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails.count > selectedIndex ? homeViewModel.passedPrisonerDetails[selectedIndex] : nil;
    self.title = prisonerDetail.jailName;
    [self.homeCollectionView reloadData];
    [self.homeCollectionView.mj_header endRefreshing];
}
- (void)managePrisoner {
    PSPrisonerManageViewController *manageViewController = [[PSPrisonerManageViewController alloc] initWithViewModel:self.viewModel];
    [manageViewController setDidManaged:^{
        [self updateContent];
    }];
    [self.navigationController pushViewController:manageViewController animated:YES];
}
#pragma mark - 中间预约数据处理
- (NSInteger)meetingRows {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    NSInteger count = homeViewModel.meetings.count;
    return count >= 2 ? count : 2;
}

- (NSString *)meetingDayAtIndex:(NSInteger)index {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    NSString *timeString = nil;
    if (index >= 0 && index < homeViewModel.meetings.count) {
        PSMeeting *meeting = homeViewModel.meetings[index];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat:@"MM月dd日 H:mm"];
        [formatter setDateFormat:@"MM-dd H:mm"];
        timeString = [formatter stringFromDate:meeting.meetingDate];
    }
     NSString*Noreservation=NSLocalizedString(@"No reservation", @"暂无预约");
    return timeString ? timeString : Noreservation;
}

- (NSTimeInterval)latestMeetingLeftTime {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    PSMeeting *latestMeeting = homeViewModel.latestMeeting;
    NSTimeInterval interval = 0;
    if (latestMeeting) {
        interval = [latestMeeting.meetingDate timeIntervalSinceDate:[NSDate date]];
    }
    return interval;
}

- (NSAttributedString *)leftDaysWithDays:(NSInteger)days {
    NSMutableAttributedString *daysString = [NSMutableAttributedString new];
    [daysString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)days] attributes:@{NSFontAttributeName:FontOfSize(60),NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    [daysString appendAttributedString:[[NSAttributedString alloc] initWithString:@"天" attributes:@{NSFontAttributeName:FontOfSize(10),NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    return daysString;
}

- (void)renderContents {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    PSPrisonerDetail *prisonerDetail = homeViewModel.passedPrisonerDetails.count > 0 ? homeViewModel.passedPrisonerDetails[0] : nil;
    self.title = prisonerDetail.jailName;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    self.homeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.homeCollectionView.backgroundColor = [UIColor whiteColor];
    self.homeCollectionView.dataSource = self;
    self.homeCollectionView.delegate = self;
    [self.homeCollectionView registerClass:[PSAppointmentInfoCell class] forCellWithReuseIdentifier:@"PSAppointmentInfoCell"];
    [self.homeCollectionView registerClass:[PSPrisonerCell class] forCellWithReuseIdentifier:@"PSPrisonerCell"];
    [self.homeCollectionView registerClass:[PSHomeHallSectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PSHomeHallSectionView"];
    [self.homeCollectionView registerClass:[PSHallFunctionCell class] forCellWithReuseIdentifier:@"PSHallFunctionCell"];
    @weakify(self)
    self.homeCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.view addSubview:self.homeCollectionView];
    [self.homeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}
-(void)renderRightBarButtonItem{
    UIButton *rButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rButton.exclusiveTouch = YES;
    CGSize defaultSize = CGSizeMake(40, 44);
    UIImage*nImage=[UIImage imageNamed:@"homeMessageIcon"];
    if (nImage.size.width > defaultSize.width) {
        defaultSize.width = nImage.size.width;
    }
    rButton.frame = CGRectMake(0, 0, defaultSize.width, defaultSize.height);
    rButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rButton setImage:nImage forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.dotLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 6, 6, 6)];
    self.dotLable.backgroundColor = [UIColor redColor];
    self.dotLable.layer.cornerRadius = 3;
    self.dotLable.clipsToBounds = YES;
    self.dotLable.hidden=YES;
    UIView*customView=[[UIView alloc]init];
    customView.frame=CGRectMake(0, 0, 48, 40);
    [customView addSubview:rButton];
    [customView addSubview:self.dotLable];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.rightBarButtonItem=barItem;
    
    self.session = [PSCache queryCache:AppUserSessionCacheKey];
    NSString *dot = self.session.families.isNoticed;
    if ([dot isEqualToString:@"0"]) {
        self.dotLable.hidden = NO;
    }
}
-(void)showDot{
    self.dotLable.hidden = NO;
}

- (void)refreshData {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    @weakify(self)
    [homeViewModel requestHomeDataCompleted:^(id data) {
        @strongify(self)
        [self updateContent];
    }];
}

- (UIImage *)leftItemImage {
    return [UIImage imageNamed:@"homeDrawerIcon"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDot) name:AppDotChange object:nil];
        PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
        [[PSLoadingView sharedInstance] show];
        @weakify(self)
        [homeViewModel requestHomeDataCompleted:^(id data) {
            @strongify(self)
            [[PSLoadingView sharedInstance] dismiss];
            [self renderContents];
            [self renderRightBarButtonItem];
            
            //[self VersonUpdate];
        }];
}


#pragma mark -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return section == 2 ? CGSizeMake(SCREEN_WIDTH, 60) : CGSizeZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    return section == 2 ? homeViewModel.functions.count : 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;
    if (indexPath.section == 0) {
        itemSize = CGSizeMake(SCREEN_WIDTH, 135);
    }else if (indexPath.section == 1) {
        itemSize = CGSizeMake(SCREEN_WIDTH, 160);
    }else{
        CGFloat width = (SCREEN_WIDTH - 2 * 15) / 3;
        itemSize = CGSizeMake(width, width);
    }
    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (section == 2) {
        inset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    return inset;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"PSHomeHallSectionView" forIndexPath:indexPath];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSPrisonerCell" forIndexPath:indexPath];
        PSPrisonerCell *prisonerCell = (PSPrisonerCell *)cell;
        @weakify(self)
        [prisonerCell.appointmentButton bk_whenTapped:^{
            @strongify(self)
            [self appointmentPrisoner];
        }];
        [prisonerCell.operationView bk_whenTapped:^{
            @strongify(self)
            [self managePrisoner];
        }];
        prisonerCell.prisonerLabel.text = [self nameOfPrisoner];
    }else if (indexPath.section == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSAppointmentInfoCell" forIndexPath:indexPath];
        PSAppointmentInfoCell *infoCell = (PSAppointmentInfoCell *)cell;
        @weakify(self)
        [infoCell.appointmentView setListRows:^NSInteger{
            @strongify(self)
            return [self meetingRows];
        }];
        [infoCell.appointmentView setListRowText:^NSString *(NSInteger index) {
            @strongify(self)
            return [self meetingDayAtIndex:index];
        }];
        PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
        [infoCell.appointmentView updateTimeLeft:[self latestMeetingLeftTime] haveMeeting:homeViewModel.latestMeeting != nil];
        if (self.homeCollectionView.mj_header.isRefreshing) {
            [infoCell.appointmentView reloadData];
        }
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSHallFunctionCell" forIndexPath:indexPath];
        PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
        PSHallFunction *function = homeViewModel.functions[indexPath.row];
        ((PSHallFunctionCell *)cell).functionImageView.image = [UIImage imageNamed:function.itemIconName];
        ((PSHallFunctionCell *)cell).functionNameLabel.text = function.itemName;
        NSInteger lines = (NSInteger)ceil(homeViewModel.functions.count / 3.0);
        if (indexPath.row / 3 + 1 ==  lines) {
            //最后排
            if ((indexPath.row + 1) % 3 == 0) {
                ((PSHallFunctionCell *)cell).itemPosition = PSPositionLastRowRight;
            }else{
                ((PSHallFunctionCell *)cell).itemPosition = PSPositionLastRowOther;
            }
        }else{
            if ((indexPath.row + 1) % 3 == 0) {
                ((PSHallFunctionCell *)cell).itemPosition = PSPositionRowRight;
            }else{
                ((PSHallFunctionCell *)cell).itemPosition = PSPositionOther;
            }
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self selectHallFunctionAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    self.localCode=nil;
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
