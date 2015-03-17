//
//  tabButton.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "tabButton.h"
#import "FileOperation.h"
#import "hqBaseViewController.h"
#import "MarketViewController.h"
#import "zhongheViewController.h"
#import "dapanViewController.h"
#import "bankuaiViewController.h"
#import "geguViewController.h"
#import "quanquiViewController.h"
#import "gangguViewController.h"
#import "DCommon.h"
#import "huShenViewController.h"

#define kTitlePadding 5
#define kTitleWidth (self.frame.size.width-20)/4
#define KBottomHeight 44
#define ktabHeight 38
#define kButtonTitleColor UIColorFromRGB(0x000000)
#define kButtonTitleCurrentColor UIColorFromRGB(0xe86e25)
#define kButtonFont [UIFont fontWithName:kFontName size:16]

@interface tabButton ()
{
    zhongheViewController *_zhongheController;
    dapanViewController *_dapanController;
    bankuaiViewController *_bankuaiController;
    geguViewController *_geguController;
    quanquiViewController *_quanquiController;
    gangguViewController *_gangguController;
    hqBaseViewController *_baseController;
    // 深股
    dapanViewController *_szController;
    // 沪股
    dapanViewController *_huController;
    NSMutableArray *_isShowed;
    UIView *_btBg ;// 按钮移动背景
    UIView *_tabButtonView;
    huShenViewController *_huShen;
    
}
@property (strong,nonatomic) NSMutableArray *hqTitle;
@property (strong,nonatomic) FileOperation *fo;

@end

@implementation tabButton


-(id)init{
    self = [super init];
    if (self) {
        // 初始化数据
        [self getPlistData];
        // 初始化控制器
        [self initController];
        
    }
    return self;
}


-(void)dealloc{
    self.hqTitle = nil;
    self.fo = nil;
    _zhongheController = nil;
    _dapanController = nil;
    _bankuaiController = nil;
    _geguController = nil;
    _quanquiController = nil;
    _gangguController = nil;
    _baseController = nil;
    _szController = nil;
    _huController = nil;
    _huShen = nil;
}


#pragma mark - -----------------自定义方法--------------------


#pragma mark 初始化控制器
-(void)initController{
    _zhongheController = [[zhongheViewController alloc] init];
    _dapanController = [[dapanViewController alloc] init];
    _dapanController.kType = 0; // 大盘
    _bankuaiController = [[bankuaiViewController alloc] init];
    _geguController = [[geguViewController alloc] init];
    _quanquiController = [[quanquiViewController alloc] init];
    _gangguController = [[gangguViewController alloc] init];
//    _isShowed = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:NO],
//                 [NSNumber numberWithBool:NO],
//                 [NSNumber numberWithBool:NO],
//                 [NSNumber numberWithBool:NO],
//                 [NSNumber numberWithBool:NO],
//                 [NSNumber numberWithBool:NO], nil];
//    self.controllers = [[NSMutableArray alloc] initWithObjects:_zhongheController,
//                        _dapanController,
//                        _bankuaiController,
//                        _geguController,
//                        _quanquiController,
//                        _gangguController, nil];
    _szController = [[dapanViewController alloc] init];
    _szController.kType = 1; // 深股
    _huController = [[dapanViewController alloc] init];
    _huController.kType = 2; // 沪股
    _isShowed = [[NSMutableArray alloc] initWithObjects:
                 [NSNumber numberWithBool:NO],
                 [NSNumber numberWithBool:NO],
                 [NSNumber numberWithBool:NO],
                 [NSNumber numberWithBool:NO], nil];
    self.controllers = [[NSMutableArray alloc] initWithObjects:
                        _zhongheController,
                        _dapanController,
                        _huController,
                        _szController, nil];
    self.backgroundColor = ClearColor;
    // 初始化高度改变值为0
    [DCommon setChangeHeight:0];
}

#pragma mark 初始化控件
-(id)initWithSuperController:(MarketViewController*)market andFrame:(CGRect)frame{
    self = [self init];
    if (self) {
        self.marketController = market;
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, ktabHeight);
        self.backgroundColor = UIColorFromRGB(0xe1e1e1);
        // 初始化控件
        [self initView];
        // 默认显示第一个视图
        [self clickButton:nil];
    }
    return self;
}

#pragma mark 初始化视图
-(void)initView{
    // 创建分类按钮
    // 背景
    _btBg = [[UIView alloc] initWithFrame:CGRectMake(kTitlePadding, 34, kTitleWidth, 4)];
    _btBg.backgroundColor = kButtonTitleCurrentColor;
    [self addSubview:_btBg];
//    // 底线
//    UIView *_btLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
//    _btLine.backgroundColor = UIColorFromRGB(0x808080);
//    [self addSubview:_btLine];
//    _btLine = nil;
    // 按钮
    if (self.hqTitle) {
        CGFloat x = kTitlePadding;
        for (int i=0;i<self.hqTitle.count;i++) {
            NSString *key = [self.hqTitle objectAtIndex:i];
            UIButton *hqbtn = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, kTitleWidth, ktabHeight)];
            [hqbtn setTitle:key forState:UIControlStateNormal];
            [hqbtn setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
            [hqbtn setTitleColor:kButtonTitleCurrentColor forState:UIControlStateSelected];
            [hqbtn setTitleColor:kButtonTitleCurrentColor forState:UIControlStateHighlighted];
            [hqbtn setBackgroundColor:ClearColor];
            hqbtn.titleLabel.font = kButtonFont;
            hqbtn.tag = i+100;
            [hqbtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:hqbtn];
            hqbtn = nil;
            x += kTitleWidth + kTitlePadding;
        }
    }
    
}

