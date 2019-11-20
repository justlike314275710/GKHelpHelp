//
//  PSBaseWebViewController.h
//  Start
//
//  Created by calvin on 16/7/13.
//  Copyright © 2016年 DingSNS. All rights reserved.
//

#import "PSViewController.h"
#import "PSWebViewProtocol.h"
#import <WebKit/WebKit.h>

#define UA_APPENDING @"iphone-com.sinog2c.Yuwu"

@interface PSBaseWebViewController : PSViewController <WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, strong, readonly) NSURL *url;

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *progressTrackTintColor;
@property (nonatomic, assign) BOOL enableUpdateLeftNavigationItem;//是否允许通过网页的加载来更新左导航按钮（如显示返回和关闭功能），默认为YES
@property (nonatomic, assign) BOOL enableUpdateTitle;//是否允许通过网页内容更新导航title，默认为YES

@property (nonatomic, strong) UIProgressView *progressView;
- (instancetype)initWithURL:(NSURL *)url;
- (void)reloadWithURL:(NSURL *)url;
- (void)loadWebView;

@end
