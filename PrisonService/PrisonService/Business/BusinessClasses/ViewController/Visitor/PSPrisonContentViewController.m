//
//  PSPrisonSelectViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/4.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSPrisonContentViewController.h"
#import "XWPresentOneTransition.h"
#import "XWInteractiveTransition.h"
#import "PSPrisonSelectViewController.h"
#import "PSVisitorViewModel.h"
#import "PSProvinceDisplayViewController.h"
#import "PSCityDisplayViewController.h"
#import "PSJailDisplayViewController.h"

@interface PSPrisonContentViewController ()<UIViewControllerTransitioningDelegate,WMPageControllerDataSource,WMPageControllerDelegate>

@property (nonatomic, strong) XWInteractiveTransition *interactiveDismiss;
@property (nonatomic, strong) XWInteractiveTransition *interactivePush;
@property (nonatomic, strong) PSPrisonSelectViewController *prisonSelectViewController;
@property (nonatomic, strong) PSProvinceDisplayViewController *provinceDisplayViewController;
@property (nonatomic, strong) PSCityDisplayViewController *cityDisplayViewController;
@property (nonatomic, strong) PSJailDisplayViewController *jailDisplayViewController;
@property (nonatomic, assign) NSInteger numberOfPages;

@end

@implementation PSPrisonContentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Event
- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestData {
    PSVisitorViewModel *viewModel = (PSVisitorViewModel *)self.viewModel;
    @weakify(self)
    [viewModel requestProvincesWithCompletion:^(id data) {
        @strongify(self)
        [self.prisonSelectViewController reloadData];
    } failed:^(NSError *error) {
        
    }];
}

- (void)selectProvinceAtIndex:(NSInteger)index {
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    if (index >= 0 && index < visitorViewModel.provices.count) {
        visitorViewModel.provinceSelectIndex = index;
        [self.prisonSelectViewController reloadData];
        @weakify(self)
        [visitorViewModel requestCitysOfSelectProvinceWithCompletion:^(id data) {
            @strongify(self)
            self.cityDisplayViewController = nil;
            self.jailDisplayViewController = nil;
            [self.prisonSelectViewController reloadData];
            if (visitorViewModel.currentCitys.count > 0) {
                self.prisonSelectViewController.selectIndex = 1;
            }
        } failed:^(NSError *error) {
            @strongify(self)
            [self.prisonSelectViewController reloadData];
        }];
    }
}

- (void)selectCityAtIndex:(NSInteger)index {
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    if (index >= 0 && index < visitorViewModel.currentCitys.count) {
        visitorViewModel.citySelectIndex = index;
        [self.prisonSelectViewController reloadData];
        @weakify(self)
        [visitorViewModel requestJailsOfSelectCityWithCompletion:^(id data) {
            @strongify(self)
            self.jailDisplayViewController = nil;
            [self.prisonSelectViewController reloadData];
            if (visitorViewModel.currentJails.count > 0) {
                self.prisonSelectViewController.selectIndex = 2;
            }
        } failed:^(NSError *error) {
            @strongify(self)
            [self.prisonSelectViewController reloadData];
        }];
    }
}

- (void)selectJailAtIndex:(NSInteger)index {
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    if (index >= 0 && index < visitorViewModel.currentJails.count) {
        visitorViewModel.jailSelectIndex = index;
        [self.prisonSelectViewController reloadData];
        if (self.selectedJailCallback) {
            self.selectedJailCallback();
        }
        [self closeAction:nil];
    }
}


