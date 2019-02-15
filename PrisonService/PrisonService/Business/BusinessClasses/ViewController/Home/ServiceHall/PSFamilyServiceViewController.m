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
#import "PSSessionManager.h"
#import "PSPrisonerDetail.h"
#import "MeetJails.h"
#import "PSBusinessConstants.h"
#import "PSBindPrisonerViewController.h"
#import "PSPrisonerDetailRequest.h"


@interface PSFamilyServiceViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *serviceCollectionView;
@property (nonatomic, strong) NSMutableArray *detailRequests;
@property (nonatomic, strong) NSMutableArray *details;


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
    [self getData];
    [self renderContents];
}



- (void)getData {
    
    PSFamilyServiceViewModel *serviceViewModel = (PSFamilyServiceViewModel *)self.viewModel;
    
    [[PSLoadingView sharedInstance] show];
    PSMeetJailsnnmeViewModel *model = [[PSMeetJailsnnmeViewModel alloc] init];
    @weakify(self);
    [model requestMeetAllJailsterCompleted:^(PSResponse *response) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
            //把绑定的罪犯放到最前面
            if (model.prisons.count > 1) {
                [model.prisons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MeetPrisonserModel *meetJails = obj;
                    if ([meetJails.prisonerId isEqualToString:serviceViewModel.prisonerDetail.prisonerId]) {
                        [self.prisons insertObject:meetJails atIndex:0];
                    } else {
                        [self.prisons addObject:obj];
                    }
                }];
            } else {
                self.prisons = model.prisons;
            }
            
            //有新绑定的罪犯-----重新刷新用户绑定的罪犯详细信息
            if (self.prisons.count > [PSSessionManager sharedInstance].passedPrisonerDetails.count) {
                [self reloadBingPrisonserDetails:self.prisons];
            } else {
                [self.serviceCollectionView reloadData];
            }
        });
    } failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PSLoadingView sharedInstance] dismiss];
        });
    }];
    
}
//当前绑定的所有犯人
- (void)reloadBingPrisonserDetails:(NSArray *)prisonsers {
    
    [self.detailRequests removeAllObjects];
    [self.details removeAllObjects];
    
    for (MeetPrisonserModel *registration in prisonsers) {
        PSPrisonerDetailRequest *detailRequest = [PSPrisonerDetailRequest new];
        detailRequest.prisonerId = registration.prisonerId;
        @weakify(self)
        @weakify(detailRequest)
        [detailRequest send:^(PSRequest *request, PSResponse *response) {
            @strongify(self)
            @strongify(detailRequest)
            PSPrisonerDetailResponse *detailResponse = (PSPrisonerDetailResponse *)response;
            if (detailResponse.code == 200) {
                if (detailResponse.prisonerDetail) {
                    [self.details addObject:detailResponse.prisonerDetail];
                }
            }
            [self.detailRequests removeObject:detailRequest];
            if (self.detailRequests.count == 0) {
//                self.passedPrisonerDetails = self.details;
            }
        } errorCallback:^(PSRequest *request, NSError *error) {
            @strongify(self)
            [self.detailRequests removeObject:detailRequest];
            if (self.detailRequests.count == 0) {
//                self.passedPrisonerDetails = self.details;
            }
        }];
        [self.detailRequests addObject:detailRequest];
        //最后一个 刷新
        if ([registration isEqual:prisonsers[prisonsers.count-1]]) {
            PSFamilyServiceViewModel *serviceViewModel = (PSFamilyServiceViewModel *)self.viewModel;
            [PSSessionManager sharedInstance].passedPrisonerDetails = self.details;
            [self.details enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PSPrisonerDetail *meetJails = obj;
                if ([meetJails.prisonerId isEqualToString:serviceViewModel.prisonerDetail.prisonerId]) {
                    [PSSessionManager sharedInstance].selectedPrisonerIndex = idx;
                    *stop = YES;
                }
            }];
            [self.serviceCollectionView reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  self.prisons.count>0?4:3;
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
        NSInteger height = self.prisons.count>0?(self.prisons.count+1)*40+30:0;
        itemSIze = CGSizeMake(SCREEN_WIDTH,height);
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
        infoView.prisonerName = serviceViewModel.prisonerDetail.name;
        
        [infoView setInfoRows:^NSInteger{
            return serviceViewModel.newfamilyServiceItems.count;
        }];
        [infoView setIconNameOfRow:^NSString *(NSInteger index) {
            if (index >= 0 && index < serviceViewModel.familyServiceItems.count) {
                PSFamilyServiceItem *serviceItem = serviceViewModel.newfamilyServiceItems[index];
                return serviceItem.itemIconName;
            }
            return nil;
        }];
        [infoView setTitleTextOfRow:^NSString *(NSInteger index) {
            if (index >= 0 && index < serviceViewModel.familyServiceItems.count) {
                PSFamilyServiceItem *serviceItem = serviceViewModel.newfamilyServiceItems[index];
                return serviceItem.itemName;
            }
            return nil;
        }];
        [infoView setDetailTextOfRow:^NSString *(NSInteger index) {
            if (index >= 0 && index < serviceViewModel.newfamilyServiceItems.count) {
                PSFamilyServiceItem *serviceItem = serviceViewModel.newfamilyServiceItems[index];
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
        
       PSServicePrisonsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSServicePrisonsCell" forIndexPath:indexPath];
        cell.Prisons = self.prisons;
        //切换服刑人员
        @weakify(self);
        if (self.prisons.count>1) {
            cell.changeBlock = ^(MeetPrisonserModel *meetjails) {
                @strongify(self);
                [self changePrison:meetjails];
            };
        }
        //绑定服刑人员
        cell.bingBlock = ^{
            @strongify(self);
            [self bingdingPrison];
            //直接埋点....
            [SDTrackTool logEvent:CLICK_GO_BIND_PRISONER];
            
        };
    
      return cell;
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self periodChange];
    }else if (indexPath.section == 2) {
        //[self honorOfYear];
        NSString*coming_soon=NSLocalizedString(@"coming_soon", @"敬请期待");
        [PSTipsView showTips:coming_soon];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changePrison:(MeetPrisonserModel *)meetJails{
    NSArray *PrisonerDetails  = [PSSessionManager sharedInstance].passedPrisonerDetails;
    [PrisonerDetails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PSPrisonerDetail *prisonerDetail = obj;
        if ([prisonerDetail.prisonerId isEqualToString:meetJails.prisonerId]) {
            [PSSessionManager sharedInstance].selectedPrisonerIndex = idx;
            PSFamilyServiceViewModel *serviceViewModel = (PSFamilyServiceViewModel *)self.viewModel;
            serviceViewModel.prisonerDetail = (idx >= 0 && idx < PrisonerDetails.count) ? PrisonerDetails[idx] : nil;
            [self.serviceCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            if (self.didManaged) {
                self.didManaged();
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:JailChange object:nil];
            
            *stop = YES;
        }
    }];
}


-(void)bingdingPrison {
    PSBindPrisonerViewController *bindViewController = [[PSBindPrisonerViewController alloc] initWithViewModel:[[PSBindPrisonerViewModel alloc] init]];
    [self.navigationController pushViewController:bindViewController animated:YES];
}

#pragma mark - Setting*Getting
- (NSMutableArray *)prisons {
    if (!_prisons) {
        _prisons = [NSMutableArray array];
    }
    return _prisons;
}

- (NSMutableArray *)detailRequests {
    if (!_detailRequests) {
        _detailRequests = [NSMutableArray array];
    }
    return _detailRequests;
}
- (NSMutableArray *)details {
    if (!_details) {
        _details = [NSMutableArray array];
    }
    return _details;
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
