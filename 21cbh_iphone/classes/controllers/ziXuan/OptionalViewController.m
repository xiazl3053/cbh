//
//  Information ViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "OptionalViewController.h"
#import "SearchStocksViewController.h"
#import "CommonOperation.h"
#import "ziXuanIndexViewController.h"
#import "ziXuanManageViewController.h"
#import "DCommon.h"

#define kD_SelfMarket_Edit [UIImage imageNamed:@"D_SelfMarket_Edit.png"]
#define kD_SelfMarket_Edit_Hover [UIImage imageNamed:@"D_SelfMarket_Edit_Hover.png"]
#define kD_SelfMarket_Finished [UIImage imageNamed:@"D_SelfMarket_Finished.png"]
#define kD_SelfMarket_Finished_Hover [UIImage imageNamed:@"D_SelfMarket_Finished_Hover.png"]

@interface OptionalViewController ()
{
    UIView *top;
    UIButton *_editButton;// 管理按钮
    UIButton *_backButton;// 返回按钮
    UIButton *_currentButton;// 当前点的按钮
}
@end

@implementation OptionalViewController


- (void)viewDidLoad
{
    //[super viewDidLoad];
    // 初始化的时候 设置 先更新后提交
    [DCommon setIsSubmitThanUpdate:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.main.delegate = self;
    // 视图初始化
    [self initViews];
    // 初始化子视图
    [self initSubViews];
    // 设置操作类型
    [self setMarketOperationType];
    // 需要实现父类的viewWillAppear
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self myDealloc];
}

#pragma mark ---------------------------自定义方法------------------------
-(void)myDealloc{
    [self.view removeAllSubviews];
    self.transformImage = nil;
    self.zixuan = nil;
    top = nil;
    _editButton = nil;
    self.searchButton = nil;
}
#pragma mark 初始化视图
-(void)initViews{
    //[self myDealloc];
    
    if (!top) {
        // 头部
        top = [self Title:@"自选股中心" returnType:1];
        [self.view addSubview:top];
        // 隐藏返回按钮
        for (UIView *item in top.subviews) {
            if ([item class]==[UIButton class]) {
                _backButton = (UIButton*)item;
            }else{
                if ([item class]!=[UILabel class]) {
                    [item removeFromSuperview];
                }
            }
            
        }
        _backButton.hidden = YES;
        [_backButton addTarget:self action:@selector(clickReturnBack:) forControlEvents:UIControlEventTouchUpInside];
        // 添加一个管理按钮
        UIImage *bg = [DCommon imageWithColor:UIColorFromRGB(0xf0f0f0) andSize:CGSizeMake(60, top.frame.size.height)];
       // UIImage *bgHover = [DCommon imageWithColor:UIColorFromRGB(0xf0f0f0) andSize:CGSizeMake(60, top.frame.size.height)];240, 8, 66, 28
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, 66, 28)];
        _editButton.layer.borderColor=UIColorFromRGB(0xcccccc).CGColor;
        _editButton.layer.borderWidth=0.5f;
        _editButton.layer.masksToBounds=YES;
        [_editButton setTitle:@"管理" forState:UIControlStateNormal];
        [_editButton setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
        [_editButton setBackgroundImage:bg forState:UIControlStateNormal];
       // [_editButton setBackgroundImage:bgHover forState:UIControlStateHighlighted];
        [_editButton addTarget:self action:@selector(clickEditButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:_editButton];
        // 搜索按钮
        UIImage *btBg = [UIImage imageNamed:@"D_Search.png"];
        UIImage *btBgHover = [UIImage imageNamed:@"D_SearchHover.png"];
        
        NSString *path=[[NSBundle mainBundle]pathForResource:@"D_SearchHover@2x" ofType:@"png"];
        UIImage *image=[UIImage imageWithContentsOfFile:path];
        NSLog(@"%@",NSStringFromCGSize(image.size));
        self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake((top.frame.size.width-image.size.width)-10,(top.frame.size.height-image.size.height)*.5,image.size.width,image.size.height)];
        NSLog(@"%@",NSStringFromCGRect(self.searchButton.frame));
        [self.searchButton setImage:btBg forState:UIControlStateNormal];
        [self.searchButton setImage:btBgHover forState:UIControlStateHighlighted];
        //[self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.searchButton addTarget:self action:@selector(clickSearchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [top addSubview:self.searchButton];
        
        //    // 添加刷新旋转图片
        //    self.transformImage = [[transformImageView alloc] initWithFrame:CGRectMake(240, self.searchButton.frame.origin.y-2, 0, 0)];
        //
        //    [top addSubview:self.transformImage];
        //    // 添加一根分割线
        //    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.transformImage.frame.origin.x+self.transformImage.frame.size.width +6,
        //                                                            self.transformImage.frame.origin.y,
        //                                                            1,
        //                                                            top.frame.size.height-self.transformImage.frame.origin.y*2)];
        //    line.backgroundColor = UIColorFromRGB(0x636363);
        //    [top addSubview:line];
        
    }
    
}

