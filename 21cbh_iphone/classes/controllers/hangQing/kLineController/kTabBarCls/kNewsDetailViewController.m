//
//  kNewsDetailViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-4-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kNewsDetailViewController.h"
#import "loadingView.h"
#import "CommonOperation.h"
#import "DCommon.h"

@interface kNewsDetailViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    loadingView *_loadView;// 加载视图
    NSString *_url;// 个股新闻接口
    CommonOperation *_co;
    UITapGestureRecognizer *_tapGesture;
}

@end

@implementation kNewsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// 初始化视图
    [self initView];
    // 加载PDF文件
    [self loadDocument];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self free];
}

#pragma mark 返回主视图
-(void)returnBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --------------------自定义方法------------------
#pragma mark 初始化控制器
-(id)initNoticeWithArticleId:(NSString*)articleId andkId:(NSString*)kId andkType:(NSString*)type{
    self = [super init];
    if (self) {
        self.column = @"2";
        self.articleId = articleId;
        self.kId = kId;
        self.kType = [type intValue];
        // 初始化视图
        [self initView];
        // 加载PDF文件
        [self loadDocument];
    }
    return self;
}

-(void)free{
    [_webView removeGestureRecognizer:_tapGesture];
    [self.view removeAllSubviews];
    _loadView = nil;
    _webView = nil;
    _co = nil;
    _tapGesture = nil;
}
#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = kMarketBackground;
    _co = [[CommonOperation alloc] init];
    self.view.backgroundColor = kMarketBackground;
    [self.transformImage removeFromSuperview];
    
    [self setTopTitle];
}

-(void)setTopTitle{
    if (self.kName) {
        _tapGesture = [[UITapGestureRecognizer alloc] init];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
        [_tapGesture addTarget:self action:@selector(webViewScrollToTop)];
        NSString *title = @"新闻";
        if ([self.column isEqualToString:@"0"]) {
            title = [[NSString alloc] initWithFormat:@"%@-新闻",self.kName];
        }
        if ([self.column isEqualToString:@"1"]) {
            title = [[NSString alloc] initWithFormat:@"%@-情报",self.kName];
        }
        if ([self.column isEqualToString:@"2"]) {
            title = [[NSString alloc] initWithFormat:@"%@-公告",self.kName];
        }
        [self initTitle:title returnType:0];
        // 点击手势
        [self.topView addGestureRecognizer:_tapGesture];
        // 移除一些按钮
        for (int i=0;i<self.topView.subviews.count-2;i++) {
            UIView *item = (UIView*)[self.topView.subviews objectAtIndex:i];
            [item removeFromSuperview];
        }
        // 添加一根分割线
        UIView *line = [DCommon drawLineWithSuperView:self.topView position:NO];
        line.backgroundColor = UIColorFromRGB(0x808080);
        if (_webView) {
            _webView.frame = CGRectMake(0,self.topView.frame.size.height+self.topView.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height - (self.topView.frame.size.height+self.topView.frame.origin.y));
        }
    }
    
}
-(void)webViewScrollToTop{
    [_webView.scrollView setScrollsToTop:YES];
}
#pragma mark 加载pdf文件
-(void)loadDocument
{
    
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                               self.topView.frame.size.height+self.topView.frame.origin.y,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height - (self.topView.frame.size.height+self.topView.frame.origin.y))];
        _webView.delegate = self;
        _webView.backgroundColor = kMarketBackground;
        _webView.opaque = NO;
        _webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [self.view addSubview:_webView];
    }
//    _url = [[NSString alloc] initWithFormat:@"http://api.21cbh.com/api.php?m=kNewsDetail/kNewsDetail.smpauth&version=%@&clientType=%d&column=%@&articleId=%@&kId=%@&kType=%d",[_co getVersion],kClientType,self.column,self.articleId,self.kId,self.kType];
    _url = [[NSString alloc] initWithFormat:@"%@kNewsDetail/kNewsDetail.smpauth&version=%@&clientType=%d&column=%@&articleId=%@&kId=%@&kType=%d",kBaseURL,[_co getVersion],kClientType,self.column,self.articleId,self.kId,self.kType];
    NSURL *weburl = [NSURL URLWithString:_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:weburl];
    [_webView loadRequest:request];
    
}


#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadView) {
        CGFloat lw = 150;
        CGFloat lh = 100;
        _loadView = [[loadingView alloc] initWithTitle:@"数据加载中..." Frame:CGRectMake((self.view.frame.size.width-lw)/2, self.view.frame.size.height/2, lw, lh) IsFullScreen:YES];
        [self.view addSubview:_loadView];
    }
    
}
#pragma mark 是否显示加载视图
-(void)hideLoadingView:(BOOL)yes{
    _loadView.hidden = yes;
    if (yes) {
        [_loadView stop];
    }
    else{
        [_loadView start];
    }
    
}

#pragma mark -----------------------------webView代理的实现-----------------------------
-(void)webViewDidStartLoad:(UIWebView *)webView{
    // 开始加载在次webview上建个加载视图
    [self addLoadingView];
    [self hideLoadingView:NO];
}
#pragma mark 网页加载完毕
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self hideLoadingView:YES];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (!self.kName) {
        self.kName = title;
        [self setTopTitle];
    }
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self hideLoadingView:YES];
}

@end