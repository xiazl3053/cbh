//
//  KLineViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "KLineViewController.h"
#import "transformImageView.h"
#import "kChartViewController.h"
#import "MJRefresh.h"
#import "kTabbarController.h"
#import "AppDelegate.h"
#import "CommonOperation.h"
#import "selfMarketDB.h"
#import "selfMarketModel.h"
#import "zRemindViewController.h"
#import "selfMarketDB.h"
#import "selfMarketModel.h"
#import "DCommon.h"
#import "hangqingHttpRequest.h"
#import "MLNavigationController.h"
#import "PushNotificationHandler.h"

#define kTopHeight 75
#define kFont [UIFont systemFontOfSize:12]
#define kWhiteColor [UIColor whiteColor];
#define kDPrePng [UIImage imageNamed:@"D_Pre.png"]
#define kDPrePngHover [UIImage imageNamed:@"D_PreHover.png"]
#define kDNextPng [UIImage imageNamed:@"D_Next.png"]
#define kDNextPngHover [UIImage imageNamed:@"D_NextHover.png"]
#define kDAddImgPng [UIImage imageNamed:@"D_Add.png"]
#define kDAddImgHoverPng [UIImage imageNamed:@"D_AddHover.png"]
#define kDSubImgPng [UIImage imageNamed:@"D_Sub.png"]
#define kDSubImgHoverPng [UIImage imageNamed:@"D_SubHover.png"]

@interface KLineViewController ()<UIAlertViewDelegate>
{
    UILabel *_lbCurentPrice; // 当前价文本
    UILabel *_lbCurentChangeRate; // 涨跌幅文本
    UILabel *_lbCurentChangeValue; // 涨跌额文本
    UILabel *_lbHeightPrice; // 当前最高价文本
    UILabel *_lbLowPrice;// 当前最低价文本
    UILabel *_lbOpenPrice ;// 当前开盘价文本
    UILabel *_lbTurnoverRate ;// 当前换手率
    UILabel *_lbVolume; // 当前成交量
    UILabel *_lbVolumePrice ;// 当前成交额
    UILabel *_lbMarketValue ;// 总值 总市值
    UILabel *_lbCirculateMarketValue ;// 流值  流通市值
    UILabel *_lbPe; // 市盈率
    UILabel *_lbPriceToBook ;// 市净率
    CGFloat _defaultHeight; // 原始高度
    UIButton *_addButton; // 增加删除自选股按钮
    CGPoint pointLeftTop;
    selfMarketDB *_db ;// 自选数据库
    NSOperationQueue *_queue ;// 队列
    hangqingHttpRequest *_request;
    MLNavigationController *mlNavigation;
    
    // 上一只 下一只
    KLineViewController *_preKlineView;
    KLineViewController *_nextKlineView;
    int _page; // 当前页
    
    
    UIButton *_nextBtn;
    UIButton *_preBtn;
    
    // 背景图
    UIImageView *_bg;
    
    //正在执行方法
    BOOL isExecuteShow;
    BOOL isReceiveMemory;// 是否内存警告
}

@end

@implementation KLineViewController

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

}
-(void)viewWillAppear:(BOOL)animated{
    
    mlNavigation = (MLNavigationController*)[[CommonOperation getId] getMain].navigationController;
    mlNavigation.canDragBack = NO;
    // 如果是从第三方视图推进来则不执行 show 方法,否则本身视图切换中总会执行show方法
    if (!_isBack) {
        [self show];
    }
    // 默认添加删除按钮的状态
    [self setAddButton];
    [super viewWillAppear:animated];
    if (_kChartController){
        [_kChartController viewWillAppear:animated];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    //((MLNavigationController*)self.navigationController).canDragBack=YES;
    mlNavigation.canDragBack = YES;
    //mlNavigation = nil;
    // 如果是从第三方视图推进来则不执行 free 方法,否则本身视图切换中总会执行free方法
    if (!_isBack) {
        [self free];
    }
    [super viewDidDisappear:animated];
}
-(void)dealloc{
    [self free];
    //mlNavigation = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark --------------------------------自定义方法-------------------------------
#pragma mark 初始化K线图
-(id)initWithIsBack:(BOOL)isBack KId:(NSString*)kId KType:(int)kType KName:(NSString*)kName{
    self = [super init];
    if (self) {
        self.isBack = isBack;
        self.kId = kId;
        self.kType = kType;
        self.kName = kName;
        _isMovePage = NO;
        // 显示
        [self show];
    }
    return self;
}

#pragma mark 初始化K线图 用于二级个股列表界面
-(id)initWithBackController:(id)controller kId:(NSString*)kId KType:(int)kType KName:(NSString*)kName andPageArray:(NSMutableArray*)pageArray andPage:(int)page{
    self = [super init];
    if (self) {
        self.backController = controller;
        self.isBack = YES;
        self.kId = kId;
        self.kType = kType;
        self.kName = kName;
        self.pageArray = pageArray;
        self.currentPage = page;
        _isMovePage = NO;
        // 显示
        [self show];
    }
    return self;
}

#pragma mark 从推送中心push过来
-(id)initWithPush:(NSString*)kId KType:(int)kType KName:(NSString*)kName RemindType:(NSString*)remindType{
    self = [super init];
    if (self) {
        self.isBack = YES;
        self.kId = kId;
        self.kType = kType;
        self.kName = kName;
        _isMovePage = NO;
        // 执行用户数据本地更新策略
        //[self clearRemindDatasWithRemindType:remindType andkId:kId andKtype:[NSString stringWithFormat:@"%d",kType]];
        // 显示
        [self show];
        
    }
    return self;
}

#pragma mark 为上下页服务
-(id)initWithMovePage:(NSString*)kId KType:(int)kType KName:(NSString*)kName{
    self = [super init];
    if (self) {
        self.isBack = YES;
        self.kId = kId;
        self.kType = kType;
        self.kName = kName;
        _isMovePage = YES;
        // 显示
        [self show];
    }
    return self;
}

#pragma mark 显示
-(void)show{
    
    if (!isExecuteShow) {

        isExecuteShow = YES;
        // 所有视图dealloc
        [self free];
        // 初始化参数
        [self initParam];
        // 视图初始化
        [self initViews];
        // 初始化布局
        [self initLayout];
        // 添加标题视图
        [self addTitleView];
        // 增删自选按钮
        [self addAddButton];
        // 添加下拉刷新控件
        [self addHeader];
        // 添加上啦刷新控件
        /*******change********/
        //[self addFooter];
        // 添加底部上一页下一页视图
        [self addPreAndNextView];
        //[CommonOperation goTOLogin];
        self.isFirst = NO;
        // 开始运行
        if (!_isMovePage) {
            [self startRun];
        }
        // 添加上下页
        [self addPreNextController];
        isExecuteShow = NO;
        
    }
    
}
#pragma mark 界面准备好，开始加载数据
-(void)startRun{
    [_queue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_kChartController) {
                [_kChartController startRun];
            }
            if (_bottomController) {
                [_bottomController startRun];
            }
        });
    }];
    
}

