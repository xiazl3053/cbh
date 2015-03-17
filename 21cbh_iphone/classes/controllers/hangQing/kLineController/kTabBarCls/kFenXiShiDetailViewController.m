//
//  kFenXiShiDetailViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kFenXiShiDetailViewController.h"
#import "loadingView.h"
#import "FileOperation.h"
#import "DCommon.h"

@interface kFenXiShiDetailViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    loadingView *_loadView;// 加载视图
    FileOperation *_fo;
}

@end

@implementation kFenXiShiDetailViewController

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
-(void)free{
    [self.view removeAllSubviews];
    _fo = nil;
    _loadView = nil;
    _webView = nil;
}

#pragma mark 初始化视图
-(void)initView{
    [self initTitle:self.title returnType:0];
    self.view.backgroundColor = kMarketBackground;
    // 移除一些按钮
    for (int i=0;i<self.topView.subviews.count-2;i++) {
        UIView *item = (UIView*)[self.topView.subviews objectAtIndex:i];
        [item removeFromSuperview];
    }
    // 添加一根分割线
    UIView *line = [DCommon drawLineWithSuperView:self.topView position:NO];
    line.backgroundColor = UIColorFromRGB(0x808080);
    
    [self.transformImage removeFromSuperview];
    _fo = [[FileOperation alloc] init];
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
        _webView.backgroundColor = ClearColor;
        _webView.opaque = NO;
        _webView.scalesPageToFit = YES;
        _webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [self.view addSubview:_webView];
    }
    NSURL *url = [NSURL URLWithString:self.pdf];
    if ([self.pdf rangeOfString:@"http://"].length>0) {
        NSString *pdf = [self getLocalPDFWithUrl:self.pdf];
        if ([[NSFileManager new] fileExistsAtPath:pdf]) {
            // 如果本地文件存在则加载本地文件
            url = [NSURL fileURLWithPath:pdf];
        }
    }else{
        url = [NSURL fileURLWithPath:self.pdf];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    NSLog(@"---DFM---加载PDF:%@",self.pdf);
}

#pragma mark 获取本地PDF缓存地址
-(NSString*)getLocalPDFWithUrl:(NSString*)urlstr{
    NSString *pdf = urlstr;
    if ([pdf rangeOfString:@"http://"].length>0) {
        NSArray *tmp = [pdf componentsSeparatedByString:@"/"];
        pdf = [tmp lastObject];
    }
    // 放到用户沙盒 Library 缓存
    NSString * path= [_fo getFileDirWithFileDirName:@"PDF"];
    // 取最后的文件名
    path = [path stringByAppendingString:[[NSString alloc] initWithFormat:@"/%@",pdf]];
    return path;
}

#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadView) {
        CGFloat lw = 150;
        CGFloat lh = 100;
        _loadView = [[loadingView alloc] initWithTitle:@"数据加载中..." Frame:CGRectMake((self.view.frame.size.width-lw)/2, self.view.frame.size.height/2, lw, lh) IsFullScreen:YES];
        [_webView addSubview:_loadView];
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
    [_webView bringSubviewToFront:_loadView];
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

 
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self hideLoadingView:YES];
}

@end
