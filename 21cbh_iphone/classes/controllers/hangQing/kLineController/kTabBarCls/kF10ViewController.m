//
//  kF10ViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kF10ViewController.h"
#import "baseTableView.h"
#import "basehqCell.h"
#import "hangqingHttpRequest.h"
#import "kTabbarController.h"
#import "CommonOperation.h"
#import "loadingView.h"

#define kDCellHeight 360
#define kDDownArrowsPng [UIImage imageNamed:@"ms_in.png"]
#define kDUpArrowsPng [UIImage imageNamed:@"UpAccessory.png"]
#define kDTimeInterval 0.3

@interface kF10ViewController ()<UIWebViewDelegate>{
    NSMutableArray *_data; // 请求的数据
    NSMutableArray *_sectionTitles; // 标题集合
    NSMutableArray *_sectionIds; // 标题Id集合
    hangqingHttpRequest *_request; // 请求
    CGFloat _tableHeight; // 标题的高度
    NSMutableArray *_buttons; // 按钮集合
    NSMutableArray *_images; // 箭头集合
    NSMutableArray *_states; // 按钮状态
    UIWebView *_webView; // 网页加载
    UIButton *_currentButton; // 当前点击的按钮
    CGFloat _downHeight; // 默认向下伸展的距离
    BOOL _isScrollTop; // 是否滚动到顶部
    NSString *_url;// 网址
    CommonOperation *_co ; // 公共
    loadingView *_loadView;// 加载视图
    
}

@end

@implementation kF10ViewController

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
	// 初始化参数
    [self initParam];
    // 初始化视图
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated{
    if (self.kLineView.kType>0) {
        // 更新主视图
        [self updateView];
        // 恢复原状
        [self recoverOldState];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self free];
}