#pragma mark 手动移除视图
-(void)myRemoveAllViews{

    [self.view removeAllSubviews];
    if (!_bg) {
        // 加背景图
        UIImage *bgimg = [UIImage imageNamed:@"alert_load_black.png"];
        CGRect frame = self.view.frame;
        _bg = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-bgimg.size.width)/2, (frame.size.height-bgimg.size.height)/2, bgimg.size.width, bgimg.size.height)];
        if (self.isHorizontal) {
            _bg.frame = CGRectMake((frame.size.height-bgimg.size.width)/2, (frame.size.width-bgimg.size.height)/2, bgimg.size.width, bgimg.size.height);
        }
        _bg.image = bgimg;
        [self.view addSubview:_bg];
    }
}

#pragma mark 手动释放
-(void)free{
    [_queue cancelAllOperations];
    _queue = nil;
    
    // 释放K线图
    [_kChartController free];
    [_bottomController free];
    [_header free];
    [_footer free];
    [_request clearRequest];
    [_preKlineView free];
    [_nextKlineView free];
    _request = nil;
    _footer = nil;
    _header = nil;
    _kChartController = nil;
    _bottomController = nil;
    
    // 释放其他视图
    _preKlineView = nil;
    _nextKlineView = nil;
    _nextBtn=nil;
    _preBtn=nil;
    _kTopView = nil;
    _db = nil;
    _addButton = nil;
    _preAndNextView = nil;
    self.topView = nil;
    _mainView = nil;
    _mainScrollView = nil;
    _bg = nil;
    // 手动移除所有视图
    [self myRemoveAllViews];
}

#pragma mark 初始化参数
-(void)initParam{
    self.isFix = YES; // 默认固定
    _db = [[selfMarketDB alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _request = [[hangqingHttpRequest alloc] init];
    self.isFirst = YES;
}

#pragma mark 加载完执行
-(void)whenLoadOverAction{
    if (_mainScrollView) {
        _mainScrollView.scrollEnabled = YES;
    }
    
}

#pragma mark 初始化视图
-(void)initViews{
    [UIApplication sharedApplication].keyWindow.backgroundColor = kMarketBackground;
    self.view.backgroundColor = kMarketBackground;
    self.view.alpha = 1;
    
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        // 获取当前屏幕的大小
        _screenFrame = [UIScreen mainScreen].bounds;
        //设置应用程序的状态栏到指定的方向
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        //隐藏状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        //view旋转
        self.view.transform = CGAffineTransformIdentity;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        // view初始化frame
        self.view.frame = CGRectMake(0, 0, _screenFrame.size.width, _screenFrame.size.height);
    }
    if (!self.isHorizontal) {
        // 判断状态栏
        if ([UIApplication sharedApplication].statusBarHidden) {
            // 获取当前屏幕的大小
            _screenFrame = [UIScreen mainScreen].bounds;
            //设置应用程序的状态栏到指定的方向
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
            //隐藏状态栏
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            //view旋转
            self.view.transform = CGAffineTransformIdentity;
            [self.view setTransform:CGAffineTransformMakeRotation(0)];
            // view初始化frame
            self.view.frame = CGRectMake(0, 0, _screenFrame.size.width, _screenFrame.size.height);
        }
        
        // 头部
        [self initTitle:@"" returnType:0];
        // 添加标题
        CGFloat topPadding = 3;
        //标题栏的标题
        self.kNameLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, topPadding, 200, self.topView.frame.size.height/3*2)];
        self.kNameLabel.text = self.kName;
        self.kNameLabel.textAlignment = NSTextAlignmentCenter;
        self.kNameLabel.backgroundColor=[UIColor clearColor];
        self.kNameLabel.textColor=UIColorFromRGB(0x000000);
        self.kNameLabel.font = [UIFont fontWithName:kFontName size:18];
        [self.kNameLabel sizeToFit];
        self.kNameLabel.center= CGPointMake(self.topView.center.x, self.kNameLabel.frame.size.height/2+topPadding);
        [self.topView addSubview:self.kNameLabel];

        // 添加副标题
        UILabel *lableSub=[[UILabel alloc] initWithFrame:CGRectMake(0, self.kNameLabel.frame.size.height+topPadding, 200, self.topView.frame.size.height/3)];
        lableSub.text = self.kId;
        lableSub.textAlignment = NSTextAlignmentCenter;
        lableSub.backgroundColor=[UIColor clearColor];
        lableSub.textColor=UIColorFromRGB(0x999999);
        lableSub.font = [UIFont fontWithName:kFontName size:14];
        [lableSub sizeToFit];
        lableSub.center= CGPointMake(self.topView.center.x, self.topView.frame.size.height/3*2+topPadding);
        [self.topView addSubview:lableSub];
        self.kIdLabel = lableSub;
        lableSub = nil;
        
    }
    
}
#pragma mark 设置标题
-(void)setKTitle:(NSString *)title{
    self.kNameLabel.text = title;
    [self.kNameLabel sizeToFit];
    self.kNameLabel.center= CGPointMake(self.topView.center.x, self.kNameLabel.frame.size.height/2+3);
    if (self.isHorizontal) {
        self.kNameLabel.center = CGPointMake(_titleView.center.x, self.kNameLabel.frame.size.height/2+10);
    }
}

#pragma mark 添加横屏标题视图
-(void)addTitleView{
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        CGFloat w = 120;
        CGFloat h = 50;
        CGFloat x = 5;
        CGFloat lx = 0;
        if (kDeviceVersion<7) {
            x -= 20;
            lx = 25;
        }
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, w+lx , h)];
        _titleView.backgroundColor = ClearColor;
        //标题栏的标题
        self.kNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(lx, 10, w+lx, h)];
        self.kNameLabel.text = self.kName;
        self.kNameLabel.textAlignment = NSTextAlignmentCenter;
        self.kNameLabel.backgroundColor=[UIColor clearColor];
        self.kNameLabel.textColor=UIColorFromRGB(0x000000);
        self.kNameLabel.font = [UIFont fontWithName:kFontName size:18];
        [self.kNameLabel sizeToFit];
        self.kNameLabel.center= CGPointMake(_titleView.center.x, self.kNameLabel.frame.size.height/2+10);
        [_titleView addSubview:self.kNameLabel];
        // 添加副标题
        UILabel *lableSub=[[UILabel alloc] initWithFrame:CGRectMake(lx, 20, w+lx, h)];
        lableSub.text = self.kId;
        lableSub.textAlignment = NSTextAlignmentCenter;
        lableSub.backgroundColor=[UIColor clearColor];
        lableSub.textColor=UIColorFromRGB(0x999999);
        lableSub.font = [UIFont fontWithName:kFontName size:14];
        [lableSub sizeToFit];
        lableSub.center= CGPointMake(_titleView.center.x, lableSub.frame.size.height/2+30);
        [_titleView addSubview:lableSub];
        self.kIdLabel = lableSub;
        lableSub = nil;
        [self.view addSubview:_titleView];
    }
}



