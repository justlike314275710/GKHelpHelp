//
//  VIRegisterViewController.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/8/7.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "VIRegisterViewController.h"
#import "PSRegisterProgressView.h"
#import "VIRegisterPageController.h"
#import "PSPersonalViewController.h"
#import "VIMemberViewController.h"
#import "VIIDCardViewController.h"
#import "VIRelationViewController.h"
#import "VIPhoneMessageViewController.h"
#import "VIRegisterViewModel.h"
#import "PSBusinessConstants.h"
#import "PSSessionPendingController.h"
#import "MemberGuideVC.h"
#import "IDCardGuideVC.h"
#import "RelationGuideVC.h"
#import "MessageGuideVC.h"
#import "VIRegisterProgressView.h"
#import "PSSessionNoneViewController.h"
@interface VIRegisterViewController ()<WMPageControllerDataSource,WMPageControllerDelegate>
@property (nonatomic, strong) NSArray *coverImageNames;

@property (nonatomic, strong) VIRegisterProgressView *progressView;
@property (nonatomic, strong) VIRegisterPageController *registerPageController;
@property (nonatomic, strong) PSPersonalViewController *personalViewController;
@property (nonatomic, strong) VIMemberViewController *memberViewController;
@property (nonatomic, strong) VIIDCardViewController *cardViewController;
@property (nonatomic, strong) VIRelationViewController *relationViewController;
@property (nonatomic, strong) VIPhoneMessageViewController *messageViewController;
@property (nonatomic, strong) UIButton *preButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong)  MemberGuideVC*memberVC;
@property (nonatomic,assign)   BOOL firstCard;
@end

@implementation VIRegisterViewController


- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.title = @"Xác thực";
    }
    return self;
}


- (IBAction)nextStep:(id)sender {
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    switch (self.progressView.progress) {
        case VIRegisterProgressMember:
        {
            @weakify(self)
            
            [registerViewModel checkMemberDataWithCallback:^(BOOL successful, NSString *tips) {
                @strongify(self)
                if (successful) {
                    self.progressView.progress += 1;
                    self.registerPageController.selectIndex = self.progressView.progress;

                }else{
                    [PSTipsView showTips:tips];
                }
              
           }];
                
        }
            break;
      
            
        case VIRegisterProgressIDCard:
        {
            @weakify(self)
            [registerViewModel checkIDCardDataWithCallback:^(BOOL successful, NSString *tips) {
                @strongify(self)
                if (successful) {
                    self.progressView.progress += 1;
                    self.registerPageController.selectIndex = self.progressView.progress;

                }else{
                    [PSTipsView showTips:tips];
                }
             
            }];
        }
            break;
        case VIRegisterProgressMessage:
        {
            @weakify(self)
            [registerViewModel checkMessageDataWithCallback:^(BOOL successful, NSString *tips) {
                @strongify(self)
                if (successful) {
                    self.progressView.progress += 1;
                    self.registerPageController.selectIndex = self.progressView.progress;
                    
                }else{
                    [PSTipsView showTips:tips];
                }
                }];
           
        }
            break;
            
        case VIRegisterProgressrelation:
        {
            
            @weakify(self)
            [registerViewModel checkProtocolDataWithCallback:^(BOOL successful, NSString *tips) {
                @strongify(self)
                if (successful) {
                    [self actionOfRegister];
                    
                }else{
                    [PSTipsView showTips:tips];
                }
            }];
           // [self actionOfRegister];
        }
            break;
        default:
            break;
    }
}

-(void)guideAction{
    
    switch (self.progressView.progress) {
        case VIRegisterProgressMember:{
            [self presentViewController:[[MemberGuideVC alloc]init] animated:YES completion:nil];
        }break;
        case VIRegisterProgressrelation:{
            [self presentViewController:[[RelationGuideVC alloc]init] animated:YES completion:nil];
        }break;
        case VIRegisterProgressIDCard:{
            [self presentViewController:[[IDCardGuideVC alloc]init] animated:YES completion:nil];
        }break;
        case VIRegisterProgressMessage:{
            [self presentViewController:[[MessageGuideVC alloc]init] animated:YES completion:nil];
        }break;
        default:
            break;
    }
}
- (IBAction)preStep:(id)sender {
    self.progressView.progress -= 1;
    self.registerPageController.selectIndex = self.progressView.progress;
}

