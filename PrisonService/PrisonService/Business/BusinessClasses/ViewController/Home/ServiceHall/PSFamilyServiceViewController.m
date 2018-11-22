//
//  PSFamilyServiceViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFamilyServiceViewController.h"
#import "PSServiceInfoCell.h"
#import "PSServiceLinkView.h"
#import "PSServiceOtherCell.h"
#import "PSPeriodChangeViewController.h"
#import "PSHonorViewController.h"
#import "PSPinmoneyViewController.h"
#import "PSPinmoneyViewModel.h"
#import "PSMeetJailsnnmeViewModel.h"
#import "PSServicePrisonsCell.h"

@interface PSFamilyServiceViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *serviceCollectionView;
@property (nonatomic, strong) UIScrollView *myScrollview;

@end

@implementation PSFamilyServiceViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*family_server=NSLocalizedString(@"family_server", @"家属服务");
        self.title = family_server;
    }
    return self;
}

- (void)periodChange {
//    PSPeriodChangeViewController *changeViewController = [[PSPeriodChangeViewController alloc] initWithViewModel:[PSPeriodChangeViewModel new]];
    PSPinmoneyViewController *changeViewController = [[PSPinmoneyViewController alloc] initWithViewModel:[[PSPinmoneyViewModel alloc]init] ];
    [self.navigationController pushViewController:changeViewController animated:YES];
}

- (void)honorOfYear {
    PSHonorViewController *honorViewController = [[PSHonorViewController alloc] initWithViewModel:[PSRewardAndPunishmentViewModel new]];
    [self.navigationController pushViewController:honorViewController animated:YES];
}

- (void)renderContents {
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    self.serviceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
    self.serviceCollectionView.backgroundColor = [UIColor clearColor];
    self.serviceCollectionView.dataSource = self;
    self.serviceCollectionView.delegate = self;
    [self.serviceCollectionView registerClass:[PSServiceInfoCell class] forCellWithReuseIdentifier:@"PSServiceInfoCell"];
    [self.serviceCollectionView registerClass:[PSServiceOtherCell class] forCellWithReuseIdentifier:@"PSServiceOtherCell"];
    [self.serviceCollectionView registerClass:[PSServicePrisonsCell class] forCellWithReuseIdentifier:@"PSServicePrisonsCell"];
    [self.serviceCollectionView registerClass:[PSServiceLinkView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PSServiceLinkView"];
    [self.view addSubview:self.serviceCollectionView];
    [self.serviceCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = AppBaseBackgroundColor2;
    [self renderContents];
    [self getData];
}

- (void)getData {
    
    [[PSLoadingView sharedInstance] show];
    PSMeetJailsnnmeViewModel *model = [[PSMeetJailsnnmeViewModel alloc] init];
    [model requestMeetJailsterCompleted:^(PSResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
            [self.serviceCollectionView reloadData];
        });
    } failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
        });
    }];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSIze = CGSizeZero;
    if (indexPath.section == 0) {
        itemSIze = CGSizeMake(SCREEN_WIDTH, 300);
    }else{
        itemSIze = CGSizeMake(SCREEN_WIDTH, 58);
    }
    if (indexPath.section == 3) {
        itemSIze = CGSizeMake(SCREEN_WIDTH,300);
    }
    return itemSIze;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize sectionSize = CGSizeZero;
    if (section != 0&&section != 3) {
        sectionSize = CGSizeMake(SCREEN_WIDTH, 5);
    }
    return sectionSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = nil;
    if (indexPath.section != 0) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"PSServiceLinkView" forIndexPath:indexPath];
    }
    return header;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSServiceInfoCell" forIndexPath:indexPath];
        PSFamilyServiceViewModel *serviceViewModel = (PSFamilyServiceViewModel *)self.viewModel;
        PSFamilyServiceInfoView *infoView = ((PSServiceInfoCell *)cell).infoView;
        infoView.prisonerLabel.text = serviceViewModel.prisonerDetail.name;
        [infoView setInfoRows:^NSInteger{
            return serviceViewModel.familyServiceItems.count;
        }];
        [infoView setIconNameOfRow:^NSString *(NSInteger index) {
            if (index >= 0 && index < serviceViewModel.familyServiceItems.count) {
                PSFamilyServiceItem *serviceItem = serviceViewModel.familyServiceItems[index];
                return serviceItem.itemIconName;
            }
            return nil;
        }];
        [infoView setTitleTextOfRow:^NSString *(NSInteger index) {
            if (index >= 0 && index < serviceViewModel.familyServiceItems.count) {
                PSFamilyServiceItem *serviceItem = serviceViewModel.familyServiceItems[index];
                return serviceItem.itemName;
            }
            return nil;
        }];
        [infoView setDetailTextOfRow:^NSString *(NSInteger index) {
            if (index >= 0 && index < serviceViewModel.familyServiceItems.count) {
                PSFamilyServiceItem *serviceItem = serviceViewModel.familyServiceItems[index];
                return serviceItem.content;
            }
            return nil;
        }];
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSServiceOtherCell" forIndexPath:indexPath];
        PSFamilyServiceViewModel *serviceViewModel = (PSFamilyServiceViewModel *)self.viewModel;
        NSInteger index = indexPath.section - 1;
        if (index >= 0 && index < serviceViewModel.otherServiceItems.count) {
            PSFamilyServiceItem *serviceItem = serviceViewModel.otherServiceItems[index];
            ((PSServiceOtherCell *)cell).iconImageView.image = [UIImage imageNamed:serviceItem.itemIconName];
            ((PSServiceOtherCell *)cell).nameLabel.text = serviceItem.itemName;
        }
    }
    if (indexPath.section == 3) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSServicePrisonsCell" forIndexPath:indexPath];
//        PSFamilyServiceViewModel *serviceViewModel = (PSFamilyServiceViewModel *)self.viewModel;
//        NSInteger index = indexPath.section - 1;
//        if (index >= 0 && index < serviceViewModel.otherServiceItems.count) {
//            PSFamilyServiceItem *serviceItem = serviceViewModel.otherServiceItems[index];
//            ((PSServiceOtherCell *)cell).iconImageView.image = [UIImage imageNamed:serviceItem.itemIconName];
//            ((PSServiceOtherCell *)cell).nameLabel.text = serviceItem.itemName;
//        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self periodChange];
    }else if (indexPath.section == 2) {
        //[self honorOfYear];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setting*Getting
- (UIScrollView *)myScrollview {
    if (!_myScrollview) {
        _myScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _myScrollview;
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