#pragma mark K线图布局
-(void)initLayout{
    if (!_mainView || !_mainView.superview) {
        // 添加主视图
        CGFloat leftX = 5;
        CGFloat topY = self.topView.frame.size.height+self.topView.frame.origin.y;
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height-topY-44;
        CGFloat mainX = 0;
        if (kDeviceVersion<7 && self.view.frame.size.height==KScreenSize.height) {
            height -=20;
        }
        // **********************************
        // 如果横屏
        // **********************************
        if (self.isHorizontal) {
            leftX = 120;
            topY = 0;
            width = _screenFrame.size.height;
            height = _screenFrame.size.width-topY;
            if (kDeviceVersion<7) {
                mainX = -20;
            }
        }

        // 创建分页视图
        if (!_isMovePage && !self.isHorizontal) {
            _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(mainX,topY,width,height)];
            _mainScrollView.delegate = self;
            _mainScrollView.pagingEnabled = YES;
            //_mainScrollView.bounces = NO;
            _mainScrollView.scrollEnabled = NO;
            _mainScrollView.backgroundColor = ClearColor;
            _mainScrollView.opaque = YES;
            [self.view addSubview:_mainScrollView];
            
        }
        
        // 添加数据视图
        _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(width,0,width,height)];
        _mainView.scrollEnabled = YES;
        _mainView.backgroundColor = ClearColor;
        _mainView.opaque = YES;
        _mainView.delegate = self;
        _mainView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        // 如果是上下页的加载 并且 不是横屏状态
        if (!_isMovePage && !self.isHorizontal) {
            [_mainScrollView addSubview:_mainView];
        }
        else{
            _mainView.frame = CGRectMake(mainX,topY,width,height);
            [self.view addSubview:_mainView];
        }
        
        // 添加参数视图
        CGFloat kw = _mainView.frame.size.width - 10;
        CGFloat kh = kTopHeight;
        // **********************************
        // 如果横屏
        // **********************************
        if (self.isHorizontal) {
            leftX = 110;
            kw = _screenFrame.size.height-leftX-4;
            kh = kh/3*2;
            topY = 0;
        }else{
            leftX = 0;
            kw = _mainView.frame.size.width;
            topY = 10;
        }
        _kTopView = [[UIView alloc] initWithFrame:CGRectMake(leftX, topY, kw, kh)];
        _kTopView.backgroundColor = UIColorFromRGB(0xe1e1e1);
//        _kTopView.layer.borderColor = UIColorFromRGB(0x000000).CGColor;
//        _kTopView.layer.borderWidth = 1;
        [_mainView addSubview:_kTopView];
        // 添加参数视图元素
        [self createTopView];
        // 初始化k线图控制器
        CGFloat ky = _kTopView.frame.origin.y+kh+10;
        kw = self.view.frame.size.width;
        kh = 310;
        // **********************************
        // 如果横屏
        // **********************************
        if (self.isHorizontal) {
            ky = kTopHeight/3*2;
            kw = _screenFrame.size.height;
        }
        _kChartController = [[kChartViewController alloc] initWithParentController:self];
        _kChartController.view.frame = CGRectMake(0,ky,kw,kh);
        _kChartController.kLineView = self;
        [_mainView addSubview:_kChartController.view];
        // NSLog(@"---DFM---_kChartController.viewFrame:%@",NSStringFromCGRect(_kChartController.view.frame));
        // 原始高度为K线图高度
        _defaultHeight = _kChartController.view.frame.size.height + _kChartController.view.frame.origin.y;
        // **********************************
        // 如果横屏
        // **********************************
        if (self.isHorizontal) {
            _defaultHeight = kh ;
        }else{
            // 添加底部控制器
            [self addBottomController];
        }
        
    }
}
#pragma mark 添加上一只下一只控制器
-(void)addPreNextController{

    if (!_isMovePage && !self.isHorizontal) {
        
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        if (self.pageArray.count>0) {
            int nums = self.pageArray.count;
            if (self.pageArray.count>=3) {
                nums = 3;
            }
            if (self.currentPage<=0) {
                self.currentPage = 0;
            }
            if (self.currentPage>=self.pageArray.count) {
                self.currentPage = self.pageArray.count-1;
            }
            // 上一只 下一只个股
            if (self.currentPage<1) {
                if (_preKlineView) {
                    [_preKlineView.view removeFromSuperview];
                    _preKlineView = nil;
                }
                nums --;
            }else{
                _preKlineView = [[KLineViewController alloc] initWithMovePage:self.kId KType:self.kType KName:self.kName];
                _preKlineView.mainView.frame = CGRectMake(0,0,width,height);
                [_mainScrollView addSubview:_preKlineView.mainView];
            }
            if (self.currentPage>=(self.pageArray.count-1) || !self.pageArray) {
                if (_nextKlineView) {
                    [_nextKlineView.view removeFromSuperview];
                    _nextKlineView = nil;
                }
                nums --;
            }else{
                // 计算到达第一页或者最后一页时的情况
                CGFloat w = width*2;
                if (nums==2 || self.pageArray.count==2) {
                    w = width;
                }
                _nextKlineView = [[KLineViewController alloc] initWithMovePage:self.kId KType:self.kType KName:self.kName];
                _nextKlineView.mainView.frame = CGRectMake(w,0,width,height);
                [_mainScrollView addSubview:_nextKlineView.mainView];
            }
            if (self.pageArray.count==2) {
                nums = self.pageArray.count;
            }
            _mainScrollView.contentSize = CGSizeMake(width*nums, _mainScrollView.frame.size.height);
            // 如果没有上一页了
            if (!_preKlineView) {
                _page = 1;
                _mainView.frame = CGRectMake(0, _mainView.frame.origin.y, _mainView.frame.size.width, _mainView.frame.size.height);
                _mainScrollView.contentOffset = CGPointMake(0, 0);
            }else{
                _page = 2;
                _mainScrollView.contentOffset = CGPointMake(width, 0);
            }
            
        }
        else{
            // 只有单只个股时候
            _page = 1;
            _mainView.frame = CGRectMake(0, _mainView.frame.origin.y, _mainView.frame.size.width, _mainView.frame.size.height);
            _mainScrollView.contentOffset = CGPointMake(0, 0);
            _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width+1, _mainScrollView.frame.size.height);
        }
        
        // 添加提示
        [self addLeftAndRightTipView];
    }
    
    
}

