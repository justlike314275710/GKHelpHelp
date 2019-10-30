//
//  PSReportScuessViewController.m
//  PrisonService
//
//  Created by kky on 2019/10/28.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSReportScuessViewController.h"
#import "PSDetailArticleViewController.h"


@interface PSReportScuessViewController ()
@property(nonatomic,strong)UIImageView *sucessIconImg;
@property(nonatomic,strong)UILabel *hassubmitLab;
@property(nonatomic,strong)UILabel *msgLab;

@end

@implementation PSReportScuessViewController

#pragma mark ---------- LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"举报";
    self.view.backgroundColor = UIColorFromRGB(249, 248, 254);
    [self setupUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark ---------- Private Method
/** 视图初始化 */
- (void)setupUI {
    [self createRightBarButtonItemWithTarget:self action:@selector(rightAction) title:@"关闭"];
    [self.view addSubview:self.sucessIconImg];
    [self.sucessIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(156);
        make.height.mas_equalTo(135);
    }];
    
    [self.view addSubview:self.hassubmitLab];
    [self.hassubmitLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_sucessIconImg.mas_bottom).offset(20);
        make.centerX.mas_equalTo(_sucessIconImg);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.msgLab];
    [self.msgLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_hassubmitLab.mas_bottom).offset(12);
        make.centerX.mas_equalTo(_hassubmitLab);
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(20);
    }];
    
}
/** 加载数据 */
- (void)loadData {
    
}

#pragma mark ---------- Target Mehtods
- (UIColor *)rightItemTitleColor {
    return UIColorFromRGB(102, 102, 102);
}

- (IBAction)actionOfLeftItem:(id)sender {
    [self rightAction];
}

-(void)rightAction{
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PSDetailArticleViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];
}
#pragma mark ---------- Setter & Getter
-(UIImageView *)sucessIconImg{
    if(_sucessIconImg==nil){
        _sucessIconImg = [[UIImageView alloc] init];
        _sucessIconImg.image = IMAGE_NAMED(@"payscuess");
    }
    return _sucessIconImg;
}
-(UILabel *)hassubmitLab{
    if(_hassubmitLab==nil){
        _hassubmitLab = [[UILabel alloc] init];
        _hassubmitLab.text = @"已提交";
        _hassubmitLab.textColor = UIColorFromRGB(38, 76, 144);
        _hassubmitLab.textAlignment = NSTextAlignmentCenter;
        _hassubmitLab.font = boldFontOfSize(19);
    }
    return _hassubmitLab;
}
-(UILabel *)msgLab{
    if(_msgLab==nil){
        _msgLab = [[UILabel alloc] init];
        _msgLab.text = @"您的举报已提交审核,感谢您对平台的支持";
        _msgLab.textColor = UIColorFromRGB(102,102,102);
        _msgLab.textAlignment = NSTextAlignmentCenter;
        _msgLab.font = FontOfSize(12);
    }
    return _msgLab;
}

@end