#pragma mark --------------------------------自定义方法-------------------------------
-(void)free{
    // 清除请求
    [_request clearRequest];
    _request = nil;
    _data = nil;
    _co = nil;
    _webView = nil;
    [self.view removeAllSubviews];
}
-(void)show{}
-(void)clear{}
#pragma 初始化参数
-(void)initParam{
    _request = [[hangqingHttpRequest alloc] init];
    _data = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"", nil];
    _buttons = [[NSMutableArray alloc] init];
    _sectionTitles = [[NSMutableArray alloc] initWithObjects:
                      @"操盘必备",
                     // @"财报摘要",
                      @"股东情况",
                      @"主营业务",
                      @"核心题材",
                      @"机构评级",
                      @"股本情况",
                      //@"成交回报",
                      //@"大宗交易",
                      //@"融资融劵",
                      //@"管理层",
                      @"分红融资",
                      @"公司概况",
                      @"回顾展望",
                      //@"资本运作",
                      @"板块分析",
                      nil];
    _sectionIds = [[NSMutableArray alloc] initWithObjects:
                      @"0",
                      // @"1",
                      @"2",
                      @"3",
                      @"4",
                      @"5",
                      @"6",
                      //@"7",
                      //@"8",
                      //@"9",
                      //@"10",
                      @"11",
                      @"12",
                      @"13",
                      //@"14",
                      @"15",
                      nil];
    _states = [[NSMutableArray alloc] initWithObjects:
               [NSNumber numberWithBool:NO],
               //[NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               //[NSNumber numberWithBool:NO],
               //[NSNumber numberWithBool:NO],
               //[NSNumber numberWithBool:NO],
               //[NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               //[NSNumber numberWithBool:NO],
               [NSNumber numberWithBool:NO],
               nil ];
    _images = [[NSMutableArray alloc] init];
    _tableHeight = kSectionHeight * _sectionTitles.count;
    _downHeight = 100;// 向下伸展的高度
    _isScrollTop = NO; // 默认不会滚动到顶部
    //设置参数
    _co = [[CommonOperation alloc] init];
    NSString *version= [_co getVersion];
    NSString *screenType = @"3";
    _url = [[NSString alloc]initWithFormat:@"%@fTenChart/fTenChart.smpauth&version=%@&clientType=%d&screenType=%@&type=%d&kId=%@&pageColor=%@&colum=",kBaseURL,version,kClientType,screenType,self.kLineView.kType,self.kLineView.kId,@"1"];
    // 主视图滚动回调方法
    [self parentBlock];
}
#pragma mark 初始化视图
-(void)initViews{
    if (self.kLineView.kType>0) {
        // 添加webView
        [self addWebView];
        // 添加标题
        [self addTitles];
    }
    else{
        // 大盘是没有F10信息的
        UILabel *nomessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
        nomessage.text = @"该证劵暂无F10";
        nomessage.textAlignment = NSTextAlignmentCenter;
        nomessage.backgroundColor = ClearColor;
        nomessage.textColor = UIColorFromRGB(0xFFFFFF);
        [self.view addSubview:nomessage];
        nomessage = nil;
    }
}
#pragma mark 更新视图
-(void)updateView{
    UIView *lastView = (UIView*)[[self.view subviews] lastObject];
    CGFloat height = lastView.frame.size.height+lastView.frame.origin.y; // 最新高度
    if (_currentButton==[_buttons lastObject]) {
        height += _webView.frame.size.height;
    }
    NSLog(@"---DFM---更新视图高度：%f",height);
    // 更新视图的高度
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 10000);
    // 更新主视图的高度
    if (self.kLineView) {
        [self.kLineView updateMainViewHeight:height];
    }
    // 恢复当前按钮的位置
    [self recoverCurrentButton:_currentButton];
}
#pragma mark 添加webView
-(void)addWebView{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    _webView.hidden = YES;
    _webView.delegate = self;
    _webView.scrollView.scrollEnabled = NO;
    _webView.backgroundColor = kMarketBackground;
    [self.view addSubview:_webView];
}
#pragma mark 添加标题
-(void)addTitles{
    CGFloat x = 0;
    CGFloat y = 0;
    for (int i=0; i<_sectionTitles.count; i++) {
        UIButton *l = [[UIButton alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width, kSectionHeight)];
        l.backgroundColor = UIColorFromRGB(0xe1e1e1);
        [l setTitle:[_sectionTitles objectAtIndex:i] forState:UIControlStateNormal];
        l.titleLabel.font = [UIFont fontWithName:kFontName size:16];
        l.titleLabel.textAlignment = NSTextAlignmentCenter;
        [l setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
        l.userInteractionEnabled = YES;
        [_buttons addObject:l]; // 存储按钮
        // 加个点击事件
        [l addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // 加根底线
        UIView *ll = [[UIView alloc] initWithFrame:CGRectMake(x, l.frame.size.height-0.5, self.view.frame.size.width, 0.5)];
        ll.backgroundColor = UIColorFromRGB(0x000000);
        [l addSubview:ll];
        // 加个箭头
        UIImageView *iv = [[UIImageView alloc] initWithImage:kDDownArrowsPng];
        iv.frame = CGRectMake(l.frame.size.width-kDDownArrowsPng.size.width-15,
                              (l.frame.size.height-kDDownArrowsPng.size.height)/2,
                              kDDownArrowsPng.size.width,
                              kDDownArrowsPng.size.height);
        iv.layer.transform = CATransform3DMakeRotation(M_PI * 0.0f / 180.0f, 0.0f, 0.0f, 1.0f);
        // 箭头加入集合
        [_images addObject:iv];
        [l addSubview:iv];
        [self.view addSubview:l];
        ll = nil;
        l = nil;
        y+=kSectionHeight;
    }
    
    // 更新视图
    [self updateView];
}

#pragma mark 标题点击事件
-(void)clickButtonAction:(UIButton*)button{
    _currentButton = nil;
    // 收起所有标题
    [self recoverAll:button];
    // 移动到此按钮处
    /******change*******/
    //[self scrollToTop:button];
    // 标题收缩动画
    [self animationForButton:button];
    // 更新视图 这里延迟执行，以防滚动太快
    [self performSelector:@selector(updateView) withObject:Nil afterDelay:kDTimeInterval];
    // 记录当前按钮
    _currentButton = button;
    _isScrollTop = YES;
    self.kLineView.isFix = NO;
}

#pragma mark 按钮集合的特效
-(void)animationForButton:(UIButton*)button{
    // 如果没有展开则展开
    if (![[_states objectAtIndex:[_buttons indexOfObject:button]] boolValue]) {
        BOOL isDown = YES; // 按钮是否向下伸展
        // 首先按顺序收缩按钮
        for (int i=_buttons.count-1;i>=0;i--) {
            UIButton *item = (UIButton*)[_buttons objectAtIndex:i];
            // 当前按钮的下一个按钮开始伸展
            if (item==button) {
                isDown = NO;
                // 在他下面显示一个webView
                _webView.hidden = NO;
                NSURL *url = [NSURL URLWithString:[_url stringByAppendingString:[NSString stringWithFormat:@"%@",[_sectionIds objectAtIndex:i]]]];
                NSLog(@"---DFM---%@",url);
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                _webView.frame = CGRectMake(0, button.frame.size.height+button.frame.origin.y, _webView.frame.size.width, _downHeight);
                _webView.delegate = self;
                _webView.backgroundColor = ClearColor;
                _webView.opaque = NO;
                [_webView loadRequest:request];
            }
            // 向下伸展特效
            if (isDown && item!=button) {
                item.frame = CGRectMake(item.frame.origin.x, item.frame.origin.y + _downHeight, item.frame.size.width, item.frame.size.height);
            }
            item = nil;
        }
        // 设置按钮的状态为已展开
        [_states replaceObjectAtIndex:[_buttons indexOfObject:button] withObject:[NSNumber numberWithBool:YES]];
        // 箭头状态向下
        UIImageView *imageview = (UIImageView*)[_images objectAtIndex:[_buttons indexOfObject:button]];
        [UIView animateWithDuration:kDTimeInterval animations:^{
            imageview.layer.transform = CATransform3DMakeRotation(M_PI * 90.0f / 180.0f, 0.0f, 0.0f, 1.0f);
        }];
        imageview = nil;
    }else{
        // 设置按钮的状态为未展开
        [_states replaceObjectAtIndex:[_buttons indexOfObject:button] withObject:[NSNumber numberWithBool:NO]];
        UIImageView *imageview = (UIImageView*)[_images objectAtIndex:[_buttons indexOfObject:button]];
        [UIView animateWithDuration:kDTimeInterval animations:^{
            imageview.layer.transform = CATransform3DMakeRotation(M_PI * 0.0f / 180.0f, 0.0f, 0.0f, 1.0f);
        }];
        imageview = nil;
    }
}
#pragma mark 恢复当前按钮的原始位置
-(void)recoverCurrentButton:(UIButton*)button{
    if (button) {
        CGFloat x = 0;
        CGFloat y = kSectionHeight * [_buttons indexOfObject:button];
        button.frame = CGRectMake(x, y, self.view.frame.size.width, kSectionHeight);
        NSLog(@"---DFM---恢复当前按钮的位置：%f",button.frame.origin.y);
    }
    
}
#pragma mark 收起所有标题
-(void)recoverAll:(UIButton*)button{
    // 恢复webView的原始位置
    if (_webView) {
        //清除UIWebView的缓存
        [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
    }
    _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    _webView.hidden = YES;
    

    // 先收起在此按钮之下的所有标题
    // 原始xy轴
    CGFloat x = 0;
    CGFloat y = 0;
    // 先恢复原状
    for (int i=0; i<_sectionTitles.count; i++) {
        UIButton *item = (UIButton*)[_buttons objectAtIndex:i];
        if (item.frame.origin.y!=y) {
            // 恢复位置
            item.frame = CGRectMake(x, y, self.view.frame.size.width, kSectionHeight);
            // 收起三角形
            UIImageView *imageview = (UIImageView*)[_images objectAtIndex:[_buttons indexOfObject:item]];
            imageview.layer.transform = CATransform3DMakeRotation(M_PI * 0.0f / 180.0f, 0.0f, 0.0f, 1.0f);
            imageview = nil;
        }
        y+=kSectionHeight;
        item = nil;
        if (button) {
            // 将其他按钮设置为未展开状态
            if (i!=[_buttons indexOfObject:button]) {
                // 设置按钮的状态为未展开
                [_states replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    
}

#pragma mark 恢复到原始状态
-(void)recoverOldState{
    // 控制器栏默认是不固定的
    self.kLineView.isFix = YES;
    _isScrollTop = NO;
    // 标题原始状态
    [self recoverAll:nil];
    // 恢复当前按钮指针为nil
    _currentButton = nil;
    // 更新主视图
    [self updateView];
    // 展开第一项
    [self clickButtonAction:[_buttons objectAtIndex:0]];

}

-(void)scrollToTop:(UIButton*)button{
    //得到主视图滚动的Y周
    CGFloat y = self.kLineView.mainView.bounds.origin.y; // 当前y
    CGRect frame = self.kLineView.kChartController.view.frame;
    // 如果y轴已经滚动到很高则回滚
    if (y>frame.origin.y+frame.size.height) {
        [self.kLineView.mainView setContentOffset:CGPointMake(0, frame.origin.y+frame.size.height) animated:_isScrollTop];
    }
    NSLog(@"---DFM---当前的按钮位置：%f",button.frame.origin.y);
    if (_isScrollTop && button.frame.origin.y<=320) {
        // 主视图回滚到导航控制器栏哪里
        [self.kLineView.mainView setContentOffset:CGPointMake(0, frame.origin.y+frame.size.height+button.frame.origin.y+button.frame.size.height) animated:_isScrollTop];
    }else if(button.frame.origin.y>320){
        // 主视图回滚到导航控制器栏哪里
        [self.kLineView.mainView setContentOffset:CGPointMake(0, frame.origin.y+frame.size.height+button.frame.origin.y+button.frame.size.height-150) animated:_isScrollTop];
    }
    
}
#pragma mark 主视图的滚动回调
-(void)parentBlock{
    // 主视图滚动的时候会回调一个block
    __block kF10ViewController *f10 = self;
    self.kLineView.scrollBlock = ^(KLineViewController *kLineView){
        // 固定点
        CGFloat y = kLineView.mainView.bounds.origin.y; // 当前y
        CGRect btFrame = kLineView.bottomController.butonView.frame ;// 底部导航栏按钮位置原始值
        CGFloat oldY = kLineView.kChartController.view.frame.size.height+kLineView.kChartController.view.frame.origin.y + btFrame.size.height; // 底部控制器导航栏的原始Y
        y = y - oldY; // 在本视图相对移动距离
        // 当前按钮的相对Y轴
        CGFloat minY = [f10->_buttons indexOfObject:f10->_currentButton]*f10->_currentButton.frame.size.height;
        CGFloat maxY = f10->_webView.frame.size.height+f10->_webView.frame.origin.y-f10->_currentButton.frame.size.height;
        //NSLog(@"---DFM---滚动-%f minY:%f,maxY:%f",y,minY,maxY);
        // 固定在顶部
        if (f10->_currentButton) {
            if (y>=minY && y<=maxY) {
                f10->_currentButton.frame = CGRectMake(f10->_currentButton.frame.origin.x,
                                                       y,
                                                       f10->_currentButton.frame.size.width,
                                                       f10->_currentButton.frame.size.height);
            }
        }
    };

}

#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadView) {
        CGFloat lw = 100;
        CGFloat lh = 80;
        _loadView = [[loadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-lw)/2, 10, lw, lh)];
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
    // 网页自适应高度
    CGRect frame = webView.frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    CGFloat height = webView.frame.size.height;
    NSLog(@"---DFM---网页加载完毕,高度：%f",_downHeight);
    // 标题收缩动画
    BOOL isDown = YES; // 按钮是否向下伸展
    // 首先按顺序收缩按钮
    for (int i=_buttons.count-1;i>=0;i--) {
        UIButton *item = (UIButton*)[_buttons objectAtIndex:i];
        // 当前按钮的下一个按钮开始伸展
        if (item==_currentButton) {
            isDown = NO;
        }
        // 向下伸展特效
        if (isDown && item!=_currentButton) {
            // 伸展动画
            [UIView animateWithDuration:kDTimeInterval animations:^{
                item.frame = CGRectMake(item.frame.origin.x, item.frame.origin.y - _downHeight + height, item.frame.size.width, item.frame.size.height);
            }];
        }
        item = nil;
    }
    // 更新主视图
    [self updateView];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self hideLoadingView:YES];
}

@end
