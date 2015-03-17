//
//  kTabbarController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-28.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kTabbarController.h"
#import "kBaseViewController.h"
#import "hangqingHttpRequest.h"
#import "kNewsViewController.h"
#import "kPanKouViewController.h"
#import "kFenXiShiViewController.h"
#import "kF10ViewController.h"
#import "DCommon.h"

#define kButtonTitleColor UIColorFromRGB(0x000000)
#define kButtonTitleCurrentColor kBrownColor
#define kButtonFont [UIFont fontWithName:kFontName size:15]

@interface kTabbarController(){
    NSMutableArray *_btTitles;
    hangqingHttpRequest *_request; // 请求
    __block int _currentButtonIndex; // 当前点击的按钮下标
    NSMutableArray *_controllers;
    kBaseViewController *_currentController; // 当前控制器
    kNewsViewController *_kNewsView; // 新闻视图
    kPanKouViewController *_kPanKouView; // 盘口视图
    kNewsViewController *_kQingBaoView; // 情报视图
    kFenXiShiViewController *_kFenXiShi; // 分析师视图
    kNewsViewController *_kNoticeView; // 公告视图
    kF10ViewController *_kF10View; // F10视图
}

@end

@implementation kTabbarController

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
    // 初始化画参数
    [self initParam];
    // 视图初始化
    [self initView];
    
    // 添加按钮
    [self addTabButton];
}

-(void)dealloc{
    [self free];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ----------------------------------自定义方法---------------------------------
-(void)free{
    if (_controllers) {
        [_controllers removeAllObjects];
        _controllers = nil;
    }
    [_currentController free];
    [_kNewsView free];
    [_kPanKouView free];
    [_kQingBaoView free];
    [_kFenXiShi free];
    [_kNoticeView free];
    [_kF10View free];
    _currentController = nil;
    _kNewsView = nil;
    _kPanKouView = nil;
    _kQingBaoView = nil;
    _kFenXiShi = nil;
    _kNoticeView = nil;
    _kF10View = nil;
    _butonView = nil;
    _btTitles = nil;
    _request = nil;
    _currentButtonIndex = 0;
    [self.view removeAllSubviews];
}
#pragma mark 界面准备好开始加载数据
-(void)startRun{
    // 默认点击第一个按钮
    [self clickButtonAction:nil];
}

#pragma mark 视图初始化
-(void)initView{
    self.view.backgroundColor = kMarketBackground;
    self.view.userInteractionEnabled = YES;
    [self.view removeAllSubviews];
}

#pragma mark 初始化参数
-(void)initParam{
    _request = [[hangqingHttpRequest alloc] init];
    _currentButtonIndex = 0;
    _controllers = [[NSMutableArray alloc] init];
}
#pragma mark 初始化控制器
-(void)initControllers{
    if (_controllers.count<=0) {
        // 新闻
        _kNewsView = [[kNewsViewController alloc] init];
        _kNewsView.newsType = @"新闻";
        _kNewsView.columnId = 0;
        _kNewsView.kLineView = self.kLineView;
        // 盘口
        _kPanKouView = [[kPanKouViewController alloc] init];
        // 情报
//        _kQingBaoView = [[kNewsViewController alloc] init];
//        _kQingBaoView.newsType = @"情报";
//        _kQingBaoView.columnId = 1;
//        _kQingBaoView.kLineView = self.kLineView;
        // 分析师
        _kFenXiShi = [[kFenXiShiViewController alloc] init];
        // 公告
        _kNoticeView = [[kNewsViewController alloc] init];
        _kNoticeView.newsType = @"公告";
        _kNoticeView.columnId = 2;
        _kNoticeView.kLineView = self.kLineView;
        // F10
        _kF10View = [[kF10ViewController alloc] init];
        
        // 添加进控制器
        [_controllers addObject:_kNewsView];
        [_controllers addObject:_kPanKouView];
        //[_controllers addObject:_kQingBaoView];
        [_controllers addObject:_kFenXiShi];
        [_controllers addObject:_kNoticeView];
        [_controllers addObject:_kF10View];
    }
    
}

#pragma mark k线切换按钮
-(void)addTabButton{
    // 添加切换按钮
    // _btTitles = [[NSMutableArray alloc] initWithObjects:@"新闻",@"盘口",@"情报",@"分析师",@"公告",@"F10", nil];
    _btTitles = [[NSMutableArray alloc] initWithObjects:@"新闻",@"盘口",@"分析师",@"公告",@"F10", nil];
    CGFloat btHeight = 40;
    CGFloat btWidth = self.view.frame.size.width / _btTitles.count;
    _butonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, btHeight)];
   // _butonView.backgroundColor = UIColorFromRGB(0x000000);
    // 导航按钮
    CGFloat x = 0;
    for (int i=0;i<_btTitles.count;i++) {
        NSString *key = [_btTitles objectAtIndex:i];
        UIButton *hqbtn = [[UIButton alloc] initWithFrame:CGRectMake(x, 0.5, btWidth,btHeight-1)];
        [hqbtn setTitle:key forState:UIControlStateNormal];
        [hqbtn setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
        [hqbtn setTitleColor:kButtonTitleCurrentColor forState:UIControlStateSelected];
        [hqbtn setTitleColor:kButtonTitleCurrentColor forState:UIControlStateHighlighted];
        [hqbtn setBackgroundColor:UIColorFromRGB(0xe1e1e1)];
        hqbtn.titleLabel.font = kButtonFont;
        hqbtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        hqbtn.tag = i;
        [hqbtn addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_butonView addSubview:hqbtn];
        hqbtn = nil;
        x += btWidth;
    }
    [self.view addSubview:_butonView];
    // 移动线
    UIView *line = [DCommon drawLineWithSuperView:_butonView position:NO];
    line.backgroundColor = kBrownColor;
    line.frame = CGRectMake(line.frame.origin.x, btHeight-4, btWidth, 4);
    
}