#pragma mark 添加上下页左右提示视图
-(void)addLeftAndRightTipView{
    // 加两个没有上一页了，没有下一页了的提示
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(-30, 0, 25, _mainScrollView.frame.size.height)];
    t.text = @"没有上一页了";
    t.backgroundColor = ClearColor;
    t.font = [UIFont fontWithName:kFontName size:16];
    t.numberOfLines = 6;
    t.textColor = UIColorFromRGB(0x262626);
    [_mainScrollView addSubview:t];
    
    UILabel *tb = [[UILabel alloc] initWithFrame:CGRectMake(_mainScrollView.contentSize.width+30, 0, 25, _mainScrollView.frame.size.height)];
    tb.text = @"没有下一页了";
    tb.backgroundColor = ClearColor;
    tb.font = [UIFont fontWithName:kFontName size:16];
    tb.numberOfLines = 6;
    tb.textColor = UIColorFromRGB(0x262626);
    [_mainScrollView addSubview:tb];
    
    UIImage *img = [UIImage imageNamed:@"alert_tanhao.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(t.frame.origin.x-2, 105, 20, 20)];
    imgView.image = img;
    imgView.alpha = 0.1;
    [_mainScrollView addSubview:imgView];
    imgView = nil;
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(tb.frame.origin.x-2, 105, 20, 20)];
    imgView.image = img;
    imgView.alpha = 0.1;
    [_mainScrollView addSubview:imgView];
    imgView = nil;
    tb = nil;
    t = nil;
}

#pragma mark 添加底部导航控制器
-(void)addBottomController{
    // 添加底部控制器模块，控制器会根据自己的内容自动调整父级视图的高度
    if (!_bottomController && !self.isHorizontal) {
        _bottomController = [[kTabbarController alloc] init];
        _bottomController.kLineView = self;
        _bottomController.view.frame = CGRectMake(0,
                                                 _kChartController.view.frame.size.height+_kChartController.view.frame.origin.y,
                                                 self.view.frame.size.width,
                                                 self.view.frame.size.height+1000);
        [_mainView addSubview:_bottomController.view];
    }
}
#pragma mark 添加上一页和下一页的视图
-(void)addPreAndNextView{
    
    
    CGFloat w = self.view.frame.size.width;
    CGFloat h = 44;
    CGFloat x = 0;
    CGFloat y = self.view.frame.size.height-h;
    CGFloat width = 120;
    if (kDeviceVersion<7 && self.view.frame.size.height==KScreenSize.height) {
        y -= 20;
    }
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        w = 90;
        h = 30;
        width = h+15;
        if (KScreenSize.height<500) {
            w = 60;
            width = 30;
        }
        y = self.view.frame.size.width-h-5;
        x = self.view.frame.size.height - w - 5;
        if (kDeviceVersion<7) {
            x -= 20;
        }
    }
    // 添加底部上一页下一页视图
    _preAndNextView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _preAndNextView.backgroundColor = UIColorFromRGB(0xe3e3e3);
    // 添加上一页按钮
    UIFont *font = [UIFont fontWithName:kFontName size:12];
    UIColor *color = UIColorFromRGB(0x808080);
    UIButton *preButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, h)];
    CGFloat imgX = (width-kDPrePngHover.size.width)/2-30;
    CGFloat imgY = 6;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        _preAndNextView.backgroundColor = ClearColor;
        imgX = (width-kDPrePngHover.size.width)/2;
    }else{
        [preButton setTitle:@"上一只" forState:UIControlStateNormal];
        preButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [preButton setTitleColor:color forState:UIControlStateNormal];
        preButton.titleLabel.font = font;
        [preButton setTitleEdgeInsets:UIEdgeInsetsMake(h/3+3, -55, 0, 0)];
    }
    
    //preButton.backgroundColor = UIColorFromRGB(0x333333);
    preButton.hidden = NO;
    [preButton addTarget:self action:@selector(clickPreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    UIImageView *pre = [[UIImageView alloc] initWithFrame:CGRectMake(imgX,imgY, kDPrePngHover.size.width, kDPrePngHover.size.height)];
    UIImageView *pre = [[UIImageView alloc] initWithFrame:CGRectMake(imgX,imgY, 15, 19)];
    
    NSLog(@"%@",NSStringFromCGRect(pre.frame));
    pre.image = kDPrePngHover;
    [preButton addSubview:pre];
    _preBtn=preButton;

    pre = nil;
    [_preAndNextView addSubview:preButton];
    // 如果到最后一页了就显示不可点击状态
    if (self.currentPage<1) {
        preButton.alpha = 0.2;
        preButton.enabled = NO;
    }
    // 添加下一页按钮
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-width, 0, width, h)];
    imgX = (width-kDNextPngHover.size.width)/2+30;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        CGFloat nextBtX = preButton.frame.origin.x+preButton.frame.size.width;
        nextButton.frame = CGRectMake(nextBtX, 3, width, h);
        imgX = (width-kDNextPngHover.size.width)/2;
        imgY = 3;
        
    }else{
        [nextButton setTitle:@"下一只" forState:UIControlStateNormal];
        [nextButton setTitleEdgeInsets:UIEdgeInsetsMake(h/3+3, 55, 0, 0)];
        nextButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [nextButton setTitleColor:color forState:UIControlStateNormal];
        nextButton.titleLabel.font = font;
    }
    
    //nextButton.backgroundColor = UIColorFromRGB(0x333333);
    nextButton.hidden = NO;
    [nextButton addTarget:self action:@selector(clickNextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    UIImageView *next = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, kDNextPngHover.size.width, kDNextPngHover.size.height)];
    UIImageView *next = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, 15, 19)];
    next.image = kDNextPngHover;
    [nextButton addSubview:next];
    _nextBtn=nextButton;
    next = nil;
    [_preAndNextView addSubview:nextButton];
    // 如果到最后一页了就显示不可点击状态
    if (self.currentPage>=self.pageArray.count-1 || !self.pageArray) {
        nextButton.alpha = 0.2;
        nextButton.enabled = NO;
    }
    // **********************************
    // 如果横屏
    // **********************************
    if (!self.isHorizontal) {
        // 添加一根黑线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 0.5)];
        line.backgroundColor = UIColorFromRGB(0x636363);
        [_preAndNextView addSubview:line];
        line = nil;
    }
    [self.view addSubview:_preAndNextView];
    
    if (!self.isHorizontal) {
        NSString *path=[[NSBundle mainBundle]pathForResource:@"D_SelfMarket_Small_Remind@2x" ofType:@"png"];
        UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
        UIImage *remindImg = [UIImage imageNamed:@"D_SelfMarket_Small_Remind.png"];
        // 添加提醒按钮
        w = 80;
        h = _preAndNextView.frame.size.height;
        x = (_preAndNextView.frame.size.width - w)/2;
        y = 0;
        UIButton *remindButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        remindButton.backgroundColor = ClearColor;
        [remindButton addTarget:self action:@selector(clickRemindButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_preAndNextView addSubview:remindButton];
        // 添加图片
        UIImageView *remindImgView = [[UIImageView alloc] initWithFrame:CGRectMake((remindButton.frame.size.width-imageSize.size.width)/2, 5, imageSize.size.width, imageSize.size.height)];
        remindImgView.image = remindImg;
        [remindButton addSubview:remindImgView];
        remindImgView = nil;
        // 添加提醒文字
        UILabel *remindl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5+imageSize.size.height, w, 20)];
        remindl.text = @"提醒";
        remindl.textColor = color;
        remindl.backgroundColor = ClearColor;
        remindl.textAlignment = NSTextAlignmentCenter;
        remindl.font = [UIFont fontWithName:kFontName size:12];
        [remindButton addSubview:remindl];
        remindl = nil;
        remindButton = nil;
    }
    NSLog(@"addPreAndNextView==%@",[NSThread currentThread]);
}
#pragma mark 设置页数的时候重新设置分页
-(void)setPageArray:(NSMutableArray *)pageArray{
    _pageArray = pageArray;
    [_preAndNextView removeFromSuperview];
    _preAndNextView = nil;
    [self addPreAndNextView];
}