#pragma mark - UI
- (void)renderContents {
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = AppBaseTextFont1;
    titleLabel.textColor = AppBaseTextColor1;
    NSString*please_choose=NSLocalizedString(@"please_choose", @"请选择");
    titleLabel.text = please_choose;
    [titleLabel sizeToFit];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(titleLabel.frame.size);
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    NSString*close=NSLocalizedString(@"close", @"关闭");
    [closeButton setTitle:close forState:UIControlStateNormal];
    closeButton.titleLabel.font = AppBaseTextFont1;
    [closeButton setTitleColor:AppBaseTextColor1 forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    self.prisonSelectViewController = [[PSPrisonSelectViewController alloc] init];
    self.prisonSelectViewController.dataSource = self;
    self.prisonSelectViewController.delegate = self;
    [self.view addSubview:self.prisonSelectViewController.view];
    [self.prisonSelectViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(closeButton.mas_bottom).offset(10);
        make.left.bottom.right.mas_equalTo(0);
    }];
    if (self.numberOfPages >= 1) {
        self.prisonSelectViewController.selectIndex = (int)self.numberOfPages - 1;
    }
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self renderContents];
    self.interactivePush = [XWInteractiveTransition interactiveTransitionWithTransitionType:XWInteractiveTransitionTypePresent GestureDirection:XWInteractiveTransitionGestureDirectionUp];
    self.interactiveDismiss = [XWInteractiveTransition interactiveTransitionWithTransitionType:XWInteractiveTransitionTypeDismiss GestureDirection:XWInteractiveTransitionGestureDirectionDown];
    [self requestData];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    NSInteger pages = 0;
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    if (visitorViewModel.provices.count > 0) {
        pages += 1;
    }
    if (visitorViewModel.currentCitys.count > 0) {
        pages += 1;
    }
    if (visitorViewModel.currentJails.count > 0) {
        pages += 1;
    }
    self.numberOfPages = pages;
    return pages;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    NSString *title = nil;
    PSVisitorViewModel *visitorViewModel = (PSVisitorViewModel *)self.viewModel;
    NSString*please_choose=NSLocalizedString(@"please_choose", @"请选择");
    switch (index) {
        case 0:
        {
            PSProvince *selectedProvince = visitorViewModel.selectedProvince;
            title = selectedProvince ? selectedProvince.name : please_choose;
        }
            break;
         case 1:
        {
            PSCity *selectedCity = visitorViewModel.selectedCity;
            title = selectedCity ? selectedCity.name : please_choose;
        }
            break;
        case 2:
        {
            PSJail *selectedJail = visitorViewModel.selectedJail;
            title = selectedJail ? selectedJail.title : please_choose;
        }
            break;
        default:
            break;
    }
    return title;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = nil;
    switch (index) {
        case 0:
        {
            if (!self.provinceDisplayViewController) {
                PSProvinceDisplayViewController *pDisplayViewController = [[PSProvinceDisplayViewController alloc] initWithViewModel:self.viewModel];
                @weakify(self)
                [pDisplayViewController setCallback:^(NSInteger selectedIndex) {
                    @strongify(self)
                    [self selectProvinceAtIndex:selectedIndex];
                }];
                self.provinceDisplayViewController = pDisplayViewController;
            }
            viewController = self.provinceDisplayViewController;
        }
            break;
        case 1:
        {
            if (!self.cityDisplayViewController) {
                PSCityDisplayViewController *cDisplayViewController = [[PSCityDisplayViewController alloc] initWithViewModel:self.viewModel];
                @weakify(self)
                [cDisplayViewController setCallback:^(NSInteger selectedIndex) {
                    @strongify(self)
                    [self selectCityAtIndex:selectedIndex];
                }];
                self.cityDisplayViewController = cDisplayViewController;
            }
            viewController = self.cityDisplayViewController;
        }
            break;
        case 2:
        {
            if (!self.jailDisplayViewController) {
                PSJailDisplayViewController *jDisplayViewController = [[PSJailDisplayViewController alloc] initWithViewModel:self.viewModel];
                @weakify(self)
                [jDisplayViewController setCallback:^(NSInteger selectedIndex) {
                    @strongify(self)
                    [self selectJailAtIndex:selectedIndex];
                }];
                self.jailDisplayViewController = jDisplayViewController;
            }
            viewController = self.jailDisplayViewController;
        }
            break;
        default:
            break;
    }
    return viewController;
}

#pragma mark -
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [XWPresentOneTransition transitionWithTransitionType:XWPresentOneTransitionTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [XWPresentOneTransition transitionWithTransitionType:XWPresentOneTransitionTypeDismiss];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return _interactiveDismiss.interation ? _interactiveDismiss : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    return _interactivePush.interation ? _interactivePush : nil;
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
