//
//  PSPublishArticleViewController.m
//  PrisonService
//
//  Created by kky on 2019/8/5.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPublishArticleViewController.h"
#import <IQKeyboardManager/IQTextView.h>
#import "PSPublishScuessViewController.h"

@interface PSPublishArticleViewController ()

@property(nonatomic,strong)UIButton *closeBtn;
@property(nonatomic,strong)UIButton *publishBtn;
@property(nonatomic,strong)UIImageView *articletypeImg;
@property(nonatomic,strong)UILabel *articletypeLab;
@property(nonatomic,strong)UILabel *articletypeValueLab;
@property(nonatomic,strong)UIImageView *authorImg;
@property(nonatomic,strong)UILabel *authorLab;
@property(nonatomic,strong)UITextField *authorField;
@property(nonatomic,strong)UIImageView *articleTitleImg;
@property(nonatomic,strong)UILabel *articleTitleLab;
@property(nonatomic,strong)UITextField *articleTitleField;
@property(nonatomic,strong)IQTextView *articleContent;
@property(nonatomic,strong)UIScrollView *scrollview;
@property(nonatomic,strong)UIView *container;

@end

@implementation PSPublishArticleViewController

#pragma mark - CylceLife
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发布文章";
    [self p_setUI];
}

- (BOOL)hiddenNavigationBar{
    return YES;
}

#pragma mark - PrivateMethods
-(void)p_setUI{
    
    [self.view addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.with.mas_equalTo(14);
        make.top.mas_equalTo(50);
    }];
    [self.view addSubview:self.publishBtn];
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(37);
        make.width.mas_equalTo(70);
        make.centerY.mas_equalTo(_closeBtn);
    }];
    
    [self.view addSubview:self.scrollview];
    self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH,700);
    [self.scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.closeBtn.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    [self.scrollview addSubview:self.container];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.height.mas_equalTo(_scrollview);
    }];
    
    [self.container addSubview:self.articletypeImg];
    [self.articletypeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(15);
    }];
    
    [self.container addSubview:self.articletypeLab];
    [self.articletypeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_articletypeImg.mas_right).offset(10);
        make.centerY.mas_equalTo(_articletypeImg);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(21);
    }];
    
    [self.container addSubview:self.articletypeValueLab];
    [self.articletypeValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-18);
        make.centerY.mas_equalTo(_articletypeImg);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(21);
    }];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(217, 217, 217);
    [self.container addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(_articletypeImg.mas_bottom).offset(12);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.container addSubview:self.authorImg];
    [self.authorImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line1.mas_bottom).offset(25);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(15);
    }];
    
    [self.container addSubview:self.authorLab];
    [self.authorLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_authorImg.mas_right).offset(10);
        make.centerY.mas_equalTo(_authorImg);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(21);
    }];
    
    [self.container addSubview:self.authorField];
    [self.authorField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_authorLab);
        make.top.mas_equalTo(_authorLab.mas_bottom).offset(8);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(21);
    }];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = UIColorFromRGB(217, 217, 217);
    [self.container addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(_authorField.mas_bottom).offset(12);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.container addSubview:self.articleTitleImg];
    [self.articleTitleImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line2.mas_bottom).offset(16);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(15);
    }];
    
    [self.container addSubview:self.articleTitleLab];
    [self.articleTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_articleTitleImg.mas_right).offset(10);
        make.centerY.mas_equalTo(_articleTitleImg);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(21);
    }];
    
    [self.container addSubview:self.articleTitleField];
    [self.articleTitleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_articleTitleLab);
        make.top.mas_equalTo(_articleTitleLab.mas_bottom).offset(18);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(21);
    }];
    
    UIView *line3 = [UIView new];
    line3.backgroundColor = UIColorFromRGB(217, 217, 217);
    [self.container addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(_articleTitleField.mas_bottom).offset(12);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.container addSubview:self.articleContent];
    [self.articleContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.top.mas_equalTo(line3.mas_bottom).offset(22);
        make.bottom.mas_equalTo(self.container);
    }];

}
#pragma mark - TouchEvent
-(void)closeAction:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)publishAction:(UIButton*)sender{
    PSPublishScuessViewController *scuessVC = [[PSPublishScuessViewController alloc] init];
    [self.navigationController pushViewController:scuessVC animated:YES];
}