#pragma mark 添加增删自选按钮
-(void)addAddButton{
    if (!_addButton) {
        // 添加增删自选股按钮
        NSString *path=[[NSBundle mainBundle]pathForResource:@"D_Add@2x" ofType:@"png"];
        UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
        UIImage *img = kDAddImgPng;
        UIImage *imgHover = kDAddImgHoverPng;
        // 判断自选是否存在
        // 模型
        selfMarketModel *m = [[selfMarketModel alloc] init];
        m.marketId = self.kId;
        m.marketType = [[NSString alloc] initWithFormat:@"%d",self.kType];
        // 如果存在就是减号
        if ([_db isExistSelfMarket:m]) {
            img = kDSubImgPng;
            imgHover = kDSubImgHoverPng;
        }
        m = nil;

        // 添加自选按钮
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(90, (self.topView.frame.size.height-imageSize.size.height)/2, imageSize.size.width, imageSize.size.height)];
        [_addButton setImage:img forState:UIControlStateNormal];
        [_addButton setImage:imgHover forState:UIControlStateHighlighted];
        [_addButton addTarget:self action:@selector(clickAddButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // **********************************
        // 如果横屏
        // **********************************
        if (self.isHorizontal) {
            _addButton.frame = CGRectMake(0, (_titleView.frame.size.height-imageSize.size.height)/2, imageSize.size.width, imageSize.size.height);
            [_titleView addSubview:_addButton];
        }else{
            [self.topView addSubview:_addButton];
        }
    
    }
}

-(void)setAddButton{
    // 开队列操作数据库
    [_queue addOperationWithBlock:^{
        
        // 模型
        selfMarketModel *m = [[selfMarketModel alloc] init];
        m.marketId = self.kId;
        m.marketName = self.kName;
        m.marketType = [[NSString alloc] initWithFormat:@"%d",self.kType];
        m.timestamp = [DCommon getTimestamp];
        m.isSyn = NO;
        m.userId = @"";
        UserModel *user = [UserModel um];
        if (user.userId>0) {
            m.userId = user.userId;
        }
        
        // 先查询是否存在
        BOOL isExit = [_db isExistSelfMarket:m];
        if (isExit) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_addButton setImage:kDSubImgPng forState:UIControlStateNormal];
                [_addButton setImage:kDSubImgHoverPng forState:UIControlStateHighlighted];
            });
        }
        user = nil;
        m = nil;
        
        
    }];
}

#pragma mark 点击增删按钮事件
-(void)clickAddButtonAction:(UIButton*)button{
    // 开队列操作数据库
    [_queue addOperationWithBlock:^{
  
        // 模型
        selfMarketModel *m = [[selfMarketModel alloc] init];
        m.marketId = self.kId;
        m.marketName = self.kName;
        m.marketType = [[NSString alloc] initWithFormat:@"%d",self.kType];
        m.timestamp = [DCommon getTimestamp];
        m.isSyn = NO;
        m.userId = @"";
        UserModel *user = [UserModel um];
        if (user.userId>0) {
            m.userId = user.userId;
        }
        
        // 先查询是否存在
        BOOL isExit = [_db isExistSelfMarket:m];
        if (isExit) {
            // 删除
            [_db deleteSelfMarket:m];
        }else{
            // 添加
            [_db insertWithSelfMarket:m];
        }
        // 设置为已经操作过
        [DCommon SetIsChanged:YES];
        if (user.userId>0) {
            // 更新共享标识 先提交后更新
            [DCommon setIsSubmitThanUpdate:YES];
        }
        NSString *marketId = m.marketId;
        NSString *marketType = m.marketType;
        user = nil;
        m = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 点击按钮，通过按钮图片判断删减图标
            UIImage *img = [button imageForState:UIControlStateNormal];
            if ([img isEqual:kDAddImgPng]) {
                [_addButton setImage:kDSubImgPng forState:UIControlStateNormal];
                [_addButton setImage:kDSubImgHoverPng forState:UIControlStateHighlighted];
                
            }
            else{
                [_addButton setImage:kDAddImgPng forState:UIControlStateNormal];
                [_addButton setImage:kDAddImgHoverPng forState:UIControlStateHighlighted];
                // 删除分组
                [[PushNotificationHandler instance] deletePushTags:[NSString stringWithFormat:@"stock_%@_%@",marketId,marketType]];
                [[PushNotificationHandler instance] savePushTags];
            }
        });
    }];
    
}

#pragma mark 更新主视图的内容高度
-(void)updateMainViewHeight:(CGFloat)height{
    if (_mainView && !self.isHorizontal) {
        // 更新新的尺寸
        CGFloat newHeight = height+_defaultHeight+_bottomController.butonView.frame.size.height;
        CGFloat w = self.view.frame.size.width;
        _mainView.contentSize = CGSizeMake(w, newHeight);
        CGRect frame = _bottomController.view.frame;
        _bottomController.view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _bottomController.butonView.frame.size.height+height);
        // 把固定导航弄到前面来
        [_bottomController.view bringSubviewToFront:_bottomController.butonView];
    }
}

