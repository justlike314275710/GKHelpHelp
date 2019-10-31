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
#import "ReactiveObjC.h"
#import "NSString+emoji.h"
#import <RZRichTextView/RZRichTextView.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <UITextView+Placeholder.h>
#import "PSPublishArticleViewModel.h"
#import "UITextView+RZColorful.h"
#import "NSMutableAttributedString+XZExtension.h"


@interface PSPublishArticleViewController ()<UITextFieldDelegate>

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
@property(nonatomic,strong)RZRichTextView *articleContent;
@property(nonatomic,strong)UIScrollView *scrollview;
@property(nonatomic,strong)UIView *container;
@property(nonatomic,assign)BOOL hasWords;

@end

@implementation PSPublishArticleViewController

#pragma mark - CylceLife
- (void)viewDidLoad {
    [super viewDidLoad];
    PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
    self.title = @"发布文章";
    [self setupUI];
    //发布文章
    if (viewModel.type == PSPublishArticle) {
        [self setupData];
    } else {
        [self setEdeitUI];
    }
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (BOOL)hiddenNavigationBar{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollview.contentSize = CGSizeMake(_container.width,700);
    });
    
}

#pragma mark - PrivateMethods
-(void)setupData{
    PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
    [viewModel findPenNameCompleted:^(PSResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUI];
        });
    } failed:^(NSError *error) {
        
    }];
}

-(void)refreshUI{
    
    PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
    self.authorField.text = viewModel.model.pseudonym;
    if (self.authorField.text.length>0) {
       self.authorField.enabled = NO;
        viewModel.editPenName = NO;
    } else {
       self.authorField.enabled = YES;
        viewModel.editPenName = YES;
    }
}

-(void)setEdeitUI{
    PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
    self.authorField.text = viewModel.penName;
    self.articleTitleField.text = viewModel.title;
//    self.articleContent.text = viewModel.content;
    if (self.authorField.text.length>0) {
        self.authorField.enabled = NO;
    } else {
        self.authorField.enabled = YES;
    }
    if (self.articleTitleField.text.length>0) {
        self.articleTitleField.enabled = NO;
    } else {
        self.articleTitleField.enabled = YES;
    }
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:viewModel.content];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setFirstLineHeadIndent:20];
    [paragraphStyle setLineSpacing:10];
    [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[viewModel.content length])];
    _articleContent.attributedText = attriStr;
}

