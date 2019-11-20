//
//  PSBuyCardView.m
//  PrisonService
//
//  Created by kky on 2018/11/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBuyCardView.h"
#import "PSSessionManager.h"

@interface PSBuyCardView()<UITextFieldDelegate>

@property(nonatomic,strong) UIView *contView;
@property(nonatomic,strong) UIButton *cancerBtn;
@property(nonatomic,strong) UIButton *sureBtn;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UITextField *amounField;
@property(nonatomic,strong) UIToolbar *shadowView;
@property(nonatomic,assign) NSInteger seletIndex;
@property(nonatomic,assign) BOOL isWrite; //手写OR选择框(埋点需要)
@property(nonatomic,strong) UILabel *totalLabel;
@property(nonatomic,strong) PSBuyModel *buyModel;




@end

@implementation PSBuyCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH,325);
        self.backgroundColor = [UIColor whiteColor];
        _seletIndex = 0;
        _isWrite = NO;
        [self p_setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame buyModel:(PSBuyModel *)buyModel index:(NSInteger)index; {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0,SCREEN_HEIGHT-325, SCREEN_WIDTH,325);
        self.backgroundColor = [UIColor whiteColor];
        _seletIndex = index;
        _buyModel = buyModel;
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
    NSString * titleLabText=NSLocalizedString(@"Family card purchase", @"远程探视卡购买");
    titleLab.text = titleLabText;
    titleLab.textColor = UIColorFromRGB(0,0,0);
    titleLab.font = FontOfSize(17);
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(closeButton);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(10,45,SCREEN_WIDTH-20, 1)];
    topLine.backgroundColor = UIColorFromRGB(234,235,238);
    [self addSubview:topLine];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(20,260,SCREEN_WIDTH-40, 1)];
    bottomLine.backgroundColor = UIColorFromRGB(234,235,238);
    [self addSubview:bottomLine];
    
    NSString * family_members=NSLocalizedString(@"family members:", @"家属:");
    NSString * Inmates=NSLocalizedString(@"Inmates:", @"服刑人员:");
    NSString * Prison_name=NSLocalizedString(@"Prison name:", @"监狱名称:");
    NSString * Purchase_quantity=NSLocalizedString(@"Purchase quantity:", @"购买数量:");
    NSString * Amount_of_money=NSLocalizedString(@"Amount of money:", @"金额:");
    NSArray *keytitles = @[family_members,Inmates,Prison_name,Purchase_quantity,Amount_of_money];
    
    
    NSString *family_members_value = _buyModel.family_members;
    //名字加密
//    if (family_members_value.length>2) {
//        NSInteger length = family_members_value.length-2;
//        NSString *repreceString = @"*";
//        for (int i = 1;i<length ;i++) {
//            repreceString = [repreceString stringByAppendingString:repreceString];
//        }
//        family_members_value = [family_members_value stringByReplacingCharactersInRange:NSMakeRange(1, length) withString:repreceString];
//    } else {
//        if (family_members_value.length>0) {
//            family_members_value = [family_members_value stringByReplacingCharactersInRange:NSMakeRange(family_members_value.length-1, 1) withString:@"*"];
//        }
//    }
    NSString *allmoney = [NSString stringWithFormat:@"%.2lf元",_buyModel.Amount_of_money];
    NSArray *valuetexts = @[family_members_value,_buyModel.Inmates,_buyModel.Prison_name];
    
    
    for (int i = 0;i<5; i++) {
        UILabel *keylabel = [[UILabel alloc] initWithFrame:CGRectMake(10,50+40*i,70, 40)];
        keylabel.text = keytitles[i];
        keylabel.font = FontOfSize(14);
        keylabel.textAlignment = NSTextAlignmentRight;
        keylabel.numberOfLines = 0;
        keylabel.textColor = UIColorFromRGB(51,51,51);
        [self addSubview:keylabel];
        
        if (i<3) {
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90,50+40*i,250, 40)];
            valueLabel.text = keytitles[i];
            valueLabel.font = FontOfSize(14);
            valueLabel.textAlignment = NSTextAlignmentLeft;
            valueLabel.textColor = UIColorFromRGB(51,51,51);
            valueLabel.text = valuetexts[i];
            valueLabel.numberOfLines = 0;
            [self addSubview:valueLabel];
        }
        if (i==4) {
            self.totalLabel.frame = CGRectMake(90,50+40*i,250, 40);
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:allmoney];
            [attrStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(51,51,51) range:NSMakeRange(allmoney.length-1,1)];
            self.totalLabel.attributedText = attrStr;
            if ([NSObject judegeIsVietnamVersion]) self.totalLabel.text = [allmoney substringToIndex:allmoney.length-1];
            [self addSubview:self.totalLabel];
        }
    }
    //购买数量
    NSString *piece = NSLocalizedString(@"piece", @"张");
    NSString *one_piece = [NSString stringWithFormat:@"1%@",piece];
    NSString *three_piece = [NSString stringWithFormat:@"3%@",piece];
    NSString *six_piece = [NSString stringWithFormat:@"6%@",piece];
    NSString *Input_purchase_quantity = NSLocalizedString(@"Input purchase quantity", @"输入购买数量");
    NSArray *btnNames = @[one_piece,three_piece,six_piece];
    
    int btnWidth = (SCREEN_WIDTH - 110)/6;
    for (int i = 0; i<6; i++) {
        if (i<3) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(90+(btnWidth+5)*i,180,btnWidth ,20);
            [btn setTitle:btnNames[i] forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGB(43, 61, 152) forState:UIControlStateNormal];
            btn.titleLabel.font = FontOfSize(10);
            btn.layer.masksToBounds = YES;
            btn.layer.borderWidth = 1;
            if (i==0) {
                btn.layer.borderColor = UIColorFromRGB(43, 61, 152).CGColor;
            } else {
               btn.layer.borderColor = [UIColor grayColor].CGColor;
            }
//            btn.layer.borderColor = UIColorFromRGB(43, 61, 152).CGColor;
            btn.layer.cornerRadius = 2;
            btn.tag = 10+i;
            [self addSubview:btn];
            @weakify(self);
            [btn bk_whenTapped:^{
                @strongify(self);
                [self seletAmount:btn.tag];
            }];
        }
        if (i==3) {
            self.amounField.frame = CGRectMake(90+(btnWidth+5)*i, 180, btnWidth*2, 20);
            self.amounField.placeholder = Input_purchase_quantity;
            [self addSubview:self.amounField];
        }
        if (i == 5) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90+(btnWidth+5)*i,170,btnWidth, 40)];
            label.text = piece;
            label.font = FontOfSize(10);
            label.textColor = UIColorFromRGB(51,51,51);
            [self addSubview:label];
        }
    }

    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString * sureBtnText=NSLocalizedString(@"Purchase immediately", @"立即购买");
    [sureBtn setTitle:sureBtnText forState:UIControlStateNormal];
    sureBtn.titleLabel.font = FontOfSize(10);
    sureBtn.titleLabel.numberOfLines = 0;
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
        if (_seletIndex==0) {
            NSString * message =NSLocalizedString(@"Please enter the purchase quantity", @"请输入购买数量");
            [PSTipsView showTips:message];
            return ;
        }
        @strongify(self)
        [self disMissView];
        if (self.buyBlock) {
            self.buyBlock(_seletIndex,_isWrite);
        }
    }];
}