#pragma mark 返回主视图
-(void)returnBack{
   
        if (self.isBack) {
            // 返回到父级视图
            [self.navigationController popViewControllerAnimated:YES];
            [self free];
        }else{
            if (self.backController) {
                [self.navigationController popToViewController:self.backController animated:YES];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }

}


#pragma mark 创建参数视图元素
-(void)createTopView{
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        [_kTopView removeAllSubviews];
    }
    // 一些固定值
    CGFloat threeLineHeight = kTopHeight/3;
    CGFloat threeLineWidth = _kTopView.frame.size.width / 3;
    CGFloat fourLineWidth = threeLineWidth*2 / 3;
    CGFloat fourLineWidthBottom = _kTopView.frame.size.width / 4;
    CGFloat oneCharWidth = 18;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.isHorizontal) {
        threeLineWidth = _kTopView.frame.size.width / 4.4;
        fourLineWidth = threeLineWidth*2 / 3;
        if (self.screenFrame.size.height<500) {
            threeLineWidth = _kTopView.frame.size.width / 4.1;
            fourLineWidth = threeLineWidth*2 / 2.6;
        }
    }
    // 添加一个背景
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, threeLineHeight*2, _kTopView.frame.size.width, threeLineHeight)];
    bg.backgroundColor = ClearColor;
    [_kTopView addSubview:bg];
    // 添加参数名称
    // 总值
    UILabel *zhongzhi = [self createLabelWithFrame:CGRectMake(5, threeLineHeight*2, oneCharWidth*2, threeLineHeight) andFont:kFont andText:@"总值:" andSuperView:_kTopView];
    // 流值
    UILabel *liuzhi = [self createLabelWithFrame:CGRectMake(fourLineWidthBottom+10, threeLineHeight*2, oneCharWidth*2, threeLineHeight) andFont:kFont andText:@"流值:" andSuperView:_kTopView];
    // 市盈
    UILabel *shiying = [self createLabelWithFrame:CGRectMake(fourLineWidthBottom*2+13, threeLineHeight*2, oneCharWidth*2, threeLineHeight) andFont:kFont andText:@"市盈:" andSuperView:_kTopView];
    // 市净率
    UILabel *shijing = [self createLabelWithFrame:CGRectMake(fourLineWidthBottom*3+8, threeLineHeight*2, oneCharWidth*2, threeLineHeight) andFont:kFont andText:@"市净:" andSuperView:_kTopView];
    // 高
    UILabel *gao = [self createLabelWithFrame:CGRectMake(threeLineWidth, 0, oneCharWidth, threeLineHeight) andFont:kFont andText:@"高:" andSuperView:_kTopView];
    // 低
    UILabel *di = [self createLabelWithFrame:CGRectMake(threeLineWidth, threeLineHeight, oneCharWidth, threeLineHeight) andFont:kFont andText:@"低:" andSuperView:_kTopView];
    // 开
    UILabel *kai = [self createLabelWithFrame:CGRectMake(threeLineWidth+fourLineWidth, 0, oneCharWidth, threeLineHeight) andFont:kFont andText:@"开:" andSuperView:_kTopView];
    // 换
    UILabel *huan = [self createLabelWithFrame:CGRectMake(threeLineWidth+fourLineWidth, threeLineHeight, oneCharWidth, threeLineHeight) andFont:kFont andText:@"换:" andSuperView:_kTopView];
    // 量
    UILabel *liang = [self createLabelWithFrame:CGRectMake(threeLineWidth+fourLineWidth*2, 0, oneCharWidth, threeLineHeight) andFont:kFont andText:@"量:" andSuperView:_kTopView];
    // 额
    UILabel *e = [self createLabelWithFrame:CGRectMake(threeLineWidth+fourLineWidth*2, threeLineHeight, oneCharWidth, threeLineHeight) andFont:kFont andText:@"额:" andSuperView:_kTopView];
    
    // **********************************
    // 如果横屏 总值，流值，市盈，市净率要重新定位位置
    // **********************************
    if (self.isHorizontal) {
        // 如果是个股，调整下量和额的距离
        if (self.kType>0) {
            liang.frame = CGRectMake(threeLineWidth+fourLineWidth*2-10, 0, oneCharWidth, threeLineHeight);
            e.frame = CGRectMake(threeLineWidth+fourLineWidth*2-10, threeLineHeight, oneCharWidth, threeLineHeight);
            zhongzhi.frame = CGRectMake(threeLineWidth+fourLineWidth*3-15, 0, oneCharWidth*2, threeLineHeight);
            liuzhi.frame = CGRectMake(threeLineWidth+fourLineWidth*3-15, threeLineHeight, oneCharWidth*2, threeLineHeight);
        }else{
            zhongzhi.frame = CGRectMake(threeLineWidth+fourLineWidth*3+5, 0, oneCharWidth*2, threeLineHeight);
            liuzhi.frame = CGRectMake(threeLineWidth+fourLineWidth*3+5, threeLineHeight, oneCharWidth*2, threeLineHeight);
        }

        // 屏幕太小就不显示市盈和市净率了
        if (self.screenFrame.size.height>500) {
            shiying.frame = CGRectMake(threeLineWidth+fourLineWidth*4, 0, oneCharWidth*2, threeLineHeight);
            shijing.frame = CGRectMake(threeLineWidth+fourLineWidth*4, threeLineHeight, oneCharWidth*2, threeLineHeight);
        }else{
            shiying.hidden = YES;
            shijing.hidden = YES;
        }
        
    }
    
    
    // 添加参数值
    // 当前值
    _lbCurentPrice = [self createLabelWithFrame:CGRectMake(0, 0, threeLineWidth, threeLineHeight+10) andFont:kDefaultFont andText:@"--" andSuperView:_kTopView];
    _lbCurentPrice.textAlignment = NSTextAlignmentCenter;
    _lbCurentPrice.font = [UIFont fontWithName:kFontName size:20];
    if (self.isHorizontal) {
        _lbCurentPrice.font = [UIFont fontWithName:kFontName size:20];
    }
    // 涨跌额
    _lbCurentChangeRate = [self createLabelWithFrame:CGRectMake(0, threeLineHeight, threeLineWidth/2, threeLineHeight) andFont:kFont andText:@"--" andSuperView:_kTopView];
    _lbCurentChangeRate.textAlignment = NSTextAlignmentCenter;
    _lbCurentChangeRate.font = [UIFont fontWithName:kFontName size:12];
    UIColor *color = kRedColor;
    if ([[_lbCurentChangeRate.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"]) {
        color = kGreenColor;
    }
    _lbCurentChangeRate.textColor = color;
    _lbCurentPrice.textColor = color;
    
    // 涨跌值
    _lbCurentChangeValue = [self createLabelWithFrame:CGRectMake(threeLineWidth/2, threeLineHeight, threeLineWidth/2, threeLineHeight) andFont:kFont andText:@"--" andSuperView:_kTopView];
    _lbCurentChangeValue.textAlignment = NSTextAlignmentCenter;
    _lbCurentChangeValue.textColor = color;
    _lbCurentChangeValue.font = [UIFont fontWithName:kFontName size:12];
    
    // 总值
    _lbMarketValue = [self createLableWithLable:zhongzhi andCharCount:2 andSuperView:_kTopView];
    // 流值
    _lbCirculateMarketValue = [self createLableWithLable:liuzhi andCharCount:2 andSuperView:_kTopView];
    
    // 市盈
    _lbPe = [self createLableWithLable:shiying andCharCount:2 andSuperView:_kTopView];
    // 市净
    _lbPriceToBook = [self createLableWithLable:shijing andCharCount:2 andSuperView:_kTopView];
    if (self.isHorizontal) {
        // 屏幕太小就不显示市盈和市净率了
        if (self.screenFrame.size.height<500) {
            _lbPe.hidden = YES;
            _lbPriceToBook.hidden = YES;
        }
    }
    
    // 高
    _lbHeightPrice = [self createLableWithLable:gao andCharCount:1 andSuperView:_kTopView];
    // 开
    _lbOpenPrice = [self createLableWithLable:kai andCharCount:1 andSuperView:_kTopView];
    // 量
    _lbOpenPrice = [self createLableWithLable:liang andCharCount:1 andSuperView:_kTopView];
    // 低
    _lbOpenPrice = [self createLableWithLable:di andCharCount:1 andSuperView:_kTopView];
    // 换
    _lbOpenPrice = [self createLableWithLable:huan andCharCount:1 andSuperView:_kTopView];
    // 额
    _lbOpenPrice = [self createLableWithLable:e andCharCount:1 andSuperView:_kTopView];
    
}
#pragma mark 创建一个Label
-(UILabel*)createLabelWithFrame:(CGRect)frame andFont:(UIFont*)font andText:(NSString*)text andSuperView:(UIView*)view{
    UILabel *temp = [[UILabel alloc] initWithFrame:frame];
    temp.textColor = UIColorFromRGB(0x000000);
    temp.backgroundColor = ClearColor;
    temp.font = font;
    temp.text = text;
    [view addSubview:temp];
    return temp;
}
#pragma mark 创建相对位置lable
-(UILabel*)createLableWithLable:(UILabel*)label andCharCount:(int)count andSuperView:(UIView*)view{
    // 一些固定值
    CGFloat threeLineHeight = kTopHeight/3;
    CGFloat threeLineWidth = _kTopView.frame.size.width / 3;
    CGFloat fourLineWidth = threeLineWidth*2 / 3;
    //CGFloat fourLineWidthBottom = _kTopView.frame.size.width / 4;
    CGFloat oneCharWidth = 14;
    UILabel *temp = [self createLabelWithFrame:CGRectMake(label.frame.origin.x+oneCharWidth*count+(count>=2?0:2), label.frame.origin.y, fourLineWidth-oneCharWidth+(count>=2?0:2), threeLineHeight) andFont:kFont andText:@"--" andSuperView:view];
    temp.textColor = UIColorFromRGB(0x000000);
    temp.textAlignment = NSTextAlignmentLeft;
    return temp;
    
}

#pragma mark ---------------------------视图事件方法响应------------------------------
#pragma mark 点击下一页按钮
-(void)clickNextButtonAction:(UIButton*)button{
    if (self.isHorizontal) {
        button.alpha = 0.5;
    }else{
       // button.backgroundColor = UIColorFromRGB(0x222222);
    }
    button.enabled = NO;
    _preBtn.enabled=NO;
    [self performSelector:@selector(clickNextButtonActionDelay:) withObject:button afterDelay:0.3];
}
-(void)clickNextButtonActionDelay:(UIButton*)button{
    if (self.pageArray) {
        int nextPage = self.currentPage + 1;
        if (nextPage<self.pageArray.count) {
            // 横屏的时候直接翻页
            if (self.isHorizontal) {
                // 跳转到某页
                self.currentPage = nextPage;
                [self jumpIntoPage];
            }else{
                // 滚动到下一页
                NSLog(@"当前页：%i",nextPage);
               // [_mainScrollView setContentOffset:CGPointMake(nextPage*320, 0) animated:YES];
                [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x+_mainScrollView.frame.size.width, _mainScrollView.contentOffset.y) animated:YES];
            }
        }
        else{
            // 没有下一页了
        }
    }
}
#pragma mark 点击上一页按钮
-(void)clickPreButtonAction:(UIButton*)button{
    if (self.isHorizontal) {
        button.alpha = 0.5;
    }else{
       // button.backgroundColor = UIColorFromRGB(0x222222);
    }
    button.enabled = NO;
    _nextBtn.enabled=NO;
    [self performSelector:@selector(clickPreButtonActionDelay:) withObject:button afterDelay:0.3];
}
-(void)clickPreButtonActionDelay:(UIButton*)button{
    if (self.pageArray) {
        int prePage = self.currentPage - 1;
        if (prePage<self.pageArray.count && prePage>=0) {
            // 横屏的时候直接翻页
            if (self.isHorizontal) {
                // 跳转到某页
                self.currentPage = prePage;
                [self jumpIntoPage];
            }else{
                // 滚动到上一页
                NSLog(@"当前页：%i",prePage);
               // [_mainScrollView setContentOffset:CGPointMake(prePage*320, 0) animated:YES];
                [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x-_mainScrollView.frame.size.width, _mainScrollView.contentOffset.y) animated:YES];

            }
        }else{
            // 返回根控制器
            //[self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark 点击提醒按钮事件
-(void)clickRemindButtonAction:(UIButton*)button{
    button.backgroundColor = UIColorFromRGB(0x222222);
    // 检查是否登录
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        // 进入提醒界面
        // 读取数据库
        [_queue addOperationWithBlock:^{
            selfMarketModel *m = [_db getSelfMarketModelWithMarketId:self.kId andMarketType:[[NSString alloc] initWithFormat:@"%d",self.kType]];
            if (m.marketId) {
                // 进入提醒界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    zRemindViewController *remind = [[zRemindViewController alloc] init];
                    remind.marketName = m.marketName;
                    remind.marketId = m.marketId;
                    remind.marketType = m.marketType;
                    remind.newsValue = self.newsPrice;
                    remind.changeRate = self.changeRate;
                    self.isBack = YES;
                    [self.navigationController pushViewController:remind animated:YES];
                    remind = nil;
                    button.backgroundColor = ClearColor;
                });
            }else{
                // 进入提醒界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    zRemindViewController *remind = [[zRemindViewController alloc] init];
                    remind.marketName = self.kName;
                    remind.marketId = self.kId;
                    remind.marketType = [[NSString alloc] initWithFormat:@"%d",self.kType];
                    remind.newsValue = self.newsPrice;
                    remind.changeRate = self.changeRate;
                    self.isBack = YES;
                    [self.navigationController pushViewController:remind animated:YES];
                    remind = nil;
                    button.backgroundColor = ClearColor;
                });
            }
       
        }];
    }else{
        button.backgroundColor = ClearColor;
        // 没登陆就弹出登陆提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆提示" message:@"自选股服务需要登陆才可使用，请先登陆。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登陆", nil];
        [alert show];
    }
    user = nil;
}