//- (void)checkCodeAction {
//    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
//    @weakify(self)
//    [registerViewModel checkCodeCompleted:^(PSResponse *response) {
//        @strongify(self)
//        if (response.code == 200) {
//            [self actionOfRegister];
//        }else{
//            [[PSLoadingView sharedInstance] dismiss];
//            [PSTipsView showTips:response.msg ? response.msg : @"短信校验失败"];
//        }
//    } failed:^(NSError *error) {
//        @strongify(self)
//        [[PSLoadingView sharedInstance] dismiss];
//        [self showNetError];
//    }];
//}

- (void)checkWhiteListAction {
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance] show];
    @weakify(self)
    [registerViewModel checkWhiteListCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            [self actionOfRegister];
            //[self registerFaceGid:registerViewModel.avatarUrl];
        }else{
            //[self checkCodeAction];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError];
    }];
}

- (void)actionOfRegister {
    VIRegisterViewModel *registerViewModel = (VIRegisterViewModel *)self.viewModel;
    registerViewModel.type=@"0";
    @weakify(self)
    @weakify(registerViewModel)
    
    [registerViewModel registerCompleted:^(PSResponse *response) {
        @strongify(self)
        @strongify(registerViewModel)
        [[PSLoadingView sharedInstance] dismiss];
        NSLog(@"%@",response);
        if (response.code == 200) {
            //注册成功
            if (self.callback) {
                self.callback(YES,registerViewModel.session);
            }
            [PSTipsView showTips:@"Giấy chứng nhận đăng ký thành công."];
            [self.navigationController pushViewController:[[PSSessionNoneViewController alloc]init] animated:YES];
        }else{
            [PSTipsView showTips:@"Giấy chứng nhận đăng ký thất bại."];
        }
    } failed:^(NSError *error) {
        NSLog(@"----%@",error);
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError];
    }];
}



- (void)reloadStepButtons {
    CGSize bSize = CGSizeMake(120, 35);
    if (self.progressView.progress == VIRegisterProgressMember) {
        self.preButton.hidden = YES;
        self.nextButton.hidden = NO;
        self.registerButton.hidden = YES;
        [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.registerPageController.view.mas_bottom);
            make.size.mas_equalTo(bSize);
        }];
    }else if (self.progressView.progress == VIRegisterProgressrelation){
        self.preButton.hidden = NO;
        self.nextButton.hidden = YES;
        self.registerButton.hidden = NO;
        [self.preButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.mas_centerX).offset(-15);
            make.top.mas_equalTo(self.registerPageController.view.mas_bottom);
            make.size.mas_equalTo(bSize);
        }];
        [self.registerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_centerX).offset(15);
            make.top.mas_equalTo(self.registerPageController.view.mas_bottom);
            make.size.mas_equalTo(bSize);
        }];
    }else{
        self.preButton.hidden = NO;
        self.nextButton.hidden = NO;
        self.registerButton.hidden = YES;
        [self.preButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.mas_centerX).offset(-15);
            make.top.mas_equalTo(self.registerPageController.view.mas_bottom);
            make.size.mas_equalTo(bSize);
        }];
        [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_centerX).offset(15);
            make.top.mas_equalTo(self.registerPageController.view.mas_bottom);
            make.size.mas_equalTo(bSize);
        }];
    }
}


