//
//  AboutViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-26.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "AboutViewController.h"
#import "CollectCustomView.h"
#import "NCMConstant.h"
#import "NoticeOperation.h"

@interface AboutViewController (){

    UIView *_top;
    UIView *_bgView;
    UIWebView *_webView;
}

@end

@implementation AboutViewController

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
    [self initViews];
    
    
}

-(void)initViews{
    [self initNavigationBar];
   // [self initBGView];
    [self initWebView];
   // [self initCoreText];

}

#pragma mark -初始化背景View
-(void)initBGView{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(reLoadWeb)];
    tap.numberOfTapsRequired=1;
    
    UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, _top.frame.size.height+_top.frame.origin.y, 320, KScreenSize.height-_top.frame.size.height-_top.frame.origin.y)];
    // bgView.backgroundColor=[UIColor greenColor];
    bgView.backgroundColor=kBgcolor;
    [bgView addGestureRecognizer:tap];
    _bgView=bgView;
    
    UIImageView *img=[[UIImageView alloc]init];
    img.frame=CGRectMake((bgView.frame.size.width-239)*.5, (bgView.frame.size.height-34)*.5, 239, 34);
    img.image=[UIImage imageNamed:@"alert_load.png"];
    [bgView addSubview:img];
    
    UILabel *label=[[UILabel alloc]init];
    label.frame=CGRectMake((bgView.frame.size.width-200)*.5, img.bottom, 200, 30);
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=UIColorFromRGB(0X808080);
    label.text=@"点击屏幕,重新加载";
    [bgView addSubview:label];
    
    [self.view addSubview:bgView];
    
}

#pragma mark -加载View
-(void)reLoadWeb{
    NSURL *url=[NSURL URLWithString:KAppAboutUrl];
    NSURLRequest *quest=[NSURLRequest requestWithURL:url];
    [_webView loadRequest:quest];
}

#pragma mark -test
-(void)initCoreText{

    CollectCustomView *view=[[CollectCustomView alloc]initWithFrame:CGRectMake(0, _top.bottom, self.view.frame.size.width, self.view.frame.size.height-_top.bottom)];
    NSLog(@"aboutVC.frame=%@",NSStringFromCGRect(view.frame));
   // view.backgroundColor=[UIColor whiteColor];
    
    [self.view addSubview:view];
    

}
#pragma mark -初始化NavigationBar
-(void)initNavigationBar{
    UIView *top=[self Title:@"关于" returnType:1];
    _top =top;
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
}
#pragma mark -初始化WebView
-(void)initWebView{
    UIWebView *web=[[UIWebView alloc]initWithFrame:CGRectMake(0, _top.bottom, self.view.frame.size.width, 0)];
    web.delegate=self;
    _webView=web;
    [self.view addSubview:web];
    [self reLoadWeb];
}

#pragma mark -webDelegate方法
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [_bgView removeFromSuperview];
    _webView.frame=CGRectMake(0, _top.bottom, self.view.frame.size.width, self.view.frame.size.height-_top.bottom);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_bgView removeFromSuperview];
    [self initBGView];
    NoticeOperation *notice=[[NoticeOperation alloc]init];
    [notice showAlertWithMsg:KNoticeLoadAboutFailTitle imageName:KNoticeLoadAboutFailIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
}

#pragma mark -Dealloc方法
-(void)dealloc{
    NSLog(@"------------About----------delloc");
    _top=nil;
    _bgView=nil;
    _webView=nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
