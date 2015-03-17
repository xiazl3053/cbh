//
//  MoreListWebViewController.m
//  customer
//
//  Created by 周晓 on 13-8-23.
//  Copyright (c) 2013年 yuyin. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD+Add.h"
#import "ShareViewController.h"
#import "XinWenHttpMgr.h"
#import "NoticeOperation.h"

@interface WebViewController (){
    UIWebView *_myWebView;//webview控件
    UIView *_loadView;//加载view
    UIView *_reLoadview;//重载view
}

@end

@implementation WebViewController


-(id)initWithAdId:(NSString *)adId type:(NSString *)type url:(NSString *)url{
    if (self=[super init]) {
        self.adId=adId;
        self.type=type;
        self.url=url;
    }
    return self;
}

-(id)initWithUrl:(NSString *)url
{
    if (self=[super init]) {
        self.url=url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化控件和变量
    [self initViewParams];
    //请求广告详情接口
    [self getAdDetail];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  ---------自定义方法----------------
#pragma mark 初始化控件和变量
-(void)initViewParams{
    //标题栏
    UIView *top=[self Title:self.title returnType:1];
    
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    //创建uiwebView
    UIWebView *web=[[UIWebView alloc] initWithFrame:CGRectMake(0,top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-top.frame.size.height-20)];
    [self.view addSubview:web];
    web.backgroundColor=[UIColor clearColor];
    web.opaque=NO;//背景不透明设置为NO
    web.scalesPageToFit=YES;
    web.delegate=self;
    _myWebView=web;
    
    UIButton* moreButtom=[UIButton buttonWithType:UIButtonTypeCustom];
    moreButtom.frame=CGRectMake(top.frame.size.width-40, 5, 40, 40);
    moreButtom.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    [moreButtom setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [moreButtom setImage:[UIImage imageNamed:@"settings_selected"] forState:UIControlStateHighlighted];
    [moreButtom addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:moreButtom];
}


#pragma mark 更多按钮的点击事件
-(void)moreButtonClicked:(UIButton*)sender
{
    UIActionSheet* actionSheet=[[UIActionSheet alloc]initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"分享",@"刷新",@"用Safari打开", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:self.view];
}

#pragma mark 获取广告详情接口数据
-(void)getAdDetail{
    
    _loadView=[[NoticeOperation getId] getLoadView:self.view imageName:@"alert_load"];
    
    if(self.adId&&self.type)
    {
        XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
        hmgr.hh.wvc=self;
        [hmgr adDetailWithAdId:self.adId type:self.type];
    }
    else if (self.url)
    {
        [self webviewLoadWithUrl:self.url];
    }
}

#pragma mark 获取广告详情数据后的处理
-(void)getAdDetailHandle:(AdDetaiModel *)adtm{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!adtm) {
            if (_loadView) {
                [[NoticeOperation getId] viewFaceOut:_loadView];
            }
            
            _reLoadview=[[NoticeOperation getId] getReLoadview:self.view obj:self imageName:@"alert_load"];
            
        }else{
            self.adtm=adtm;
            _url=[NSString stringWithFormat:@"%@",adtm.adUrl];
            NSString *url=[NSString stringWithFormat:@"%@",adtm.adUrl];
            [self webviewLoadWithUrl:url];
        }
    });
}

#pragma mark webview加载网页
-(void)webviewLoadWithUrl:(NSString *)url{
    if (url!=nil&&![url isEqualToString:@""]) {//有url就加载
        if (_type&&[_type isEqual:@"6"]) {//活动页才能拼该参数
            url=[url stringByAppendingString:@"&platform=ios"];//内嵌打开网页
        }
        NSURL *url1=[NSURL URLWithString:url];
        NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url1];
        [_myWebView loadRequest:request];
        [_myWebView setUserInteractionEnabled:YES];

    }
}


#pragma mark 分享
-(void)shareBtn{
    if (!self.adtm) {
        return;
    }
    
    ShareViewController *svc=[[ShareViewController alloc] initWithTitle:self.adtm.adTitle  url:self.adtm.adUrl icon:self.adtm.sharePic controller:self];
    [self addChildViewController:svc];
    [self.view addSubview:svc.view];
}


#pragma mark - --------以下为uiwebview的代理方法--------------

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //[MBProgressHUD showMessag:@"正在加载..." toView:self.view];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (_loadView) {
        [[NoticeOperation getId] viewFaceOut:_loadView];
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    //[MBProgressHUD showError:@"网页维护中..." toView:self.view];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //分享
            [self shareBtn];
            break;
        case 1:
        {
            [self refreshPageEvent];
        }
            break;
        case 2:
        {
            NSURL *url=[NSURL URLWithString:_url];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
            
        default:
            
            break;
    }
}

#pragma mark - PageBarDelegate

-(void)refreshPageEvent
{
    NSString* js=@"location.reload()";
    [_myWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}

-(void)pageGoBackEvent
{
    NSString* js=@"history.back()";
    [_myWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}

-(void)pageGoForWardEvent
{
    NSString* js=@"history.forward()";
    [_myWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
}


#pragma mark 点击重新加载数据
-(void)clickReload{
    if (_reLoadview) {
        [_reLoadview removeFromSuperview];
    }
    //重新加载数据
    [self getAdDetail];
}

@end