- (void)reloadContent {
    [self.registerPageController reloadData];
    self.registerPageController.selectIndex = self.progressView.progress;
    [self reloadStepButtons];
}
-(void)renderRightBarButtonItem{
    UIButton *rButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rButton.exclusiveTouch = YES;
    CGSize defaultSize = CGSizeMake(15, 15);
    
    UIImage*nImage=[UIImage imageNamed:@"guidanceIcon"];
    if (nImage.size.width > defaultSize.width) {
        defaultSize.width = nImage.size.width;
    }
    rButton.frame = CGRectMake(0, 10, defaultSize.width, defaultSize.height);
    rButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rButton setImage:nImage forState:UIControlStateNormal];
    UILabel*guideLab= [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 50, 25)];
    guideLab.numberOfLines=0;
    guideLab.text=@"Hướng dẫn";
    guideLab.textColor=AppBaseTextColor1;
    guideLab.font=FontOfSize(10);
    UIView*customView=[[UIView alloc]init];
    customView.frame=CGRectMake(0, 0, 60, 40);
    [customView addSubview:rButton];
    [customView addSubview:guideLab];
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(guideAction)];
    [customView  addGestureRecognizer:tapGesturRecognizer];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.rightBarButtonItem=barItem;
    
}
- (void)renderContents {
    self.progressView = [VIRegisterProgressView new];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(RELATIVE_HEIGHT_VALUE(10));
        make.height.mas_equalTo(60);
    }];
    self.registerPageController = [[VIRegisterPageController alloc] init];
    self.registerPageController.dataSource = self;
    self.registerPageController.delegate = self;
    [self.view addSubview:self.registerPageController.view];
    [self.registerPageController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-RELATIVE_HEIGHT_VALUE(80));
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(25);
    }];
    self.preButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.preButton addTarget:self action:@selector(preStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.preButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    self.preButton.titleLabel.font = AppBaseTextFont1;
    [self.preButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.preButton setTitle:@"LênMột bước" forState:UIControlStateNormal];
    [self.view addSubview:self.preButton];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = AppBaseTextFont1;
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton setTitle:@"BướcTiếpTheo" forState:UIControlStateNormal];
    [self.view addSubview:self.nextButton];
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton setBackgroundImage:[[UIImage imageNamed:@"universalBtBg"] stretchImage] forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = AppBaseTextFont1;
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.registerButton setTitle:@"Xác thực" forState:UIControlStateNormal];
    [self.view addSubview:self.registerButton];
    [self reloadStepButtons];
    
}

- (void)initialize {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderContents];
    [self renderRightBarButtonItem];
    
}



#pragma mark 0
#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return 4;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return nil;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectZero;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = nil;
    switch (index) {
            
        case 0:
        {
            if (!self.memberViewController) {
                self.memberViewController = [[VIMemberViewController alloc] initWithViewModel:self.viewModel];
            }
            viewController = self.memberViewController;
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstMember"]) {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstMember"];
                [self presentViewController:[[MemberGuideVC alloc]init] animated:YES completion:nil];
            }
            
        }
            break;
        case 1:
        {
            if (!self.cardViewController) {
                self.cardViewController = [[VIIDCardViewController alloc] initWithViewModel:self.viewModel];
            }
            viewController = self.cardViewController;
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstCard"]) {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstCard"];
                [self presentViewController:[[IDCardGuideVC alloc]init] animated:YES completion:nil];
            }
        }
            break;
        case 2:
        {
            
            if (!self.messageViewController) {
                self.messageViewController = [[VIPhoneMessageViewController alloc] initWithViewModel:self.viewModel];
            }
            viewController = self.messageViewController;
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstPhone"]) {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstPhone"];
                [self presentViewController:[[MessageGuideVC alloc]init] animated:YES completion:nil];
            }
            
           
        }
            break;
        case 3:
        {
            if (!self.relationViewController) {
                self.relationViewController = [[VIRelationViewController alloc] initWithViewModel:self.viewModel];
            }
            viewController = self.relationViewController;
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstRelation"]) {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstRelation"];
                [self presentViewController:[[RelationGuideVC alloc]init] animated:YES completion:nil];
            }
        }
            break;
        default:
            break;
    }
    return viewController;
}


- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    self.progressView.progress = pageController.selectIndex;
    [self reloadStepButtons];
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