-(void)setupUI{
    
    [self.view addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.with.mas_equalTo(14);
        make.top.mas_equalTo(50);
        [self.closeBtn be_setEnlargeEdge:10];
    }];
    [_closeBtn be_setEnlargeEdgeWithTop:20 right:15 bottom:5 left:20];
    
    [self.view addSubview:self.scrollview];
    [self.scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.closeBtn.mas_bottom).offset(5);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];

    
    [self.scrollview addSubview:self.container];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.width.height.mas_equalTo(_scrollview);
        make.top.mas_equalTo(0);
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
        make.width.mas_equalTo(200);
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
        make.width.mas_equalTo(200);
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
        make.left.mas_equalTo(35);
        make.right.mas_equalTo(-35);
        make.top.mas_equalTo(line3.mas_bottom).offset(22);
        make.bottom.mas_equalTo(self.container.mas_bottom).offset(-10);
    }];
    
    [self.view addSubview:self.publishBtn];
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(37);
        make.width.mas_equalTo(70);
        make.centerY.mas_equalTo(_closeBtn);
    }];

}
#pragma mark - TouchEvent
-(void)closeAction:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)publishAction:(UIButton*)sender{
    _hasWords = NO;
     PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
    viewModel.penName = _authorField.text;
    viewModel.content = _articleContent.text;
    viewModel.title = _articleTitleField.text;
    viewModel.articleType = @"1";
    [viewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        if (successful) {
            [viewModel publishArticleCompleted:^(PSResponse *response) {
                if (response.code == 200) { //文章发表成功
                    PSPublishScuessViewController *scuessVC = [[PSPublishScuessViewController alloc] init];
                    //刷新我的文章列表
                    KPostNotification(KNotificationRefreshMyArticle, nil);
                    PushVC(scuessVC);
                }else if (response.code == 1587) { //标题重复
                    NSString *msg = response.msg;
                    [PSTipsView showTips:msg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reUseTitleName];
                    });
                }else if (response.code == -1) { //笔名重复
                    NSString *msg = response.msg;
                    [PSTipsView showTips:msg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reUsePenName];
                    });
                }else if(response.code ==1586) { //存在敏感字符
                    NSString *msg = response.msg;
                    [PSTipsView showTips:msg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reEditContent];
                    });
                }
            } failed:^(NSError *error) {
                
            }];
        } else {
            [PSTipsView showTips:tips];
        }
    }];
}
//文章标题重复
-(void)reUseTitleName{
    [_articleTitleLab rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.paragraphStyle.alignment(NSTextAlignmentLeft);
        confer.text(@"文章标题");
        confer.text(@"(*文章标题重复)").textColor(UIColorFromRGB(232, 16, 16));
    }];
}
//作者笔名重复
- (void)reUsePenName{
    [_authorLab rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.paragraphStyle.alignment(NSTextAlignmentLeft);
        confer.text(@"作者笔名");
        confer.text(@"(*作者笔名重复)").textColor(UIColorFromRGB(232, 16, 16));
    }];
}
//存在敏感字符
-(void)reEditContent{
    //内容
    self.hasWords = YES;
    PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:viewModel.content];
    [viewModel.words enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *astring = obj;
        NSMutableArray *sbulocationAry = [viewModel getRangeStr:viewModel.content findText:astring];
        [sbulocationAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = [obj integerValue];
            [self textAttributedString:attriStr WithString:astring index:index];
        }];
    }];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setFirstLineHeadIndent:20];
    [paragraphStyle setLineSpacing:10];
    [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[viewModel.content length])];
    // 调整字间距
    _articleContent.attributedText = attriStr;
    _articleContent.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraphStyle;
    
    //标题
    NSMutableAttributedString * attriStr1 = [[NSMutableAttributedString alloc] initWithString:viewModel.title];
    [viewModel.words enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *astring = obj;
        NSMutableArray *sbulocationAry = [viewModel getRangeStr:viewModel.title findText:astring];
        [sbulocationAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = [obj integerValue];
            [self textAttributedString:attriStr1 WithString:astring index:index];
        }];
    }];
    _articleTitleField.attributedText = attriStr1;
    //作者名字
    NSMutableAttributedString * attriStr2 = [[NSMutableAttributedString alloc] initWithString:viewModel.penName];
    [viewModel.words enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *astring = obj;
        NSMutableArray *sbulocationAry = [viewModel getRangeStr:viewModel.penName findText:astring];
        [sbulocationAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = [obj integerValue];
            [self textAttributedString:attriStr2 WithString:astring index:index];
        }];
    }];
    _authorField.attributedText = attriStr2;


}

// 富文本设置
- (void)textAttributedString:(NSMutableAttributedString*)attriString WithString:(NSString *)string index:(NSInteger)index
{
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(index,string.length)];
}