#pragma mark 初始化子视图
-(void)initSubViews{
    self.view.backgroundColor = kMarketBackground;
    
    if (!_zixuan) {
        // 添加自选按钮
        _zixuan = [ziXuanIndexViewController instance];
        CGFloat topHeight = top.frame.size.height+top.frame.origin.y;
        CGFloat marketTabButtonHeight = self.view.frame.size.height-topHeight;
        [self addChildViewController:_zixuan];
        _zixuan.isShowHuShenZhi=YES;
        _zixuan.view.frame = CGRectMake(0, topHeight, self.view.frame.size.width, marketTabButtonHeight);
        _zixuan.Parent = self;
        //_zixuan.view.backgroundColor = UIColorFromRGB(0x000000);
        [self.view addSubview:_zixuan.view];
       // [_zixuan show];
    }
    else{
        //[_zixuan loadLocalDatas];
    }
    
    [_zixuan show];
    
     NSLog(@"_zixuan.frame==%@",NSStringFromCGRect(_zixuan.view.frame));
}



#pragma mark 设置注销登陆的操作类型
-(void)setMarketOperationType{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 操作类型 0 表示用户注销登陆后 清除设备号的关联
    [defaults setObject:[NSNumber numberWithInt:0] forKey:kSelfMarketOperationType];
    defaults = nil;
}

#pragma mark 点击按钮向下
-(void)bottomDown:(UIView *)bottom{
    // 共享改变的高度值
    [DCommon setChangeHeight:61];
    [_zixuan show];
}
#pragma mark 点击按钮向上
-(void)bottomUp:(UIView *)bottom{
    // 共享改变的高度值
    [DCommon setChangeHeight:0];
    [_zixuan show];
}

#pragma mark 搜索按钮点击事件
-(void)clickSearchButtonAction:(UIButton*)button{
    // 保存本页面的成果
//    if (_zixuan) {
//        // 点击搜索相当于离开本界面，那么保存用户信息并同步到远程服务器
//        [_zixuan saveLocalDatas];
//        // 设置标志为提交后再更新 ,为二级视图返回做准备
//        _zixuan.isSubmitThanUpdate = YES;
//        // 设置共享标志
//        [DCommon setIsSubmitThanUpdate:YES];
//    }
    SearchStocksViewController *searchView = [[SearchStocksViewController alloc] init];
    [self.navigationController pushViewController:searchView animated:YES];
    searchView = nil;
}
#pragma mark 按钮视图变化
-(void)changeButtonViews{
    UIButton *button = _currentButton;
    button.enabled = YES;
    CGFloat x = _zixuan.mainTableView.frame.origin.x;
    if ([_editButton.titleLabel.text isEqualToString:@"管理"] && x==320) {
        [_editButton setTitle:@"完成" forState:UIControlStateNormal];
        // 隐藏掉搜索按钮
        _searchButton.hidden = YES;
        // 设置为先提交后更新
        [DCommon setIsSubmitThanUpdate:YES];
    }else{
        [_editButton setTitle:@"管理" forState:UIControlStateNormal];
        // 显示掉搜索按钮
        _searchButton.hidden = NO;
    }
    
    button = nil;
}


#pragma mark 点击编辑按钮
-(void)clickEditButtonAction:(UIButton*)button{
    _currentButton = button;
    _currentButton.enabled = NO;
    _currentButton.alpha = 1;
    // 按钮效果
    [UIView animateWithDuration:0.2 animations:^{
        _currentButton.alpha = 0.3;
    } completion:^(BOOL isfinish){
        _currentButton.alpha = 1;
    }];
    if (_zixuan) {
        [_zixuan moveViews:YES];
    }
}

#pragma mark 点击返回按钮
-(void)clickReturnBack:(UIButton*)button{
    _currentButton = button;
    _currentButton.enabled = NO;
    _currentButton.alpha = 1;
    // 按钮效果
    [UIView animateWithDuration:0.2 animations:^{
        _currentButton.alpha = 0.3;
    } completion:^(BOOL isfinish){
        _currentButton.alpha = 1;
    }];
    if (_zixuan) {
        [_zixuan moveViews:NO];
    }
}

-(void)refreshViews{
    if (_zixuan) {
        
        //[_zixuan show];
    }
}

@end
