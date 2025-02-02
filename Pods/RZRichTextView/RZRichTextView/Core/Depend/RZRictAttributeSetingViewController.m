//
//  RZRictAttributeSetingViewController.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRictAttributeSetingViewController.h"
#import <Masonry/Masonry.h>
#import "RZRichTextConfigureManager.h"
#import "RZRTSliderView.h"
#import "RZRTColorView.h"
#import "UIView+RZFrame.h"
#import "RZRTParagraphView.h"
#import "RZRichTextProtocol.h"
#import "RZRTShadowView.h"
#import "RZRTURLView.h"

@interface RZRictAttributeSetingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL dismiss;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *contenView;


@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) NSMutableArray *viewsDataSource;

@property (nonatomic, strong) RZRTSliderView *slider;
@property (nonatomic, assign) CGFloat sliderMinValue;
@property (nonatomic, assign) CGFloat sliderMaxValue;
@property (nonatomic, assign) CGFloat sliderValue;
@property (nonatomic, copy) void(^didRZRTSliderValueChanged)(CGFloat value);
@property (nonatomic, copy) void(^didRZRTSliderComplete)(CGFloat value);

@property (nonatomic, strong) RZRTColorView *colorView;
@property (nonatomic, copy) void(^didColorChanged)(UIColor *color);
@property (nonatomic, copy) void(^didColorComplete)(UIColor *color);
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) RZRTParagraphView *paragraphView;
@property (nonatomic, copy) void(^didParagraphChanged)(NSMutableParagraphStyle *paragraph);
@property (nonatomic, copy) void(^didParagraphComplete)(NSMutableParagraphStyle *paragraph);
@property (nonatomic, strong) NSMutableParagraphStyle *paragraph;

@property (nonatomic, strong) RZRTShadowView *shadowView;
@property (nonatomic, copy) void(^didShadowChanged)(NSShadow *shadow);
@property (nonatomic, copy) void(^didShadowComplete)(NSShadow *shadow);
@property (nonatomic, strong) NSShadow *shadow;

@property (nonatomic, strong) RZRTURLView *urlView;
@property (nonatomic, copy) void(^didUrlComplete)(NSAttributedString *urlString);
@property (nonatomic, strong) NSAttributedString *urlString;

@property (nonatomic, assign) CGFloat tableViewHeight;

@end

@implementation RZRictAttributeSetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    self.contenView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contenView.x = self.view.frame.size.width;
    [self.view addSubview:self.contenView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.contenView addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.masksToBounds = NO;
    
    _viewsDataSource = @[].mutableCopy;
    if (self.didRZRTSliderValueChanged) {
        [_viewsDataSource addObject:self.slider];
    }
    if (self.didColorChanged) {
        [_viewsDataSource addObject:self.colorView];
    }
    if (self.didShadowChanged) {
        [_viewsDataSource addObject:self.shadowView];
    }
    if (self.didParagraphChanged) {
        [_viewsDataSource addObject:self.paragraphView];
    }
    
    if (self.didUrlComplete) {
        [_viewsDataSource addObject:self.urlView];
    }
    
    __block CGFloat height = 150;
    [_viewsDataSource enumerateObjectsUsingBlock:^(UIView <RZRTViewDelegate> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        height += obj.viewHeight;
    }];
    self.tableViewHeight = height;
    
    [self setTableViewHeight];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)deviceChangeOrientation:(id)sender {
    CGRect frame = self.contenView.frame;
    frame.size = self.view.size;
    self.contenView.frame = frame;
    
    [self setTableViewHeight];
}

- (void)setTableViewHeight {
    CGFloat height = self.tableViewHeight;
    if (height > self.view.frame.size.height - (rz_iPhone_liuhai? 74:0)) {
        height = self.view.frame.size.height - (rz_iPhone_liuhai? 74:0);
    }
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contenView);
        make.width.equalTo(self.contenView).offset(-20);
        make.height.equalTo(@(height));
    }];
}

- (void)sliderValue:(CGFloat)value min:(CGFloat)min max:(CGFloat)max didSliderValueChanged:(void (^)(CGFloat))changed complete:(nonnull void (^)(CGFloat))complete {
    self.sliderValue = value;
    self.sliderMinValue = min;
    self.sliderMaxValue = max;
    self.didRZRTSliderValueChanged = changed;
    self.didRZRTSliderComplete = complete;
}

- (void)color:(UIColor *)color didChanged:(void(^)(UIColor *color))coloChanged complete:(void(^)(UIColor *color))complete {
    self.didColorChanged = coloChanged;
    self.didColorComplete = complete;
    self.color = color;
}

- (void)pargraph:(NSMutableParagraphStyle *)paragraph didChanged:(void(^)(NSMutableParagraphStyle *paragraph))paragraphChanged complete:(void(^)(NSMutableParagraphStyle *paragraph))complete {
    self.paragraph = paragraph;
    self.didParagraphChanged = paragraphChanged;
    self.didParagraphComplete = complete;
}

- (void)shadow:(NSShadow *)shadow didChanged:(void (^)(NSShadow * _Nonnull))shadowChanged complete:(void (^)(NSShadow * _Nonnull))complete {
    self.shadow = shadow;
    self.didShadowChanged = shadowChanged;
    self.didShadowComplete = complete;
}

