//
//  PSVistorHomeViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/6/14.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "UIViewController+MMDrawerController.h"
#import "PSAuthenticationHomeViewController.h"
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
#import "XXEmallViewController.h"
#import "PSDemoPrisonIntoduceViewController.h"
@interface PSAuthenticationHomeViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *homeCollectionView;
@property(nonatomic ,strong) UILabel *dotLable;

@end

@implementation PSAuthenticationHomeViewController




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
- (void)renderContents {
    
    self.title =@"首页";
    //[LXFileManager readUserDataForKey:@"vistorTitle"];
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
            //[PSTipsView showTips:@"该监狱暂未开通此功能"];
            [self vistorAction];
        }else if ([function.itemName isEqualToString:local_meetting]) {
            [self vistorAction];
        }else if ([function.itemName isEqualToString:e_mall]) {
            XXEmallViewController*commerceViewController=[[XXEmallViewController alloc]init];
            [self.navigationController pushViewController:commerceViewController animated:YES];
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
    MMDrawerController *drawerController = self.mm_drawerController;
    if (drawerController.openSide == MMDrawerSideNone) {
        [drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }else{
        [drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            
        }];
    }
    
}

-(void)vistorAction{
    [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]init] animated:YES];

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



- (void)initialize {
    
}



@end
