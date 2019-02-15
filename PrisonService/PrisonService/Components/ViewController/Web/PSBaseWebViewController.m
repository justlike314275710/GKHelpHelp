//
//  PSWebViewController.m
//  Start
//
//  Created by calvin on 16/7/13.
//  Copyright © 2016年 DingSNS. All rights reserved.
//

#import "PSBaseWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface PSBaseWebView : WKWebView

@property (nonatomic, assign) BOOL didKeyboardShow;

@end

@implementation PSBaseWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerKeyboardEvents];
    }
    return self;
}

- (void)dealloc {
    [self removeKeyboardEvents];
}

- (void)registerKeyboardEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _didKeyboardShow = YES;
}

- (void)keyBoardWillHidden:(NSNotification *)notification {
    _didKeyboardShow = NO;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_didKeyboardShow) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    return [super hitTest:point withEvent:event];
}

@end

@interface PSBaseWebViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSURL *url;
//@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation PSBaseWebViewController

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.enableUpdateLeftNavigationItem = YES;
        self.enableUpdateTitle = YES;
        self.url = url;
        self.progressTintColor = [UIColor colorWithRed:254 / 255.0 green:224 / 255.0 blue:102 / 255.0 alpha:1.0];
        self.progressTrackTintColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [self deleteWebCache];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"URL"];
    [_progressView removeFromSuperview];
    _webView.navigationDelegate = nil;
    _webView.scrollView.delegate = nil;
}

- (void)deleteWebCache {
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:nil];
    }
}

- (IBAction)backAction:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateNavigationItems {
    if (self.enableUpdateLeftNavigationItem) {
        if ([_webView canGoBack]) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            backButton.frame = CGRectMake(0, 0, 40, 44);
            [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
            backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            UIImage *lImage = [self leftItemImage];
            if (lImage) {
                [backButton setImage:lImage forState:UIControlStateNormal];
            }else{
                [backButton setTitle:NSLocalizedString(@"return", @"返回") forState:UIControlStateNormal];
            }
            [backButton setTitleColor:UIColorFromHexadecimalRGB(0x666666) forState:UIControlStateNormal];
            backButton.titleLabel.font = [UIFont systemFontOfSize:15];
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            closeButton.frame = CGRectMake(0, 0, 40, 44);
            [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setTitleColor:UIColorFromHexadecimalRGB(0x666666) forState:UIControlStateNormal];
            closeButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
            UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
            
            self.navigationItem.leftBarButtonItems = @[backItem,closeItem];
        }else {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            backButton.frame = CGRectMake(0, 0, 50, 44);
            [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
            backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            UIImage *lImage = [self leftItemImage];
            if (lImage) {
                [backButton setImage:lImage forState:UIControlStateNormal];
            }else{
                
                [backButton setTitle:NSLocalizedString(@"return", @"返回") forState:UIControlStateNormal];
            }
            [backButton setTitleColor:UIColorFromHexadecimalRGB(0x666666) forState:UIControlStateNormal];
            backButton.titleLabel.font = [UIFont systemFontOfSize:15];
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            self.navigationItem.leftBarButtonItems = @[backItem];
        }
    }
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    _progressView.tintColor = progressTintColor;
}

- (void)setProgressTrackTintColor:(UIColor *)progressTrackTintColor {
    _progressTrackTintColor = progressTrackTintColor;
    _progressView.trackTintColor = progressTrackTintColor;
}

- (void)updateTitle {
    if (self.enableUpdateTitle) {
        NSString *theTitle=[self.webView.title copy];
        if (theTitle.length > 10) {
            theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
        }
        self.title = theTitle;
    }
}

- (void)reloadWithURL:(NSURL *)url {
    self.url = url;
    [self loadWebView];
}

- (void)loadWebView {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* userAgent = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
   
    if ([userAgent length] == 0) {
        UIWebView* tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString* userAgent = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *newUserAgent = [NSString stringWithFormat:@"%@%@",userAgent,UA_APPENDING];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":newUserAgent}];
    }

        
    

    _webView = [[PSBaseWebView alloc] initWithFrame:CGRectZero];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, CGRectGetHeight(navigaitonBarBounds), CGRectGetWidth(navigaitonBarBounds), 0.0);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.tintColor = self.progressTintColor;
    _progressView.trackTintColor = self.progressTrackTintColor;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.navigationController.navigationBar addSubview:self.progressView];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self loadWebView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _webView) {
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            if (newprogress == 1) {
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            }else {
                self.progressView.hidden = NO;
                [self.progressView setProgress:newprogress animated:YES];
            }
        }else if ([keyPath isEqualToString:@"title"]) {
            [self updateTitle];
        }else if ([keyPath isEqualToString:@"URL"]) {
            id new = change[NSKeyValueChangeNewKey];
            id old = change[NSKeyValueChangeOldKey];
            if ([new isKindOfClass:[NSNull class]] && ![old isKindOfClass:[NSNull class]]) {
                [self.webView reload];
            }
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
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