#pragma mark - Delegate
//MARK:UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage])
    {
        NSString *msg = [textField isEqual:_authorField]?@"笔名不能包含表情符号!":@"标题不能包含表情符号!";
        [PSTipsView showTips:msg];
        return NO;
    }
    if (string.length>0&&self.hasWords) {
        [NSMutableAttributedString xzt_makeWordsAnotherColor:string color:[UIColor redColor] view:textField];
        return NO;
    }
    return YES;
}
//限制数字
- (void)textFiledChanged:(UITextField *)textFiled{
    if ([textFiled isEqual:_authorField]) {
        [SDTextLimitTool restrictionInputTextField:textFiled maxNumber:6];
    } else if ([textFiled isEqual:_articleTitleField]) {
        [SDTextLimitTool restrictionInputTextField:textFiled maxNumber:20];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:_authorField]) {
        if ([NSString hasEmoji:textField.text]||[NSString stringContainsEmoji:textField.text]) {
            NSString *msg = [textField isEqual:_authorField]?@"笔名不能包含表情符号!":@"标题不能包含表情符号!";
            [PSTipsView showTips:msg];
        }
    }
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
        _authorField.font = FontOfSize(14);
        _authorField.textColor = UIColorFromRGB(51,51,51);
        _authorField.placeholder = @"请输入笔名,不能超过六位数";
        _authorField.delegate = self;
        [_authorField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
            _authorLab.text = @"作者笔名";
//            if (x.length>6) {
//                _authorField.text = [x substringToIndex:6];
//                [PSTipsView showTips:@"笔名不能超过6个字!"];
//            }
        }];
        [_authorField addTarget:self action:@selector(textFiledChanged:) forControlEvents:UIControlEventEditingChanged];
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
        _articleTitleField.placeholder = @"请输入标题,不能超过20个字";
        _articleTitleField.delegate = self;
        [_articleTitleField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
            _articleTitleLab.text = @"文章标题";
//            if (x.length>20) {
//                _articleTitleField.text = [x substringToIndex:20];
//                [PSTipsView showTips:@"标题不能超过20个字!"];
//            }
        }];
        [_articleTitleField addTarget:self action:@selector(textFiledChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _articleTitleField;
}

-(RZRichTextView*)articleContent {
    if (!_articleContent) {
        _articleContent = [[RZRichTextView alloc] init];
        _articleContent.placeholder = @"请输入正文，字数限制为100-20000字";
        _articleContent.font = FontOfSize(14);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle setFirstLineHeadIndent:20];
        [paragraphStyle setLineSpacing:10];
        _articleContent.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraphStyle;
        @weakify(self);
        @weakify(_articleContent);
        [_articleContent setRz_textViewDidEndEditing:^(RZRichTextView * _Nonnull textView) {
            @strongify(self);
            @strongify(_articleContent);
            PSPublishArticleViewModel *viewModel = (PSPublishArticleViewModel *)self.viewModel;
            viewModel.content = textView.text;
            if ([NSString hasEmoji:textView.text]||[NSString stringContainsEmoji:textView.text]) {
                NSString *msg = NSLocalizedString(@"Can't enter expressions!", @"不能输入表情！");
                [PSTipsView showTips:msg];
            }
            textView.selectedRange = NSMakeRange(0, 0);
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setFirstLineHeadIndent:0];
            [paragraphStyle setLineSpacing:10];
            _articleContent.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraphStyle;
        
        }];
        
        [_articleContent setRz_textViewDidBeginEditing:^(RZRichTextView * _Nonnull textView) {
            textView.selectedRange = NSMakeRange(0, 0);
            @strongify(_articleContent);
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//            [paragraphStyle setFirstLineHeadIndent:20];
            [paragraphStyle setLineSpacing:10];
            _articleContent.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraphStyle;
            if (textView.text.length<=0) {
                textView.selectedRange = NSMakeRange(0, 0);
            }
        }];
        
        
        _articleContent.rz_shouldChangeTextInRange = ^BOOL(RZRichTextView * _Nonnull textView, NSRange inRange, NSString * _Nonnull replacementText) {
            @strongify(_articleContent);
            @strongify(self);
            if (textView.text.length<=0) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                [paragraphStyle setFirstLineHeadIndent:0];
                [paragraphStyle setLineSpacing:10];
                _articleContent.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraphStyle;
                textView.selectedRange = NSMakeRange(0, 0);
            } else {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//                [paragraphStyle setFirstLineHeadIndent:20];
                [paragraphStyle setLineSpacing:10];
                _articleContent.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraphStyle;
            }
            if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
                NSString *msg = NSLocalizedString(@"Can't enter expressions!", @"不能输入表情！");
                [PSTipsView showTips:msg];
                return NO;
            } else {
                if (replacementText.length>0&&self.hasWords) {
                    [NSMutableAttributedString xz_makeWordsAnotherColor:replacementText color:[UIColor redColor] view:_articleContent];
                    return NO;
                }
                return YES;
            }
        };
    }
    return _articleContent;
}









@end