#pragma mark - Setting&&Getting
-(UIScrollView *)scrollview {
    if(!_scrollview){
        _scrollview = [[UIScrollView alloc] init];
    }
    return _scrollview;
}
-(UIView *)container{
    if (!_container) {
        _container = [UIView new];
    }
    return _container;
}

-(UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:IMAGE_NAMED(@"关闭icon") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
-(UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishBtn addTarget:self action:@selector(publishAction:) forControlEvents:UIControlEventTouchUpInside];
        [_publishBtn setImage:IMAGE_NAMED(@"发表") forState:UIControlStateNormal];
    }
    return _publishBtn;
}
-(UIImageView *)articletypeImg{
    if (!_articletypeImg) {
        _articletypeImg = [UIImageView new];
        _articletypeImg.image = IMAGE_NAMED(@"文章类型");
    }
    return _articletypeImg;
}
-(UILabel *)articletypeLab{
    if (!_articletypeLab) {
        _articletypeLab = [UILabel new];
        _articletypeLab.text = @"文章类型";
        _articletypeLab.textAlignment = NSTextAlignmentLeft;
        _articletypeLab.font = FontOfSize(12);
        _articletypeLab.textColor = UIColorFromRGB(102, 102, 102);
    }
    return _articletypeLab;
}
-(UILabel *)articletypeValueLab{
    if (!_articletypeValueLab) {
        _articletypeValueLab = [UILabel new];
        _articletypeValueLab.text = @"互动文章";
        _articletypeValueLab.textAlignment = NSTextAlignmentRight;
        _articletypeValueLab.font = FontOfSize(14);
        _articletypeValueLab.textColor = UIColorFromRGB(38,76,144);
    }
    return _articletypeValueLab;
}
-(UIImageView *)authorImg{
    if (!_authorImg) {
        _authorImg = [UIImageView new];
        _authorImg.image = IMAGE_NAMED(@"作者icon");
    }
    return _authorImg;
}
-(UILabel *)authorLab{
    if (!_authorLab) {
        _authorLab = [UILabel new];
        _authorLab.text = @"作者笔名";
        _authorLab.textAlignment = NSTextAlignmentLeft;
        _authorLab.font = FontOfSize(12);
        _authorLab.textColor = UIColorFromRGB(102, 102, 102);
    }
    return _authorLab;
}
-(UITextField *)authorField{
    if (!_authorField) {
        _authorField = [UITextField new];
        _authorField.text = @"果壳吴彦祖";
        _authorLab.font = FontOfSize(14);
        _authorLab.textColor = UIColorFromRGB(51,51,51);
    }
    return _authorField;
}

-(UIImageView *)articleTitleImg{
    if (!_articleTitleImg) {
        _articleTitleImg = [UIImageView new];
        _articleTitleImg.image = IMAGE_NAMED(@"文章标题");
    }
    return _articleTitleImg;
}
-(UILabel *)articleTitleLab{
    if (!_articleTitleLab) {
        _articleTitleLab = [UILabel new];
        _articleTitleLab.text = @"文章标题";
        _articleTitleLab.textAlignment = NSTextAlignmentLeft;
        _articleTitleLab.font = FontOfSize(12);
        _articleTitleLab.textColor = UIColorFromRGB(102, 102, 102);
    }
    return _articleTitleLab;
}
-(UITextField *)articleTitleField{
    if (!_articleTitleField) {
        _articleTitleField = [UITextField new];
        _articleTitleField.font = FontOfSize(14);
        _articleTitleField.textColor = UIColorFromRGB(51,51,51);
        _articleTitleField.text = @"今夜的月光超载太重照着我一夜哄不成梦每根";
    }
    return _articleTitleField;
}

-(IQTextView*)articleContent {
    if (!_articleContent) {
        _articleContent = [[IQTextView alloc] init];
        _articleContent.placeholder = @"请输入正文，字数限制为100-20000字";
        _articleContent.font = FontOfSize(14);
    }
    return _articleContent;
}







@end