- (void)p_changeAllBtnBg{
    for (int i = 0; i<3; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:i+10];
        btn.layer.borderColor = [UIColor grayColor].CGColor;
    }
    self.amounField.layer.borderColor = [UIColor grayColor].CGColor;
}
#pragma -mark TouchEvent
- (void)seletAmount:(NSInteger)tag {
    [self p_changeAllBtnBg];
    UIButton *btn = (UIButton *)[self viewWithTag:tag];
    btn.layer.borderColor = UIColorFromRGB(43, 61, 152).CGColor;
    self.amounField.text = @"";
    [self.amounField resignFirstResponder];
    NSString *allmoney = @"";
    if (tag == 10) {
        allmoney = [NSString stringWithFormat:@"%.2lf元",_buyModel.Amount_of_money*1];
        _seletIndex = 1;
    } else if (tag ==11) {
        allmoney = [NSString stringWithFormat:@"%.2lf元",_buyModel.Amount_of_money*3];
        _seletIndex = 3;
    } else if (tag ==12) {
        _seletIndex = 6;
        allmoney = [NSString stringWithFormat:@"%.2lf元",_buyModel.Amount_of_money*6];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:allmoney];
    [attrStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(51, 51, 51) range:NSMakeRange(allmoney.length-1,1)];
    self.totalLabel.attributedText = attrStr;
    
    if ([NSObject judegeIsVietnamVersion]) self.totalLabel.text = [allmoney substringToIndex:allmoney.length-1];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self p_changeAllBtnBg];
    textField.layer.borderColor = UIColorFromRGB(43, 61, 152).CGColor;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *toString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (toString.length) {
        NSString *stringRegex;
        if (textField == self.amounField) {
            stringRegex = @"[1-9][0-9]{0,1}|100?";
        }
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
        BOOL flag = [phoneTest evaluateWithObject:toString];
        if (flag==NO) {
            if ([toString isEqualToString:@"0"]) {
                NSString *tips = NSLocalizedString(@"The purchase quantity cannot be 0", @"购买数量不能为0");
                [PSTipsView showTips:tips];
            } else {
                NSString *tips = NSLocalizedString(@"The number of purchases cannot exceed 100 sheets", @"购买数量不能超过100张");
                [PSTipsView showTips:tips];
            }
        }
        return flag;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *allmoney = [NSString stringWithFormat:@"%.2lf元",_buyModel.Amount_of_money*[textField.text integerValue]];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:allmoney];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(allmoney.length-1,1)];
    self.totalLabel.attributedText = attrStr;
    _seletIndex = [textField.text integerValue];
    if (textField.text.length>0) {
        _isWrite = YES;
    } else {
        _isWrite = NO;
    }
    if ([NSObject judegeIsVietnamVersion]) self.totalLabel.text = [allmoney substringToIndex:allmoney.length-1];
}


#pragma -mark Setting&Getting

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.font = FontOfSize(14);
        _totalLabel.textAlignment = NSTextAlignmentLeft;
        _totalLabel.textColor = [UIColor redColor];
    }
    return _totalLabel;
}
- (UITextField *)amounField {
    if (!_amounField) {
        _amounField = [[UITextField alloc] init];
        _amounField.font = FontOfSize(10);
        _amounField.layer.masksToBounds = YES;
        _amounField.layer.borderWidth = 1;
        //            textField.layer.borderColor = UIColorFromRGB(43, 61, 152).CGColor;
        _amounField.layer.borderColor = [UIColor grayColor].CGColor;
        _amounField.layer.cornerRadius = 2;
        _amounField.textAlignment = NSTextAlignmentCenter;
        _amounField.keyboardType = UIKeyboardTypeNumberPad;
        _amounField.delegate = self;
    }
    return _amounField;
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

- (void)showView:(UIViewController *)vc;{
//    [self.navigationController.view addSubview:newView];
    _isWrite = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.shadowView.frame = window.bounds;
    [vc.navigationController.view addSubview:self.shadowView];
    [vc.navigationController.view addSubview:self];
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


@implementation PSBuyModel


@end;