#pragma mark 读取plist数据
-(void)getPlistData{
    //plist资源
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"hangqing" ofType:@"plist"];
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    self.hqTitle=[data objectForKey:KPlistKey2]; // 行情分类标题集合
//    data=nil;
    NSLog(@"--DFM--%@",self.hqTitle);
    self.hqTitle = [[NSMutableArray alloc] initWithObjects:@"综合",@"大盘",@"沪股",@"深股", nil];
}

#pragma mark 点击指定tag的按钮
-(void)clickButtonWithTag:(NSInteger)tag{
    NSLog(@"----DFM----点击Tag:%d",tag);
    UIButton *btn = (UIButton*)[self viewWithTag:tag];
    [self clickButton:btn];
    btn = nil;
}

#pragma mark 点击分类按钮
-(void)clickButton:(UIButton*)button{
    int tag = 0;
    if(button)
        tag = button.tag;
    if (tag<self.controllers.count+100) {
        if (tag==0) {
            tag +=100;
        }
        // 所有按钮恢复状态
        for (UIButton *item in [self subviews]) {
            if (item.tag>=100 && item.tag<=[self subviews].count+100) {
                [item setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
            }
        }
        // 当前按钮状态
        UIButton *btn = (UIButton*)[self viewWithTag:tag];
        [btn setTitleColor:kButtonTitleCurrentColor forState:UIControlStateNormal];
        btn = nil;
        
        NSLog(@"--DFM--点击了第几个：%d",tag);
        CGFloat x = button.frame.origin.x;
        if (x<=0) {
            x = kTitlePadding;
        }
        // 按钮背景移动动画
        [UIView animateWithDuration:0.2 animations:^{
            // 执行动画
            _btBg.frame = CGRectMake(x, _btBg.frame.origin.y, _btBg.frame.size.width, _btBg.frame.size.height);
        } completion:^(BOOL isFinish){
            [self changeShowViewWithButtonTag:tag];
        }];
        
    }

}

#pragma mark 改变视图显示
-(void)changeShowViewWithButtonTag:(int)tag{
    if (self.currentTag==tag) {
        return;
    }
    self.currentTag = tag;
    tag -=100;
    if (_huShen) {
        [_huShen.view removeFromSuperview];
    }
    
    if (_baseController) {
        [_baseController clear];
        [_baseController.view removeFromSuperview];
        [_isShowed replaceObjectAtIndex:tag withObject:[NSNumber numberWithBool:NO]];
        _baseController = nil;
        
    }
    // 得到切换的控制器
    if (_baseController==nil) {
        _baseController = (hqBaseViewController*)[self.controllers objectAtIndex:tag];
        CGFloat x = 0;
        CGFloat y = self.frame.origin.y+self.frame.size.height;
        CGFloat w = self.frame.size.width;
        CGFloat h = kMarketTabButtonViewHeight;
        // 获取系统高度变化值
        CGFloat changeHeight = [DCommon getChangeHeight];
        
        // 加上系统改变的高度
        h += changeHeight;
        _baseController.view.frame = CGRectMake(x,y,w,changeHeight>0?h-15:h);
        if (![[_isShowed objectAtIndex:tag] boolValue]) {
            _baseController.market = self.marketController;
            [self.marketController.view addSubview:_baseController.view];
            [_isShowed replaceObjectAtIndex:tag withObject:[NSNumber numberWithBool:YES]];
        }
        [self.marketController.view bringSubviewToFront:_baseController.view];
        [_baseController show];
        if (tag!=0) {
            // 放沪深股在底部
            if (!_huShen) {
                _huShen = [[huShenViewController alloc] initWithParent:self.marketController andFrame:CGRectMake(0, 0, w, y+h+1.5)];
            }else{
                [self.marketController.view addSubview:_huShen.view];
                [UIView animateWithDuration:0.3 animations:^{
                    _huShen.view.frame = CGRectMake(0, y+h+1.5-_huShen.view.frame.size.height, w, _huShen.view.frame.size.height);
                } completion:^(BOOL finish){
                    [_huShen getHushenStocksIndex:YES];
                }];
                
                
            }
        }
    }
}

-(void)changeViewFrameWithTag:(int)tag{
    self.currentTag = tag;
    tag -=100;
    CGFloat x = 0;
    CGFloat y = self.frame.origin.y+self.frame.size.height;
    CGFloat w = self.frame.size.width;
    CGFloat h = kMarketTabButtonViewHeight;
    // 获取系统高度变化值
    CGFloat changeHeight = [DCommon getChangeHeight];
    // 加上系统改变的高度
    h += changeHeight;
    _baseController.view.frame = CGRectMake(x,y,w,h);
    [_baseController show];
    
    if (tag!=0) {
        // 放沪深股在底部
        if (!_huShen) {
            _huShen = [[huShenViewController alloc] initWithParent:self.marketController andFrame:CGRectMake(0, 0, w, y+h+1.5)];
        }else{
            //[self.marketController.view addSubview:_huShen.view];
            [UIView animateWithDuration:0.3 animations:^{
                _huShen.view.frame = CGRectMake(0, y+h+1.5-_huShen.view.frame.size.height, w, _huShen.view.frame.size.height);
            } completion:^(BOOL finish){
                [_huShen getHushenStocksIndex:YES];
            }];
            
            
        }
    }
}

@end
