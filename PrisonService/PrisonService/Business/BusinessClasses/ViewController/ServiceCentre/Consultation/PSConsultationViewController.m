//
//  PSConsultationViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSConsultationViewController.h"
#import "PSServiceLinkView.h"
#import "PSConsultationTableViewCell.h"
#import "PSConsultationOtherTableViewCell.h"
#import "PSConsultationViewModel.h"
#import "PSConsultingCategoryViewController.h"
#import "PSConsultationViewModel.h"
#import <AFNetworking/AFNetworking.h>
@interface PSConsultationViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextViewDelegate>
@property (nonatomic, strong) UICollectionView *serviceCollectionView;
@property (nonatomic , strong) NSMutableArray *selectArray;
@property (nonatomic , strong) NSMutableArray *images;

@end

@implementation PSConsultationViewController

#pragma mark  - life cycle
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"我要咨询";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    _images=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}
#pragma mark  - notification

#pragma mark  - action
- (void)handlePickerImage:(UIImage *)image {
    @weakify(self)
    PSConsultationViewModel *viewModel=(PSConsultationViewModel *)self.viewModel;
    viewModel.consultaionImage=image;
    [viewModel uploadConsultationImagesCompleted:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
           NSString*base64=[self image2DataURL:image];
            NSDictionary*dict=@{@"fileId":tips,
                                @"thumb":base64
                                };
            [self.images addObject:dict];
            viewModel.attachments=self.images;
        }
    }];

}



-(void)checkDataIsEmpty{
    PSConsultationViewModel *viewModel=(PSConsultationViewModel *)self.viewModel;
     @weakify(self)
    viewModel.categories=self.selectArray;
    [viewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
       @strongify(self)
        if (successful) {
            [self Submit_LegalAdvice];
        } else {
             [PSTipsView showTips:tips];
        }
    }];
}

-(void)Submit_LegalAdvice{
    PSConsultationViewModel *viewModel=(PSConsultationViewModel *)self.viewModel;
    //@weakify(self)
    [viewModel requestAddConsultationCompleted:^(PSResponse *response) {
    } failed:^(NSError *error) {
    }];
}

#pragma mark  - UITableViewDelegate
#pragma mark -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSIze = CGSizeZero;
    if (indexPath.section == 0) {
        itemSIze = CGSizeMake(SCREEN_WIDTH, 310);
    }else{
        itemSIze = CGSizeMake(SCREEN_WIDTH, 160);
    }
    return itemSIze;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize sectionSize = CGSizeZero;
    if (section != 0) {
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
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSConsultationTableViewCell" forIndexPath:indexPath];
        //咨询类型选择
        [((PSConsultationTableViewCell *)cell).choseButton bk_whenTapped:^{
            self.selectArray=nil;
       PSConsultingCategoryViewController*consultingCategoryViewController=[[PSConsultingCategoryViewController alloc]initWithViewModel:self.viewModel];
            consultingCategoryViewController.returnValueBlock = ^(NSArray *arrayValue) {
                [self bulidSelectArray:arrayValue];
                NSString*cateoryString=[arrayValue componentsJoinedByString:@"、"];
                [((PSConsultationTableViewCell *)cell).choseButton setTitle:cateoryString forState:0];
            };
            [self.navigationController pushViewController:consultingCategoryViewController animated:YES];
        }];
        //相册相机回调
        [((PSConsultationTableViewCell *)cell).pickerV observeSelectedMediaArray:^(NSArray<LLImagePickerModel *> *list) {
            for (int i=0; i<list.count; i++) {
                LLImagePickerModel*model=[list objectAtIndex:i];
                [self handlePickerImage:model.image];
            }
        }];
        
        ((PSConsultationTableViewCell *)cell).contentTextView.delegate=self;

     
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PSConsultationOtherTableViewCell" forIndexPath:indexPath];
        [((PSConsultationOtherTableViewCell*)cell).moneyTextField setBk_didEndEditingBlock:^(UITextField *TextField) {
            PSConsultationViewModel *viewModel=(PSConsultationViewModel *)self.viewModel;
            viewModel.reward=[TextField.text intValue];
          
        }];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
       
    }else if (indexPath.section == 2) {
        //[self honorOfYear];
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView {
   PSConsultationViewModel *viewModel=(PSConsultationViewModel *)self.viewModel;
    viewModel.describe = textView.text;
}

#pragma mark  - UI
-(void)renderContents{
    self.view.backgroundColor = AppBaseBackgroundColor2;
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    self.serviceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
    self.serviceCollectionView.backgroundColor = [UIColor clearColor];
    self.serviceCollectionView.dataSource = self;
    self.serviceCollectionView.delegate = self;
    [self.serviceCollectionView registerClass:[PSConsultationTableViewCell class] forCellWithReuseIdentifier:@"PSConsultationTableViewCell"];
    [self.serviceCollectionView registerClass:[PSConsultationOtherTableViewCell class] forCellWithReuseIdentifier:@"PSConsultationOtherTableViewCell"];
    [self.serviceCollectionView registerClass:[PSServiceLinkView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PSServiceLinkView"];
    [self.view addSubview:self.serviceCollectionView];
    [self.serviceCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.serviceCollectionView.alwaysBounceVertical=YES;
    
    
    UIButton*releaseButton=[[UIButton alloc]initWithFrame:CGRectMake(15, SCREEN_HEIGHT-110, SCREEN_WIDTH-30, 44)];
    [releaseButton setBackgroundImage:[UIImage imageNamed:@"提交按钮底框"] forState:0];
    [releaseButton setTitle:@"发布" forState:0];
    releaseButton.titleLabel.font=AppBaseTextFont3;
    [self.serviceCollectionView addSubview:releaseButton];
    [releaseButton bk_whenTapped:^{
        [self checkDataIsEmpty];
    }];
    
}
#pragma mark  - setter & getter
-(void)bulidSelectArray:(NSArray*)array{
        _selectArray=[[NSMutableArray alloc]init];
    for (int i=0; i<array.count; i++) {
        NSString*categorySting=array[i];
        if ([categorySting isEqualToString:@"财产纠纷"]) {
            [self.selectArray addObject:@"PROPERTY_DISPUTES"];
        }
        else if ([categorySting isEqualToString:@"婚姻家庭"]){
            [self.selectArray addObject:@"MARRIAGE_FAMILY"];
        }
        else if ([categorySting isEqualToString:@"交通事故"]){
             [self.selectArray addObject:@"TRAFFIC_ACCIDENT"];
        }
        else if ([categorySting isEqualToString:@"工伤赔偿"]){
            [self.selectArray addObject:@"WORK_COMPENSATION"];
        }
        else if ([categorySting isEqualToString:@"合同纠纷"]){
            //array[i]=@"CONTRACT_DISPUTE";
              [self.selectArray addObject:@"CONTRACT_DISPUTE"];
        }
        else if ([categorySting isEqualToString:@"刑事辩护"]){
            [self.selectArray addObject:@"CRIMINAL_DEFENSE"];
        }
        else if ([categorySting isEqualToString:@"房产纠纷"]){
              [self.selectArray addObject:@"HOUSING_DISPUTES"];
        }
        else if ([categorySting isEqualToString:@"劳动就业"]){
           [self.selectArray addObject:@"LABOR_EMPLOYMENT"];
        }
        else{
            
        }
    }
      NSLog(@"类型分类 %@",_selectArray);
}


- (NSString *) image2DataURL: (UIImage *) image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 1.0f);
        mimeType = @"image/jpeg";
    }
    
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
    
}

- (BOOL) imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
