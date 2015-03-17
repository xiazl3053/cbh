//
//  MarketStatisticsViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "MarketViewController.h"
#import "FileOperation.h"
#import "MLNavigationController.h"
#import "tabButton.h"
#import "transformImageView.h"
#import "SearchStocksViewController.h"
#import "CommonOperation.h"
#import "DCommon.h"

@interface MarketViewController ()
{
    UIView *top;
}

@end

@implementation MarketViewController

- (void)viewDidLoad
{
    //[super viewDidLoad];
    // 视图初始化
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    self.main.delegate = self;
    [super viewWillAppear:animated];
    // 防止状态了被隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.view.backgroundColor = kMarketBackground;
}

-(void)viewDidAppear:(BOOL)animated{
    // 初始化子视图
    [self initSubViews];
}

-(void)viewDidDisappear:(BOOL)animated{

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //self.view = nil;
}

-(void)dealloc{
    self.transformImage = nil;
    self.tabButtonView = nil;
}

#pragma mark ---------------------------自定义方法------------------------

#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor = kMarketBackground;
    // 头部
    top = [self Title:@"行情中心" returnType:2];
    [self.view addSubview:top];
    // 隐藏返回按钮
    for (UIView *item in top.subviews) {
        if ([item class]!=[UILabel class]) {
            [item removeFromSuperview];
        }
    }
    // 搜索按钮
    UIImage *btBg = [UIImage imageNamed:@"D_Search.png"];
    UIImage *btBgHover = [UIImage imageNamed:@"D_SearchHover.png"];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"D_SearchHover@2x" ofType:@"png"];
    UIImage *image=[UIImage imageWithContentsOfFile:path];
    self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(top.frame.size.width-image.size.width-10,
                                                                        (top.frame.size.height-image.size.height)/2,
                                                                        image.size.width,
                                                                        image.size.height)];
    [self.searchButton setImage:btBg forState:UIControlStateNormal];
    [self.searchButton setImage:btBgHover forState:UIControlStateHighlighted];
    [self.searchButton addTarget:self action:@selector(clickSearchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:self.searchButton];
    
    // 添加刷新旋转图片
    self.transformImage = [[transformImageView alloc] initWithFrame:CGRectMake(240, self.searchButton.frame.origin.y-2, 0, 0)];
    
    [top addSubview:self.transformImage];
    // 添加一根分割线
    UIView *line = [DCommon drawLineWithSuperView:top position:NO];
    line.backgroundColor = UIColorFromRGB(0x8d8d8d);
}

#pragma mark 初始化子视图
-(void)initSubViews{
    self.view.backgroundColor = kMarketBackground;
    CGFloat x = 0;
    CGFloat y = top.frame.size.height+top.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height;
    if (!self.tabButtonView) {
        // 添加行情分类
        self.tabButtonView = [[tabButton alloc] initWithSuperController:self andFrame:CGRectMake(x,y,w,h)];
        [self.view addSubview:self.tabButtonView];
    }
    
}

#pragma mark 点击按钮向下
-(void)bottomDown:(UIView *)bottom{
    // 共享改变的高度值
    [DCommon setChangeHeight:61];
    [self.tabButtonView changeViewFrameWithTag:self.tabButtonView.currentTag];
    NSLog(@"---DFM---底部导航栏收缩,%@",NSStringFromCGRect(self.view.frame));
}
#pragma mark 点击按钮向上
-(void)bottomUp:(UIView *)bottom{
    // 共享改变的高度值
    [DCommon setChangeHeight:0];
    [self.tabButtonView changeViewFrameWithTag:self.tabButtonView.currentTag];
    NSLog(@"---DFM---底部导航栏伸展,%@",NSStringFromCGRect(self.view.frame));
}

#pragma mark 搜索按钮点击事件
-(void)clickSearchButtonAction:(UIButton*)button{
    SearchStocksViewController *searchView = [[SearchStocksViewController alloc] init];
    [self.navigationController pushViewController:searchView animated:YES];
    searchView = nil;
}




@end