#pragma mark 跳到登陆界面
-(void)gotoLogin{
    self.isBack = YES;
    [CommonOperation goTOLogin];
}

#pragma mark 点击确定登陆按钮
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self gotoLogin];
    }
}

#pragma mark 清空本地预警信息设置
-(void)clearRemindDatasWithRemindType:(NSString*)remindType andkId:(NSString*)kId andKtype:(NSString*)kType{
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        if (!_db) {
            _db = [[selfMarketDB alloc] init];
        }
        selfMarketModel *model = [_db getSelfMarketModelWithMarketId:kId andMarketType:kType];
        if (model.marketId) {
            // 清空 上涨设置值
            if ([remindType isEqualToString:@"0"]) {
                model.heightPrice = @"";
            }
            // 清空 下跌设置值
            if ([remindType isEqualToString:@"1"]) {
                model.lowPrice = @"";
            }
            // 清空 涨幅设置值
            if ([remindType isEqualToString:@"2"]) {
                model.todayChangeRate = @"";
            }
            [_db updateRemindWithSelfMarket:model];
            // 网络上也要同步清空数据
            // 封装数据
            NSMutableArray *list = [self packageList:model];
            // 同步清空远程数据
            [_request requestSelfMarketRemind:self List:list isAsyn:YES];
            list = nil;
            model = nil;
        }
        
    }
    user = nil;
}