#pragma mark 点击k线类型切换按钮
-(void)clickButtonAction:(UIButton*)button{
    // 初始化控制器
    [self initControllers];
    // 标签处理，转换为数组下标
    NSInteger tag = button.tag;
    if (!button) {
        tag = 0;
        button = (UIButton*)[_butonView.subviews objectAtIndex:0];
    }
    // 如果是F10就不用固定了
    if (tag==_controllers.count-1) {

    }else{
        self.kLineView.isFix = YES;
    }
    // 恢复按钮原始状态
    for (int i=0;i<_btTitles.count; i++) {
        UIButton *temp = (UIButton*)[_butonView.subviews objectAtIndex:i];
        temp.backgroundColor = UIColorFromRGB(0xe1e1e1);
        [temp setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
        temp = nil;
    }
    // 高亮当前点击的按钮
    [button setTitleColor:kButtonTitleCurrentColor forState:UIControlStateNormal];
    // 移动线
    UIView *line = [_butonView.subviews lastObject];
    [UIView animateWithDuration:0.3 animations:^{
        line.frame = CGRectMake(button.frame.origin.x, line.frame.origin.y, line.frame.size.width, line.frame.size.height);
    }];
    // 切换控制器，控制器本身会自动更新父级视图的高度
    if (_currentController) {
        // 先移除视图
        [_currentController.view removeFromSuperview];
        [_currentController clear];
        _currentController = nil;
    }
    // 显示控制器
    if (tag<_controllers.count) {
        // 提取控制器
        _currentController = (kBaseViewController*)[_controllers objectAtIndex:tag];
        _currentController.kLineView = self.kLineView;
        _currentController.view.frame = CGRectMake(0, _butonView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_butonView.frame.size.height);
        // 添加视图
        [self.view addSubview:_currentController.view];
        [_currentController show];
        // 根据设定隐藏或显示上啦刷新控件
        if (tag==1 || tag==5) {
            self.kLineView.footer.hidden =YES;
        }
        else{
            self.kLineView.footer.hidden = NO;
        }
        // 把底部控制器的导航栏放到图层最前面
        [self.view sendSubviewToBack:_currentController.view];
        [self.view bringSubviewToFront:self.butonView];
    }
}

@end