- (void)urlString:(NSAttributedString *)urlString didEditComplete:(void(^)(NSAttributedString *urlString))complete {
    self.urlString = urlString;
    self.didUrlComplete = complete;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contenView.x = 0;
    } completion:^(BOOL finished) {
        self.tableView.scrollEnabled = self.tableView.contentSize.height > self.tableView.frame.size.height ? YES:NO;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.dismiss) {
        return ;
    }
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contenView.y = self.view.frame.size.height;
        self.view.alpha = 0.4;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)cancelBtnClicked:(UIButton *)sender {
    self.dismiss = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)comfirmBtnClicked:(UIButton *)sender {
    if (self.didRZRTSliderComplete) {
        self.didRZRTSliderComplete(_slider.slider.value);
    }
    if (self.didColorComplete) {
        self.didColorComplete(_colorView.color);
    }
    if (self.didParagraphComplete) {
        self.didParagraphComplete(_paragraphView.paragraph);
    }
    if (self.didShadowComplete) {
        self.didShadowComplete(_shadowView.shadow);
    }
    if (self.didUrlComplete) {
        self.didUrlComplete(_urlView.urlString);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewsDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView<RZRTViewDelegate> *obj = self.viewsDataSource[indexPath.row];
    return [obj viewHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *idf = [NSString stringWithFormat:@"cell%@", @(indexPath.row)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idf];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.viewsDataSource[indexPath.row]];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_displayLabel) {
        return 55;
    }
    if (_textView) {
        return 100;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.topView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.bottomView;
}


- (UILabel *)displayLabel {
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] init];
        _displayLabel.textAlignment = NSTextAlignmentCenter;
        _displayLabel.backgroundColor = [UIColor whiteColor];
        _displayLabel.font = [UIFont systemFontOfSize:20];
    }
    return _displayLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.scrollEnabled = NO;
        _textView.textContainerInset = UIEdgeInsetsZero;
    }
    return _textView;
}

- (UIView *)topView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    if (_displayLabel) {
        [view addSubview:self.displayLabel];
        [self.displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(view).offset(-15);
            make.centerX.equalTo(view);
            make.width.mas_lessThanOrEqualTo(view);
        }];
    }
    if (_textView) {
        [view addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(view);
            make.centerX.equalTo(view);
            make.width.equalTo(view);
            make.height.equalTo(@(100));
        }];
        view.height = 100;
    }
 
    view.layer.masksToBounds = NO;
    return view;
}

- (UIView *)bottomView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];

    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:self.confirmBtn];
    [self.confirmBtn setBackgroundImage:k_rz_richImage(@"rz_qr_btn") forState:UIControlStateNormal];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view).offset(10);
        make.width.height.equalTo(@80);
        make.bottom.equalTo(view).offset(-10);
    }];
    [self.confirmBtn addTarget:self action:@selector(comfirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:self.cancelBtn];
    [self.cancelBtn setImage:k_rz_richImage(@"rz_down") forState:UIControlStateNormal];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmBtn);
        make.right.equalTo(self.confirmBtn.mas_left).offset(-40);
        make.width.height.equalTo(@50);
    }];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}


- (RZRTSliderView *)slider {
    if (!_slider) {
        _slider = [[RZRTSliderView alloc] init];
        _slider.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, _slider.viewHeight);
        _slider.backgroundColor = [UIColor whiteColor];
        _slider.slider.minimumValue = self.sliderMinValue;
        _slider.slider.maximumValue = self.sliderMaxValue;
        _slider.slider.value = self.sliderValue;
        rz_weakObj(self);
        _slider.valueChanged = ^(CGFloat value) {
            selfWeak.sliderValue = value;
            if (selfWeak.didRZRTSliderValueChanged) {
                selfWeak.didRZRTSliderValueChanged(value);
            }
        };
    }
    return _slider;
}

- (RZRTColorView *)colorView {
    if (!_colorView) {
        _colorView = [[RZRTColorView alloc] init];
        _colorView.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, _colorView.viewHeight);
        _colorView.color = self.color;
        rz_weakObj(self);
        _colorView.didSelectedColor = ^(UIColor * _Nonnull color) {
            selfWeak.color = color;
            if (selfWeak.didColorChanged) {
                selfWeak.didColorChanged(color);
            }
        };
    }
    return _colorView;
}

- (RZRTParagraphView *)paragraphView {
    if (!_paragraphView) {
        _paragraphView = [[RZRTParagraphView alloc] init];
        _paragraphView.paragraph = self.paragraph;
        _paragraphView.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, _paragraphView.viewHeight);
        rz_weakObj(self);
        _paragraphView.didChangeParagraph = ^(NSMutableParagraphStyle * _Nonnull paragraph) {
            selfWeak.paragraph = paragraph;
            if (selfWeak.didParagraphChanged) {
                selfWeak.didParagraphChanged(paragraph);
            }
        };
    }
    return _paragraphView;
}

- (RZRTShadowView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[RZRTShadowView alloc] init];
        _shadowView.shadow = self.shadow;
        _shadowView.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, _shadowView.viewHeight);
        rz_weakObj(self);
        _shadowView.didChangeShadow = ^(NSShadow * _Nonnull shadow) {
            selfWeak.shadow = shadow;
            if (selfWeak.didShadowChanged) {
                selfWeak.didShadowChanged(shadow);
            }
        };
    }
    return _shadowView;
}

- (RZRTURLView *)urlView {
    if (!_urlView) {
        _urlView = [[RZRTURLView alloc] init];
        _urlView.urlString = self.urlString;
        _urlView.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, _urlView.viewHeight);
        rz_weakObj(self);
        _urlView.didURLEditComplete = ^(NSAttributedString * _Nonnull urlString) {
            selfWeak.urlString = urlString;
        };
    }
    return _urlView;
}

@end
