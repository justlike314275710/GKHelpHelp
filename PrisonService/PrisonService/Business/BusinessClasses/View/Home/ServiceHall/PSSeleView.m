//
//  PSSeleView.m
//  PrisonService
//
//  Created by kky on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSSeleView.h"
#import "PSPrisonerDetail.h"

@interface PSSeleView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *contView;
@property(nonatomic,strong) UIButton *cancerBtn;
@property(nonatomic,strong) UIButton *sureBtn;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UITableView *myTableview;
@property(nonatomic,strong) UIToolbar *shadowView;
@property(nonatomic,strong) NSArray<PSPrisonerDetail *> *datalist;
@property(nonatomic,assign) NSInteger seletIndex;


@end

@implementation PSSeleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH,325);
        self.backgroundColor = [UIColor whiteColor];
        _seletIndex = 0;
        [self p_setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame dataList:(NSArray *)datalist index:(NSInteger)index {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0,SCREEN_HEIGHT-325, SCREEN_WIDTH,325);
        self.backgroundColor = [UIColor whiteColor];
        _datalist = datalist;
        _seletIndex = index;
        [self p_setUI];
    }
    return self;
}

- (void)p_setUI {
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"universalCloseIcon"] forState:UIControlStateNormal];
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(14);
    }];
    @weakify(self)
    [closeButton bk_whenTapped:^{
        @strongify(self)
        [self disMissView];
    }];
    UILabel *titleLab = [UILabel new];
    NSString * titleLabText=NSLocalizedString(@"please choose prisoners", @"请选择服刑人员");
    titleLab.text = titleLabText;
    titleLab.textColor = UIColorFromRGB(102, 102, 102);
    titleLab.font = FontOfSize(14);
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(closeButton);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.myTableview];
    [self.myTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(50);
        make.height.mas_equalTo(200);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString * sureBtnText=NSLocalizedString(@"determine", @"确定");
    [sureBtn setTitle:sureBtnText forState:UIControlStateNormal];
    sureBtn.titleLabel.font = FontOfSize(10);
    [sureBtn setTitleColor:UIColorFromRGB(38, 76, 144) forState:UIControlStateNormal];
    sureBtn.layer.masksToBounds = YES;
    sureBtn.layer.cornerRadius = 14;
    sureBtn.layer.borderWidth = 1;
    sureBtn.layer.borderColor = UIColorFromRGB(43, 61, 152).CGColor;
    [self addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(27);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-20);
    }];
    [sureBtn bk_whenTapped:^{
        @strongify(self)
        [self disMissView];
        if (self.firmSelecteBlock) {
            self.firmSelecteBlock(_seletIndex);
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datalist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"seleviewcellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(20,15 ,300 ,20)];
        nameLab.text = [_datalist objectAtIndex:indexPath.row].name;
        nameLab.textColor = UIColorFromRGB(102, 102, 102);
        nameLab.font = FontOfSize(14);
        [cell.contentView addSubview:nameLab];
        UIImageView *seleImg = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 19, 12, 12)];
        seleImg.tag = 100;
        seleImg.image = [UIImage imageNamed:@"sessionProtocolNormal"];
        [cell.contentView addSubview:seleImg]; //
    }
    UIImageView *seleImg = [cell.contentView viewWithTag:100];
    if (indexPath.row == _seletIndex) {
        seleImg.image = [UIImage imageNamed:@"sessionProtocolSelected"];
    } else {
        seleImg.image = [UIImage imageNamed:@"sessionProtocolNormal"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _seletIndex = indexPath.row;
    [self.myTableview reloadData];
}

#pragma -mark Setting&Getting
- (UITableView *)myTableview {
    if (!_myTableview) {
        _myTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _myTableview.tableFooterView = [UIView new];
        _myTableview.backgroundColor = [UIColor clearColor];
        //        _myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableview.dataSource = self;
        _myTableview.delegate = self;
    }
    return _myTableview;
}

- (UIToolbar *)shadowView {
    if (!_shadowView) {
        _shadowView= [[UIToolbar alloc]initWithFrame:CGRectZero];
        _shadowView.barStyle = UIBarStyleBlackTranslucent;//半透明
        //透明度
        _shadowView.alpha = 0.7f;
        @weakify(self);
        [_shadowView bk_whenTapped:^{
            @strongify(self);
            [self disMissView];
        }];
    }
    return _shadowView;
}

- (void)showView{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.shadowView.frame = window.bounds;
    [window addSubview:self.shadowView];
    [window addSubview:self];
    self.frame = CGRectMake(0, SCREEN_HEIGHT,SCREEN_WIDTH ,325);
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(0,SCREEN_HEIGHT-325, SCREEN_WIDTH,325);
    }];
}

- (void)disMissView {
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH,325);
    } completion:^(BOOL finished) {
        if (self) [self removeFromSuperview];
        if (_shadowView) [_shadowView removeFromSuperview];
    }];
}




@end
