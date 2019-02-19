//
//  PSVistorHomeViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/14.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "UIViewController+MMDrawerController.h"
#import "PSVistorHomeViewController.h"
#import "PSHomeViewModel.h"
#import "PSAppointmentInfoCell.h"
#import "PSHomeHallSectionView.h"
#import "PSHallFunctionCell.h"
#import "PSPrisonerCell.h"
#import "PSBusinessConstants.h"
#import "PSAlertView.h"
#import "PSPrisonIntroduceViewController.h"
#import "PSWorkViewModel.h"
#import "PSDynamicViewController.h"
#import "PSLawViewController.h"
#import "PSPublicViewController.h"
#import "PSRegisterViewModel.h"
#import "PSVistorLawViewController.h"
#import "PSSessionManager.h"
#import "PSRegisterViewController.h"
#import "PSSessionNoneViewController.h"
#import "PSDemoPrisonIntoduceViewController.h"
#import "PSPrisonContentViewController.h"
#import "PSVisitorViewController.h"
@interface PSVistorHomeViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *homeCollectionView;
@property(nonatomic ,strong) UILabel *dotLable;
@property (nonatomic , strong) UIButton *titleButton ;

@end

@implementation PSVistorHomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    [self renderContents];
    [self renderRightBarButtonItem];
    
    // Do any additional setup after loading the view.
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
    [rButton addTarget:self action:@selector(vistorAction) forControlEvents:UIControlEventTouchUpInside];
    
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
    
   
}

- (UIImage *)leftItemImage {
    return [UIImage imageNamed:@"homeDrawerIcon"];
}



- (void)navigationOnClickListener {

    [self.navigationController pushViewController:[[PSVisitorViewController alloc]initWithViewModel:[[PSRegisterViewModel alloc] init]] animated:YES];
}



- (void)renderContents {
    //self.title =[LXFileManager readUserDataForKey:@"vistorTitle"];
    NSString *titleSting=[NSString stringWithFormat:@"%@ ▼",[LXFileManager readUserDataForKey:@"vistorTitle"]];
    _titleButton  =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_titleButton setTitle:titleSting forState:UIControlStateNormal];
    _titleButton.titleLabel.font=FontOfSize(18);
    [_titleButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    [_titleButton sizeToFit];
    

    

    
    //添加事件
    [_titleButton addTarget:self action:@selector(navigationOnClickListener) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleButton;
    
    
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

    [self.view addSubview:self.homeCollectionView];
    [self.homeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
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
    PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
    if (index >= 0 && index < homeViewModel.functions.count) {
        PSHallFunction *function = homeViewModel.functions[index];
        if ([function.itemName isEqualToString:@"语音盒子"]) {
            [PSTipsView showTips:@"该监狱暂未开通此功能"];
        }else if ([function.itemName isEqualToString:local_meetting]) {
            [self vistorAction];
        }else if ([function.itemName isEqualToString:e_mall]) {
             [self vistorAction];
        }else if ([function.itemName isEqualToString:family_server]) {
             [self vistorAction];
        }else if ([function.itemName isEqualToString:prison_introduction]) {
            PSDemoPrisonIntoduceViewController *prisonViewController = [[PSDemoPrisonIntoduceViewController alloc] init];
            [self.navigationController pushViewController:prisonViewController animated:YES];
            
        }else if ([function.itemName isEqualToString:work_dynamic]) {
            PSWorkViewModel *viewModel = [PSWorkViewModel new];
            viewModel.newsType = PSNewsWorkDynamic;
            PSDynamicViewController *dynamicViewController = [[PSDynamicViewController alloc] initWithViewModel:viewModel];
            [self.navigationController pushViewController:dynamicViewController animated:YES];
        }else if ([function.itemName isEqualToString:laws_regulations]) {
//            PSVistorLawViewController *lawViewController = [[PSVistorLawViewController alloc] init];
//            [self.navigationController pushViewController:lawViewController animated:YES];
            [self vistorAction];
        }else if ([function.itemName isEqualToString:prison_opening]) {
            PSWorkViewModel *viewModel = [PSWorkViewModel new];
            viewModel.newsType = PSNewsPrisonPublic;
            PSPublicViewController *publicViewController = [[PSPublicViewController alloc] initWithViewModel:viewModel];
            [self.navigationController pushViewController:publicViewController animated:YES];
        }else if ([function.itemName isEqualToString:complain_advice]) {
            [self vistorAction];
        }else if ([function.itemName isEqualToString:@"更多服务"]) {
            
        }
    }
}
- (IBAction)actionOfLeftItem:(id)sender {

    [self vistorAction];

}

-(void)vistorAction{
    [[PSSessionManager sharedInstance]doLogout];
}

-(void)actionForRegister{
    PSRegisterViewController *registerViewController = [[PSRegisterViewController alloc] initWithViewModel:[[PSRegisterViewModel alloc] init]];
    [registerViewController setCallback:^(BOOL successful, id session) {
        if (self.callback) {
            self.callback(successful,session);
        }
    }];
    [self.navigationController pushViewController:registerViewController animated:YES];
  
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [prisonerCell.appointmentButton bk_whenTapped:^{
            [self vistorAction];
           
        }];
        [prisonerCell.operationView bk_whenTapped:^{
            [self vistorAction];
          
        }];
       
    }else if (indexPath.section == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSAppointmentInfoCell" forIndexPath:indexPath];
        PSAppointmentInfoCell *infoCell = (PSAppointmentInfoCell *)cell;
       
        [infoCell.appointmentView setListRows:^NSInteger{

            return 2;

        }];
        [infoCell.appointmentView setListRowText:^NSString *(NSInteger index) {

            NSString*Noreservation=NSLocalizedString(@"No reservation", @"暂无预约");
            return Noreservation;
        }];
        
    }else if (indexPath.section == 2){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSHallFunctionCell" forIndexPath:indexPath];
        PSHomeViewModel *homeViewModel = (PSHomeViewModel *)self.viewModel;
        PSHallFunction *function = homeViewModel.functions[indexPath.row];
        ((PSHallFunctionCell *)cell).functionImageView.image = [UIImage imageNamed:function.itemIconName];
        ((PSHallFunctionCell *)cell).functionNameLabel.text = function.itemName;
        NSInteger lines = (NSInteger)ceil(self.functions.count / 3.0);
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initialize {
    
}



@end