#pragma mark 封装股票集合
-(NSMutableArray*)packageList:(selfMarketModel*)model{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if (model) {
        // 单独更新一个提醒数据
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             model.marketId,@"marketId",
                             model.marketType,@"type",
                             model.heightPrice,@"heightPrice",
                             model.lowPrice,@"lowPrice",
                             model.todayChangeRate,@"todayChangeRate",
                             model.isNotice,@"isNotice",
                             model.isNews,@"isNews",
                             nil];
        [list addObject:dic];
        dic = nil;
    }
    return list;
}

#pragma mark 接口返回
-(void)getSelfMarketRemindBundle:(BOOL)isSuccess{
    if (isSuccess) {
        NSLog(@"---DFM---提醒数据同步成功");
    }else{
        NSLog(@"---DFM---提醒数据同步失败");
    }
    
}

#pragma mark ---------------------------ScrollView 代理实现------------------------
#pragma mark 上下滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==_mainView) {
        // 通知block
        if (self.scrollBlock) {
            self.scrollBlock(self);
        }
        // 把固定导航弄到前面来
        CGRect frame = _bottomController.view.frame; // 底部控制器导航栏的原始值
        CGRect btFrame = _bottomController.butonView.frame ;// 底部导航栏按钮位置原始值
        CGFloat y = scrollView.bounds.origin.y; // 当前y
        CGFloat oldY = _kChartController.view.frame.size.height+_kChartController.view.frame.origin.y; // 底部控制器导航栏的原始Y
        CGFloat olxBtY = 0;
        
        // 固定
        if (self.isFix) {
            // 固定在顶部
            if (y>=frame.origin.y && y<=(frame.size.height+frame.origin.y)) {
                _bottomController.butonView.frame = CGRectMake(btFrame.origin.x,
                                                               y-(oldY),
                                                               btFrame.size.width,
                                                               btFrame.size.height);
            }else if((y)<oldY){
                _bottomController.butonView.frame = CGRectMake(btFrame.origin.x,
                                                               olxBtY,
                                                               btFrame.size.width,
                                                               btFrame.size.height);
            }
        }else{
            _bottomController.butonView.frame = CGRectMake(btFrame.origin.x,
                                                           olxBtY,
                                                           btFrame.size.width,
                                                           btFrame.size.height);
        }
    }
    
    
    if (scrollView==_mainScrollView) {
        //NSLog(@"%@",_mainScrollView.subviews);
        // 得到每页宽度
        CGFloat pageWidth = scrollView.frame.size.width;
        // 根据当前的x坐标和页宽度计算出当前页
        int x = (int)scrollView.contentOffset.x;
        int w = (int)pageWidth;
        if (x % w == 0) {
            int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 2;
            //NSLog(@"---DFM---正在滚动页码%d,%@",currentPage,scrollView);
            // 上一页 下一页
            if (currentPage!=_page) {
                if (currentPage==_page-1) {
                    if (scrollView.contentOffset.x==0) {
                        self.currentPage --;
                    }
                }else{
                    self.currentPage ++;
                }
                // 跳到下一页上一页
                [self performSelector:@selector(jumpIntoPage) withObject:nil afterDelay:0.3];
            }
        }
    }
    
    
    
}

#pragma mark 跳到上一页下一页
-(void)jumpIntoPage{
    self.isClickTransformButton = NO;
    self.currentButtonIndex = 0;
    // 取得上一页的数据
    if (self.currentPage<self.pageArray.count) {
        [self free];
        NSArray *currentArray = [self.pageArray objectAtIndex:self.currentPage];
        self.kId = [currentArray objectAtIndex:0];
        self.kName = [currentArray objectAtIndex:1];
        self.kType = [[currentArray objectAtIndex:2] intValue];
        self.pageArray = self.pageArray;
        self.backController = self.backController;
        currentArray = nil;
    }
    [self show];
}

#pragma mark ---------------------------Mj刷新的代理实现----------------------------

#pragma mark 添加刷新下拉
-(void)addHeader{
    if (!self.isHorizontal) {
        __unsafe_unretained KLineViewController *bc = self;
        _header = [MJRefreshHeaderView header];
        _header.scrollView = _mainView;
        _header.activityView.color = UIColorFromRGB(0x888888);
        // 开始刷新Block
        _header.beginRefreshingBlock = ^(MJRefreshBaseView* refreshView){
            [bc.transformImage start];
            // 回调更新块
            if (bc.kUpdateBlock) {
                bc.kUpdateBlock(bc);
            }
            [bc performSelector:@selector(beginRefreshTableView:) withObject:refreshView afterDelay:0];
        };
        // 结束刷新Block
        _header.endStateChangeBlock = ^(MJRefreshBaseView* refreshView){
            [bc.transformImage stop];
            //[bc endRefreshTableView:refreshView];
            [bc performSelector:@selector(endRefreshTableView:) withObject:refreshView afterDelay:0];
        };
    }
}

#pragma mark 添加上拉控件
-(void)addFooter{
    if (!self.isHorizontal) {
        __unsafe_unretained KLineViewController *bc = self;
        _footer = [MJRefreshFooterView footer];
        _footer.scrollView = _mainView;
        _footer.activityView.color = UIColorFromRGB(0x888888);
        // 开始刷新Block
        _footer.beginRefreshingBlock = ^(MJRefreshBaseView* refreshView){
            bc.refreshView = refreshView;
            // 回调加载更多块
            if (bc.kMoreLoadBlock) {
                bc.kMoreLoadBlock(bc);
            }
            [bc performSelector:@selector(moreRefreshTableView:) withObject:refreshView afterDelay:0];
        };
        // 结束刷新Block
        _footer.endStateChangeBlock = ^(MJRefreshBaseView* refreshView){
            bc.refreshView = refreshView;
            //[bc endRefreshTableView:refreshView];
            [bc performSelector:@selector(endRefreshTableView:) withObject:refreshView afterDelay:0];
        };
    }
    
}

#pragma mark 开始刷新
-(void)beginRefreshTableView:(MJRefreshBaseView*)refreshView{
    if (_kChartController) {
        [_kChartController getkLineIndex:NO];
    }
    NSLog(@"---DFM---beginRefreshTableView");
    [refreshView endRefreshing];
}

#pragma mark 刷新加载更多
-(void)moreRefreshTableView:(MJRefreshBaseView*)refreshView{
    
    NSLog(@"---DFM---mainTableMoreRefreshing");
    //[refreshView endRefreshing];
}

#pragma mark 结束刷新
-(void)endRefreshTableView:(MJRefreshBaseView*)refreshView{
    NSLog(@"---DFM---endRefreshTableView");
    
}



@end
