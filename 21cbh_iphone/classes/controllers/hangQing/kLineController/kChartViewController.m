//
//  kChartViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kChartViewController.h"
#import "kChartView.h"
#import "hangqingHttpRequest.h"
#import "dropDownMenu.h"
#import "kChartTimeShareView.h"
#import "FiveSpeedViewController.h"
#import "TimeShareDetailViewController.h"
#import "timeShareChartModel.h"
#import "DCommon.h"
#import "stockBetsModel.h"
#import "KLineViewController.h"
#import "kLineModel.h"
#import "loadingView.h"
#import "kFiveDaysTimeShareView.h"
#import "KLineViewController.h"
#import "NoticeOperation.h"
#import "kTabbarController.h"

#define kButtonTitleColor UIColorFromRGB(0x000000)
#define kButtonTitleCurrentColor kBrownColor
#define kButtonFont [UIFont systemFontOfSize:15]
#define kDDownArrowsPng [UIImage imageNamed:@"D_DownArrows.png"]
#define kDUpArrowsPng [UIImage imageNamed:@"D_UpArrows.png"]
#define kDDownArrowsWhitePng [UIImage imageNamed:@"D_DownArrowsWhite.png"]
#define kDUpArrowsBlackPng [UIImage imageNamed:@"D_UpArrowsBlack.png"]
#define kDZoomInPng [UIImage imageNamed:@"D_ZoomIn.png"]
#define kDZoomInHoverPng [UIImage imageNamed:@"D_ZoomInHover.png"]
#define kDZoomOutPng [UIImage imageNamed:@"D_ZoomOut.png"]
#define kDZoomOutHoverPng [UIImage imageNamed:@"D_ZoomOutHover.png"]
#define kDRefreshTime 60

@interface kChartViewController (){
    
    // 视图
    kChartView *_kChart; // K线图表
    kChartTimeShareView *_kChartTimeShare;// 分时图
    kChartTimeParamModel *_ktimeParamModel;// 分时图参数模型
    UIView *_tempBox;// 翻页时用到的美化框
    UIView *_butonView ;// 分类按钮
    UIView *_butonBottomView; // 股吧等按钮视图
    hangqingHttpRequest *_request; // 请求分时图或者k线图
    hangqingHttpRequest *_requestBets; // 请求盘口
    UIView *_fview; // 五档盒子
    FiveSpeedViewController *_fiveSpeedView;// 五档视图控制器
    TimeShareDetailViewController *_timeShareDetailView;// 交易明细控制器
    dropDownMenu *_minuteView ;// 分钟选择
    UIButton *_zoomInButton;// 放大镜按钮
    UIButton *_zoomOutButton;// 缩小镜按钮
    UIButton *_restorationButton;// 复权按钮
    
    // 变量
    NSMutableArray *_data; // 分时图k线图数据
    stockBetsModel *_betsData; // 盘口数据模型
    NSMutableArray *_btTitles;
    NSString *_kLineType ;// 线类型
    int _count;// 总数
    int _allCount;// 最大的总数，每次都请求最大的总数
    BOOL _isRestoration ;// 是否复权
    __block int _currentButtonIndex; // 当前点击的按钮下标
    CGFloat _klineWidth ;// k线的宽度
    CGFloat _klinePadding; // k线的间距
    CGFloat _klineBoxWidth ;// K线盒子的宽度
    CGFloat _klineBoxHeight;// k线图区域的高度
    // 接口参数对接
    CGFloat _heightPrice; // 及时最高成交价
    CGFloat _closePrice; // 昨日收盘价
    double _seconds; // 下次开盘的毫秒差
    BOOL _isStop;// 是否停盘了
    NSString *_timeFrame;// 时间段
    NSTimer *_timer;// 定时刷新
    loadingView *_loadingView;// 加载视图
    UIActivityIndicatorView *_loadImg;// 加载控件
    int _days;// 分时图天数
    UIButton *_transButton;// 切换按钮
    UIButton *_currentFiveButton;//当前高亮的五档按钮
    BOOL _stopRefresh ; // 停止刷新
    
    kChartParamModel *kchartParam;// K线图参数模型
    
}

@end

@implementation kChartViewController


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
    
    _stopRefresh = NO;
    // 初始化参数
    [self initParam];
	// 初始化视图
    [self initView];
    // 加载默认数据
    //[self getkLineIndex:YES];
    [self clearTimer];
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _stopRefresh = NO;
    // [self clearTimer];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_stopRefresh) {
        _stopRefresh = NO;
        [self getkLineIndex:YES];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _stopRefresh = YES;
    [self clearTimer];
}

-(void)dealloc{
    [self free];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //self.view = nil;
    
}



#pragma mark -----------------------------------自定义方法---------------------------------
#pragma mark 清除对象
-(void)free{
    [self clearTimer];
    // 清除请求
    [_request clearRequest];
    _request = nil;
    // 清除请求
    [_requestBets clearRequest];
    _requestBets = nil;
    [_kChart free];
    [_kChartTimeShare free];
    [_fiveSpeedView free];
    [_timeShareDetailView free];
    _kChart = nil;
    _ktimeParamModel = nil;
    _kChartTimeShare = nil;
    _fiveSpeedView = nil;
    _timeShareDetailView = nil;
    
    _minuteView = nil;
    _loadingView = nil;
    [self.view removeAllSubviews];
}
#pragma mark 初始化控制器
-(id)initWithParentController:(KLineViewController*)kLineView{
    self = [super init];
    if (self) {
        self.kLineView = kLineView;
        NSLog(@"---DFM---initWithParentController");
    }
    return self;
}
#pragma mark 初始化参数
-(void)initParam{
    [self free];
    _request = [[hangqingHttpRequest alloc] init];
    _requestBets = [[hangqingHttpRequest alloc] init];
    _kLineType = @"0"; // 默认为分时图 0分时图 d日k w周k m月k
    _count = 0;
    _isRestoration = NO; // 默认不复权
    _currentButtonIndex = 0;
    _klineBoxWidth = 280; // 盒子的宽度
    _klineBoxHeight = 300;// 盒子的高度
    _klinePadding = 0.5; // k线间的间距
    _klineWidth = 5; // K线的宽度
    _days = 1; // 默认为当天的分时图
    if (self.kLineView.isFirst) {
        // 计算最大总数，默认就是屏幕最宽的时候的最大值
        _allCount = (self.view.frame.size.height-40) / (1+0.5);
    }
    
}
#pragma mark 视图初始化
-(void)initView{
    self.view.backgroundColor = kMarketBackground;
    self.view.userInteractionEnabled = YES;
    // 添加按钮
    [self addTabButton];
    // 添加复权按钮
    [self addRestoration];
    // 添加放大镜按钮
    [self addZoomButtons];
    // 添加切换旋转按钮
    [self addViewTransformButton];
    // 点击旋转刷新按钮
    __unsafe_unretained kChartViewController *kc = self;
    self.kLineView.transformImage.clickActionBlock = ^(transformImageView *transform){
        // 更新K线图数据
        [kc getkLineIndex:YES];
    };
    _request.errorRequest = ^(hangqingHttpRequest *request){
        // 网络出错处理
        kc.kLineView.mainScrollView.scrollEnabled = YES;
        // 按钮恢复
        [kc buttonEnabled:YES];
        // 隐藏加载视图
        [kc hideLoadingView:YES];
    };
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        NSLog(@"---DFM---数据返回有误那");
        // 数据返回有误
        kc.kLineView.mainScrollView.scrollEnabled = YES;
        // 按钮恢复
        [kc buttonEnabled:YES];
        // 隐藏加载视图
        [kc hideLoadingView:YES];
    };
    _requestBets.errorRequest = ^(hangqingHttpRequest *request){
        // 网络出错处理
        kc.kLineView.mainScrollView.scrollEnabled = YES;
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
        // 按钮恢复
        [kc buttonEnabled:YES];
        // 隐藏加载视图
        [kc hideLoadingView:YES];
    };
    _requestBets.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        // 数据返回有误
        kc.kLineView.mainScrollView.scrollEnabled = YES;
        // 按钮恢复
        [kc buttonEnabled:YES];
        // 隐藏加载视图
        [kc hideLoadingView:YES];
    };
    
    // 显示未加载的分时图
    if (!self.kLineView.isHorizontal) {
        if (_currentButtonIndex==0) {
            [self addkChartTimeShareView:NO];
        }
    }
    
    
}
#pragma mark 调用缓存
-(void)initDatas{
    // 取盘口缓存
    NSMutableArray *dataArray = [DCommon setPanKouToLocalWithDatas:nil andkId:self.kLineView.kId andkType:self.kLineView.kType andIsGet:YES];
    if (dataArray.count>0) {
        _betsData = [[stockBetsModel alloc] initWithDic:[dataArray firstObject]];
        if (_betsData) {
            [self updateStockBetsView];
        }
    }
    dataArray = nil;
}
#pragma mark 主界面准备就绪，开始运行K线图
-(void)startRun{
    // 清掉占位框
    if (_tempBox) {
        [_tempBox removeFromSuperview];
    }
    // 加载并显示分时图
    [self intoShow];
    // 调用缓存
    [self initDatas];
}

#pragma mark --------------------------构造视图方法-------------------------------

#pragma mark k线切换按钮
-(void)addTabButton{
    // 初始化标题 根据需求隐藏分钟选项
    _btTitles = [[NSMutableArray alloc] initWithObjects:@"分时",@"五日",@"日K",@"周K",@"月K", nil];
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.view.frame.size.width;
    CGFloat btHeight = 40;
    CGFloat btWidth = w / _btTitles.count;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.kLineView.isHorizontal) {
        x = 5;
        y = 235;
        btWidth = 50;
        if (self.kLineView.screenFrame.size.height<500) {
            btWidth = 45;
        }
        w = btWidth*_btTitles.count;
        btHeight = 30;
    }
    _butonView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, btHeight)];
//    _butonView.backgroundColor = UIColorFromRGB(0xe1e1e1);
//    _butonView.layer.borderColor = UIColorFromRGB(0x000000).CGColor;
//    _butonView.layer.borderWidth = 1;
    // 导航按钮
    x = 0;
    for (int i=0;i<_btTitles.count;i++) {
        NSString *key = [_btTitles objectAtIndex:i];
        UIButton *hqbtn = [[UIButton alloc] initWithFrame:CGRectMake(x, 0.5, btWidth,btHeight-1)];
        [hqbtn setTitle:key forState:UIControlStateNormal];
        [hqbtn setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
        [hqbtn setTitleColor:kButtonTitleCurrentColor forState:UIControlStateHighlighted];
        [hqbtn setBackgroundColor:UIColorFromRGB(0xe1e1e1)];
        hqbtn.titleLabel.font = kButtonFont;
        hqbtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        hqbtn.tag = i;
        // 隐藏分钟选项
//        if (i==_btTitles.count-1) {
//            // 最后一个按钮添加一个三角形
//            UIImageView *i = [[UIImageView alloc] initWithFrame:CGRectMake(btWidth/5*4,
//                                                                           (btHeight-kDDownArrowsPng.size.height)/2,
//                                                                           kDDownArrowsPng.size.width,
//                                                                           kDDownArrowsPng.size.height)];
//            i.image = kDUpArrowsPng;
//            [hqbtn addSubview:i];
//            i = nil;
//            hqbtn.titleLabel.frame = CGRectMake(0, 0, btWidth-kDDownArrowsPng.size.width, btHeight);
//        }
        [hqbtn addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_butonView addSubview:hqbtn];
        hqbtn = nil;
        x += btWidth;
    }
    // 顶部线
//    UIView *topline = [DCommon drawLineWithSuperView:_butonView position:YES];
//    topline.backgroundColor = UIColorFromRGB(0x000000);
//    topline = nil;
    // 移动线
    UIView *line = [DCommon drawLineWithSuperView:_butonView position:NO];
    line.backgroundColor = kBrownColor;
    line.frame = CGRectMake(line.frame.origin.x, btHeight-4, btWidth, 4);
    line = nil;
    [self.view addSubview:_butonView];
    
}

#pragma mark 五档与明细按钮
-(void)addFiveButton:(BOOL)isRequest{
    if (!_fview && _kChartTimeShare) {
        CGFloat x = _kChartTimeShare.width+_kChartTimeShare.frame.origin.x-0.5;
        CGFloat y = _kChartTimeShare.frame.origin.y;
        CGFloat w = 93;
        CGFloat h = _kChartTimeShare.frame.size.height;
        // 如果第一次让五档视图停在右边边框外面
        if (self.kLineView.isFirst && isRequest) {
            x = self.view.frame.size.width;
            // **********************************
            // 如果横屏
            // **********************************
            if (self.kLineView.isHorizontal) {
                x = self.view.frame.size.height;
            }
        }
        _fview = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
        _fview.backgroundColor = ClearColor;
        _fview.layer.borderWidth = 0.5;
        _fview.layer.borderColor = UIColorFromRGB(0x808080).CGColor;
        _fview.hidden = NO;
        [self.view addSubview:_fview];
        // 五档按钮
        NSArray *title = [[NSArray alloc] initWithObjects:@"五档",@"明细", nil];
        for (int i=0; i<2; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*w/2, 0, w/2, 35)];
            [button setTitle:[title objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
            [button setTitleColor:kBrownColor forState:UIControlStateSelected];
            button.backgroundColor = ClearColor;
            button.tag = i;
            button.titleLabel.font = [UIFont fontWithName:kFontName size:14];
            [button addTarget:self action:@selector(clickFiveButton:) forControlEvents:UIControlEventTouchUpInside];
            [_fview addSubview:button];
            button = nil;
        }
        // 加根底线
        UIView *fiveLine = [[UIView alloc] initWithFrame:CGRectMake(0, 35-4, _fview.frame.size.width/2, 4)];
        fiveLine.backgroundColor = kBrownColor;
        [_fview addSubview:fiveLine];
        // 五档内容区域
        UIView *cview = [[UIView alloc] initWithFrame:CGRectMake(0,35-0.5, _fview.frame.size.width, _kChartTimeShare.yHeight-_fview.frame.size.height+0.5)];
        cview.backgroundColor = ClearColor;
        cview.layer.borderWidth = 0.5;
        cview.layer.borderColor = UIColorFromRGB(0x808080).CGColor;
        [_fview addSubview:cview];
        cview = nil;
    }
    
}


#pragma mark 添加复权按钮
-(void)addRestoration{
    CGFloat rWidth = 40;
    CGFloat rHeight = 15;
    CGFloat x = self.view.frame.size.width-rWidth-5;
    CGFloat y = _butonView.frame.origin.y+_butonView.frame.size.height+3;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.kLineView.isHorizontal) {
        x = _butonView.frame.size.width + 260;
        y = 20;
        if (self.kLineView.screenFrame.size.height<500) {
            x -= 55;
        }
    }
    _restorationButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, rWidth, rHeight)];
    _restorationButton.backgroundColor = kBrownColor;
    [_restorationButton setTitle:@"复权" forState:UIControlStateNormal];
    _restorationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _restorationButton.titleLabel.font = [UIFont fontWithName:kFontName size:10];
    _restorationButton.layer.cornerRadius = 8;
    [_restorationButton addTarget:self action:@selector(clickRestorationButton) forControlEvents:UIControlEventTouchUpInside];
    _restorationButton.hidden = YES;
    [self.view addSubview:_restorationButton];
    [self.view bringSubviewToFront:_restorationButton];
}

#pragma mark 添加k线图表控件
-(void)addkChartView{
    if (_kChart) {
        [_kChart free];
        _kChart = nil;
    }
    // 创建k线图
    if (!_kChart) {
        // 防止复权按钮被覆盖
        [self.view bringSubviewToFront:_restorationButton];
        CGFloat x = 5;
        CGFloat y = _butonView.frame.origin.y+_butonView.frame.size.height+10;
        CGFloat w = self.view.frame.size.width-10;
        CGFloat h = _klineBoxHeight;
        _klineBoxWidth = 270;
        // **********************************
        // 如果横屏
        // **********************************
        if (self.kLineView.isHorizontal) {
            if (self.kLineView.isFirst) {
                w = self.view.frame.size.height - 10;
            }
            x = 5;
            y = 5;
            _klineBoxWidth = w - 40;
            // 兼容4S
            if (self.kLineView.screenFrame.size.width<=500) {
                _klineBoxWidth = w - 40 ;
            }
        }
        if (self.kLineView.isFirst) {
            x = -self.view.frame.size.width;
        }
        
        // 实际显示的数量
        _count = (_klineBoxWidth-1) / (_klineWidth+_klinePadding); // K线中实体的总数
        _kChart = [[kChartView alloc] initWithFrame:CGRectMake(x,y,w,h)];
        [self.view addSubview:_kChart];
        kchartParam = nil;
        if (!kchartParam) {
            kchartParam = [[kChartParamModel alloc] init];
            kchartParam.width = _klineBoxWidth;
            kchartParam.parent = self.kLineView;
        }
        
        [_kChart startWith:kchartParam];
        // 防止复权按钮被覆盖
        [self.view bringSubviewToFront:_restorationButton];
        // 手指按下回调
        __unsafe_unretained kChartViewController *ts = self;
        _kChart.pressDownBlock = ^(kLineModel *Model){
            NSArray *views = ts.kLineView.kTopView.subviews;
            // 当期最新值
            UILabel *v = (UILabel*)[views objectAtIndex:11];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f",[Model.closePrice floatValue]];
            v.textColor = kRedColor;
            // 容错处理吧
            if ([Model.changeValue isEqual:[NSNull null]]) {
                Model.changeValue  = @"";
            }
            if ([Model.heightPrice isEqual:[NSNull null]]) {
                Model.heightPrice  = @"";
            }
            if ([Model.lowPrice isEqual:[NSNull null]]) {
                Model.lowPrice  = @"";
            }
            if ([Model.volume isEqual:[NSNull null]]) {
                Model.volume  = @"";
            }
            if ([Model.volumePrice isEqual:[NSNull null]]) {
                Model.volumePrice  = @"";
            }
            if ([Model.changeRate isEqual:[NSNull null]]) {
                Model.changeRate  = @"";
            }
            if ([Model.openPrice isEqual:[NSNull null]]) {
                Model.openPrice  = @"";
            }
            if ([Model.changeValue floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            
            // 涨跌幅
            v = (UILabel*)[views objectAtIndex:12];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f%%",[Model.changeRate floatValue]];
            v.textColor = kRedColor;
            if ([Model.changeValue floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 涨跌额
            v = (UILabel*)[views objectAtIndex:13];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f",[Model.changeValue floatValue]];
            v.textColor = kRedColor;
            if ([Model.changeValue floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 最高
            v = (UILabel*)[views objectAtIndex:18];
            v.text = [DCommon stringChange:Model.heightPrice];
            v.textColor = kRedColor;
            if ([Model.heightPrice floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 开盘价
            v = (UILabel*)[views objectAtIndex:19];
            v.text = [DCommon stringChange:Model.openPrice];
            v.textColor = kRedColor;
            if ([Model.openPrice floatValue]<0) {
                v.textColor = kGreenColor;
            }
            // 最低
            v = (UILabel*)[views objectAtIndex:21];
            v.text = [DCommon stringChange:Model.lowPrice];
            v.textColor = kRedColor;
            if ([Model.lowPrice floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 成交量
            v = (UILabel*)[views objectAtIndex:20];
            v.text = [DCommon numToUnits:[Model.volume floatValue]/100];
            v = nil;
            // 换手率
            v = (UILabel*)[views objectAtIndex:22];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f%%",[Model.turnoverRate floatValue]];
            v = nil;
            // 成交额
            v = (UILabel*)[views objectAtIndex:23];
            v.text = [DCommon numToUnits:[Model.volumePrice floatValue]];
            v = nil;
        };
        // 手指移开
        _kChart.pressUpBlock = ^(kLineModel *Model){
            [ts updateStockBetsView];
        };
        // k线处理完成就会调用
        _kChart.finishedBlock = ^(kChartView *kchartView){
            // 如果K线宽度符合预设值则按钮恢复使用
            if (ts->_klineWidth<10) {
                [ts->_zoomInButton setImage:kDZoomInPng forState:UIControlStateNormal];
                ts->_zoomInButton.alpha = 1;
                ts->_zoomInButton.enabled = YES;
            }else{
                [ts->_zoomInButton setImage:kDZoomInPng forState:UIControlStateNormal];
                ts->_zoomInButton.alpha = 0.5;
                ts->_zoomInButton.enabled = NO;
            }
            if (ts->_klineWidth>2){
                [ts->_zoomOutButton setImage:kDZoomOutPng forState:UIControlStateNormal];
                ts->_zoomOutButton.alpha = 1;
                ts->_zoomOutButton.enabled = YES;
            }else{
                [ts->_zoomOutButton setImage:kDZoomOutPng forState:UIControlStateNormal];
                ts->_zoomOutButton.alpha = 0.5;
                ts->_zoomOutButton.enabled = NO;
            }
        };
        // 点击分时图手势
        _kChart.chartTapBlock = ^(kChartView *kView){
            [ts clickTransformButtonAction:nil];
        };
        // 添加完分时图再添加五档视图
        //[self addFiveButton];
        // 添加加载控件
        [self addLoadingView];
        // 重新加载数据
        [self getkLineIndex:YES];
    }
    // 显示放大镜还有复权ann
    if (_zoomInButton && _zoomOutButton) {
        _zoomOutButton.hidden = NO;
        _zoomInButton.hidden = NO;
    }
    if (_restorationButton) {
        _restorationButton.hidden = NO;
        if (_currentButtonIndex==3 || _currentButtonIndex==4) {
            _restorationButton.hidden = YES;
        }
        
    }
    if (_fview) {
        _fview.hidden = YES;
    }
    // 先清掉其他视图
    if (_kChartTimeShare) {
        [_kChartTimeShare free];
        _kChartTimeShare = nil;
    }
}

#pragma mark 添加分时图控件
-(void)addkChartTimeShareView:(BOOL)isRequest{
    NSLog(@"---DFM---ktype=%d",self.kLineView.kType);
    if (_kChartTimeShare) {
        [_kChartTimeShare free];
        [_kChartTimeShare removeFromSuperview];
        _kChartTimeShare = nil;
    }
    // 创建分时图
    if (!_kChartTimeShare) {
        // 默认是竖屏的值
        CGFloat kx = 5;
        CGFloat kw = 0.7;
        CGFloat kp = 0.2;
        CGFloat kt = 240;
        CGFloat topY = _butonView.frame.origin.y+_butonView.frame.size.height+5;
        
        // 如果为大盘则重新设置线宽
        if (self.kLineView.kType==0 ) {
            kw = 1;
            kp = 0.29;
            // **********************************
            // 如果横屏
            // **********************************
            if (self.kLineView.isHorizontal) {
                topY = 5;
                kw = 1.311;
                kp = 1;
                // 兼容4S
                if (self.kLineView.screenFrame.size.height<=500) {
                    kw = 1;
                    kp = 0.945;
                }
            }
        }else{
            // 如果为个股
            // **********************************
            // 如果横屏
            // **********************************
            if (self.kLineView.isHorizontal) {
                kw = 1;
                kp = 0.93;
                topY = 5;
                //_klineBoxHeight -= 10;
                // 兼容4S
                if (self.kLineView.screenFrame.size.height<=500) {
                    kw = 1;
                    kp = 0.56;
                }
            }
        }
        // 个股或者大盘时的分时图宽度
        CGFloat kWidth = (kw+kp)*kt+2.5;
        // 如果是5天分时图
        if (_days==5) {
            kt = 240*5;
            kp = 0;
            kWidth = self.view.frame.size.width-10;
            // **********************************
            // 如果横屏
            // **********************************
            if (self.kLineView.isHorizontal) {
                kWidth = self.kLineView.screenFrame.size.height-10;
            }
            kw = kWidth/kt;
        }
        if ((self.kLineView.isFirst && isRequest) || self.kLineView.isClickTransformButton) {
            kx = -KScreenSize.width;
        }
        _ktimeParamModel = nil;
        _kChartTimeShare = [[kChartTimeShareView alloc] initWithFrame:CGRectMake(kx,topY, kWidth, _klineBoxHeight)];
        if (!_ktimeParamModel) {
            _ktimeParamModel = [[kChartTimeParamModel alloc] init];
            _ktimeParamModel.width = kWidth;
            _ktimeParamModel.height = _klineBoxHeight-90;
            _ktimeParamModel.padding = kp;
            _ktimeParamModel.kLineWidth = kw;
            _ktimeParamModel.count = kt;
            _ktimeParamModel.days = _days;
        }
        // **********************************
        // 如果横屏
        // **********************************
        if (self.kLineView.isHorizontal) {
            //_kChartTimeShare.backgroundColor = UIColorFromRGB(0xFFFFFF);
        }
        [self.view addSubview:_kChartTimeShare];
        // 开始运行画图
        [_kChartTimeShare startWith:_ktimeParamModel];
        // 手指按下回调
        __unsafe_unretained kChartViewController *ts = self;
        _kChartTimeShare.pressDownBlock = ^(timeShareChartModel *timeModel){
            NSArray *views = ts.kLineView.kTopView.subviews;
            // 当期最新值
            UILabel *v = (UILabel*)[views objectAtIndex:11];
            v.text = [DCommon stringChange:timeModel.transationPrice];
            v.textColor = kRedColor;
            if ([timeModel.changeValue floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 涨跌幅
            v = (UILabel*)[views objectAtIndex:12];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f%%",[timeModel.changeRate floatValue]];
            v.textColor = kRedColor;
            if ([timeModel.changeValue floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 涨跌额
            v = (UILabel*)[views objectAtIndex:13];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f",[timeModel.changeValue floatValue]];
            v.textColor = kRedColor;
            if ([timeModel.changeValue floatValue]<0) {
                v.textColor = kGreenColor;
            }
            v = nil;
            // 成交量
            v = (UILabel*)[views objectAtIndex:20];
            v.text = [DCommon numToUnits:[timeModel.volume floatValue]/100];
            v = nil;
            // 换手率
            v = (UILabel*)[views objectAtIndex:22];
            v.text = [[NSString alloc] initWithFormat:@"%0.2f%%",[timeModel.turnoverRate floatValue]];
            v = nil;
        };
        // 手指移开
        _kChartTimeShare.pressUpBlock = ^(timeShareChartModel *timeModel){
            [ts updateStockBetsView];
        };
        // 画图处理完成
        _kChartTimeShare.finishBlock = ^(kChartTimeShareView *kchartTimeView){
            
            // 更新盘口数据
            if (kchartTimeView.pankou.count>0) {
                NSMutableArray *temp = kchartTimeView.pankou;
                if (ts.kLineView)
                {
                    ts.kLineView.pDatas.hugeOrder = [temp objectAtIndex:0];
                    ts.kLineView.pDatas.bigOrder = [temp objectAtIndex:1];
                    ts.kLineView.pDatas.middleOrder = [temp objectAtIndex:2];
                    ts.kLineView.pDatas.smallOrder = [temp objectAtIndex:3];
                }
                temp = nil;
            }
            
            // 如果大盘，更新盘口内外盘
            if (ts.kLineView.kType==0) {
                if (kchartTimeView.dishs.count>0) {
                    ts.kLineView.pDatas.innerDish = [NSString stringWithFormat:@"%f",[[kchartTimeView.dishs firstObject] floatValue]];
                    ts.kLineView.pDatas.outerDish = [NSString stringWithFormat:@"%f",[[kchartTimeView.dishs lastObject] floatValue]];
                }
            }
        };
        // 点击分时图手势
        _kChartTimeShare.chartTapBlocks = ^(kChartTimeShareView *kchartTimeView){
            [ts clickTransformButtonAction:nil];
        };
        
        // 添加完分时图再添加五档视图
        [self addFiveButton:isRequest];
        
        if (isRequest) {
            // 添加加载控件
            [self addLoadingView];
            // 重新加载数据
            [self getkLineIndex:YES];
        }
        
    }
    // 隐藏放大镜还有复权ann
    if (_zoomInButton && _zoomOutButton) {
        _zoomOutButton.hidden = YES;
        _zoomInButton.hidden = YES;
    }
    // 复权按钮隐藏
    if (_restorationButton) {
        _restorationButton.hidden = YES;
    }
    // 非分时图隐藏
    if ((_fview && _days==5) || self.kLineView.kType==0) {
        _fview.hidden = YES;
    }else if (self.kLineView.kType>0) {
        _fview.hidden = NO;
        if (!self.kLineView.isFirst && isRequest) {
            // 弹出效果
            CGFloat x = _kChartTimeShare.width+5-0.5;
            CGRect frame = _fview.frame;
            // 修正下五档的显示坐标
            [UIView animateWithDuration:0.3 animations:^{
                // 按钮盒子
                _fview.frame = CGRectMake(x,frame.origin.y,frame.size.width,frame.size.height);
            } completion:^(BOOL finished){
                [self clickFiveButton:_currentFiveButton];
            }];
        }
        
    }
    // 先清掉其他视图
    if (_kChart) {
        [_kChart free];
        [_kChart removeFromSuperview];
        _kChart = nil;
    }

}
#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadingView) {
        CGFloat lw = 100;
        CGFloat lh = 80;
        CGFloat x = (self.view.frame.size.width-lw)/2;
        CGFloat y = _butonView.frame.origin.y+_butonView.frame.size.height+70;
        // **********************************
        // 如果横屏
        // **********************************
        if (self.kLineView.isHorizontal) {
            x = (self.view.frame.size.width-lw)/2 ;
            y = (self.view.frame.size.height-lh)/2-self.kLineView.titleView.frame.size.height;
        }
        _loadingView = [[loadingView alloc] initWithFrame:CGRectMake(x,y,lw,lh)];
        [self.view addSubview:_loadingView];
    }
}
#pragma mark 是否显示加载视图
-(void)hideLoadingView:(BOOL)yes{
    if (_loadingView) {
        _loadingView.hidden = yes;
        if (yes) {
            [_loadingView stop];
        }
        else{
            [_loadingView start];
        }
        [self.view bringSubviewToFront:_loadingView];
    }
    
}
#pragma mark 添加放大镜按钮
-(void)addZoomButtons{
    CGFloat x = self.view.frame.size.width-kDZoomInPng.size.width*2-30;
    CGFloat y = _klineBoxHeight-25;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.kLineView.isHorizontal) {
        x = _butonView.frame.size.width+120;
        y = _butonView.frame.origin.y+3;
        if (self.kLineView.screenFrame.size.height<500) {
            x -= 15;
        }
    }
    // 添加放大镜按钮
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"D_ZoomIn@2x" ofType:@"png"];
    UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
    
    _zoomInButton = [[UIButton alloc] initWithFrame:CGRectMake(x,y,imageSize.size.width,imageSize.size.height)];
    [_zoomInButton setImage:kDZoomInPng forState:UIControlStateNormal];
    [_zoomInButton setImage:kDZoomInHoverPng forState:UIControlStateHighlighted];
    [_zoomInButton addTarget:self action:@selector(clickZoomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _zoomInButton.hidden = YES;
    [self.view addSubview:_zoomInButton];
    // 添加缩小镜按钮
    x = self.view.frame.size.width-kDZoomOutPng.size.width-10;
    y = _klineBoxHeight-25;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.kLineView.isHorizontal) {
        x = _butonView.frame.size.width + 120 + kDZoomInPng.size.width + 25;
        y = _butonView.frame.origin.y+3;
        if (self.kLineView.screenFrame.size.height<500) {
            x -= 25;
        }
    }
    _zoomOutButton = [[UIButton alloc] initWithFrame:CGRectMake(x,y,imageSize.size.width,imageSize.size.height)];
    [_zoomOutButton setImage:kDZoomOutPng forState:UIControlStateNormal];
    [_zoomOutButton setImage:kDZoomOutHoverPng forState:UIControlStateHighlighted];
    [_zoomOutButton addTarget:self action:@selector(clickZoomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _zoomOutButton.hidden = YES;
    [self.view addSubview:_zoomOutButton];
}

#pragma mark 旋转按钮
-(void)addViewTransformButton{
    UIButton *bt = [[UIButton alloc] init];
    CGFloat w = 80;
    CGFloat h = 30;
    CGFloat x = (self.view.frame.size.width-w)/2;
    CGFloat y = _klineBoxHeight-28;
    // **********************************
    // 如果横屏
    // **********************************
    if (self.kLineView.isHorizontal) {
        y = _butonView.frame.origin.y;
        x = _butonView.frame.size.width+20;
        if (self.kLineView.screenFrame.size.height<500) {
            x -= 10;
        }
    }
    bt.frame = CGRectMake(x, y, w, h);
    [bt setTitle:@"切换横屏" forState:UIControlStateNormal];
    // **********************************
    // 如果横屏
    // **********************************
    if (self.kLineView.isHorizontal) {
        [bt setTitle:@"切换竖屏" forState:UIControlStateNormal];
    }
    [bt setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    [bt setTitleColor:kBrownColor forState:UIControlStateSelected];
    bt.backgroundColor = UIColorFromRGB(0xffffff);
    bt.titleLabel.font = [UIFont fontWithName:kFontName size:14];
    bt.layer.borderColor=UIColorFromRGB(0xe1e1e1).CGColor;
    bt.layer.borderWidth=0.5f;
    
//    bt.layer.borderWidth = 0.5;
//    bt.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
//    bt.layer.cornerRadius = 3;
    [bt addTarget:self action:@selector(clickTransformButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt];
    _transButton = bt;
    bt = nil;
}

#pragma mark 更新K线图
-(void)updateKLine{
    //_loadingView.hidden = YES;
    [self buttonEnabled:YES];
    // 更新k线视图
    switch (_currentButtonIndex) {
        case 0:
        case 1:{
            _ktimeParamModel.data = _data;
            _ktimeParamModel.heightPrice = _heightPrice;
            _ktimeParamModel.closePrice = _closePrice;
            _ktimeParamModel.days = _days;
            _ktimeParamModel.timeFrame = _timeFrame;
            [_kChartTimeShare updateWith:_ktimeParamModel];
        }
            break;
        case 2:
        case 3:
        case 4:{
            
            if (_klineWidth>10)
                _klineWidth = 10;
            if (_klineWidth<2)
                _klineWidth = 2;
            
            _count = (_klineBoxWidth-1) / (_klineWidth+_klinePadding)-1; // K线中实体的总数
            kchartParam.data = _data;
            kchartParam.padding = _klinePadding;
            kchartParam.kLineWidth = _klineWidth;
            kchartParam.count = _count;
            [_kChart updateWith:kchartParam];
            
        }
            break;
        default:
            break;
    }

    // 把一些按钮视图移动到视图最上层
    self.kLineView.currentButtonIndex = _currentButtonIndex;// 共享当前视图索引
    // 把放大镜移到最前面来
    if (_zoomOutButton && _zoomInButton) {
        [self.view bringSubviewToFront:_zoomInButton];
        [self.view bringSubviewToFront:_zoomOutButton];
    }
    if (_restorationButton) {
        [self.view bringSubviewToFront:_restorationButton];
    }
    [self.view bringSubviewToFront:_transButton];
}
#pragma mark 添加五档明细等视图
-(void)addFiveView:(int)index{
    if (_kChartTimeShare) {
        CGRect frame = CGRectMake(0, 35, _fview.frame.size.width, _fview.frame.size.height-35);
        // 添加五档
        if (!_fiveSpeedView) {
            _fiveSpeedView = [[FiveSpeedViewController alloc] initWithFrame:frame];
            _fiveSpeedView.kLineView = self.kLineView;
            [_fview addSubview:_fiveSpeedView.view];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFiveButton:)];
            _fiveSpeedView.view.userInteractionEnabled = YES;
            [_fiveSpeedView.view addGestureRecognizer:tapGesture];
            tapGesture = nil;
        }
        // 添加交易明细
        if (!_timeShareDetailView) {
            _timeShareDetailView = [[TimeShareDetailViewController alloc] initWithFrame:frame];
            _timeShareDetailView.kLineView = self.kLineView;
            [_fview addSubview:_timeShareDetailView.view];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFiveButton:)];
            _timeShareDetailView.view.userInteractionEnabled = YES;
            [_timeShareDetailView.view addGestureRecognizer:tapGesture];
            tapGesture = nil;
        }
        if (_fiveSpeedView && _timeShareDetailView) {
            // 根据按钮添加五档或者明细视图
            if (index==0) {
                _fiveSpeedView.view.frame = frame;
                [_fiveSpeedView.view setHidden:NO];
                [_fiveSpeedView show];
                [_timeShareDetailView.view setHidden:YES];
            }else{
                _timeShareDetailView.view.frame = frame;
                [_timeShareDetailView.view setHidden:NO];
                [_timeShareDetailView show];
                [_fiveSpeedView.view setHidden:YES];
            }
        }
    }
    
}

#pragma mark 更新盘口参数
-(void)updateStockBetsView{
    if (_betsData) {
        NSArray *views = self.kLineView.kTopView.subviews;
        // 昨日收盘价
        self.kLineView.yesterdayPrice = _betsData.yesterdayPrice;
        // 共享最新价
        self.kLineView.newsPrice = [DCommon stringChange:_betsData.newsValue];
        // 共享涨跌幅
        self.kLineView.changeRate = [[NSString alloc] initWithFormat:@"%0.2f%%",[_betsData.changeRate floatValue]];
        // 判断是否停牌
        if ([_betsData.newsValue floatValue]<=0 && [_betsData.volumePrice floatValue]<=0) {
            self.kLineView.isStopStock = YES;
        }
        // 当期最新值
        UILabel *v = (UILabel*)[views objectAtIndex:11];
        v.text = [DCommon stringChange:_betsData.newsValue];
        v.textColor = kRedColor;
        if ([_betsData.changeValue floatValue]<0) {
            v.textColor = kGreenColor;
        }
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 涨跌幅
        v = (UILabel*)[views objectAtIndex:12];
        v.text = [[NSString alloc] initWithFormat:@"%0.2f%%",[_betsData.changeRate floatValue]];
        v.textColor = kRedColor;
        if ([_betsData.changeValue floatValue]<0) {
            v.textColor = kGreenColor;
        }
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 涨跌额
        v = (UILabel*)[views objectAtIndex:13];
        v.text = [[NSString alloc] initWithFormat:@"%0.2f",[_betsData.changeValue floatValue]];
        v.textColor = kRedColor;
        if ([_betsData.changeValue floatValue]<0) {
            v.textColor = kGreenColor;
        }
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 最高
        v = (UILabel*)[views objectAtIndex:18];
        v.text = [DCommon stringChange:_betsData.heightPrice];
        v.textColor = kRedColor;
        if ([_betsData.heightPrice floatValue]<[_betsData.yesterdayPrice floatValue]) {
            v.textColor = kGreenColor;
        }
        if ([_betsData.heightPrice floatValue]==[_betsData.yesterdayPrice floatValue]) {
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 开盘价
        v = (UILabel*)[views objectAtIndex:19];
        v.text = [DCommon stringChange:_betsData.openPrice];
        v.textColor = kRedColor;
        if ([_betsData.openPrice floatValue]<[_betsData.yesterdayPrice floatValue]) {
            v.textColor = kGreenColor;
        }
        if ([_betsData.openPrice floatValue]==[_betsData.yesterdayPrice floatValue]) {
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 成交量
        v = (UILabel*)[views objectAtIndex:20];
        v.text = [DCommon numToUnits:[_betsData.volume floatValue]/100];
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 最低
        v = (UILabel*)[views objectAtIndex:21];
        v.text = [DCommon stringChange:_betsData.lowPrice];
        v.textColor = kRedColor;
        if ([_betsData.lowPrice floatValue]<[_betsData.yesterdayPrice floatValue]) {
            v.textColor = kGreenColor;
        }
        if ([_betsData.lowPrice floatValue]==[_betsData.yesterdayPrice floatValue]) {
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 换手率
        v = (UILabel*)[views objectAtIndex:22];
        v.text = [[NSString alloc] initWithFormat:@"%@%%",[DCommon stringChange:_betsData.turnoverRate]];
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 成交额
        v = (UILabel*)[views objectAtIndex:23];
        v.text = [DCommon numToUnits:[_betsData.volumePrice floatValue]];
        if (self.kLineView.isStopStock) {
            v.text = @"--";
            v.textColor = UIColorFromRGB(0xFFFFFF);
        }
        v = nil;
        // 总值
        v = (UILabel*)[views objectAtIndex:14];
        v.text = [DCommon numToUnits:[_betsData.totalPrice floatValue]*10000];
        v = nil;
        // 流值
        v = (UILabel*)[views objectAtIndex:15];
        v.text = [DCommon numToUnits:[_betsData.flowPrice floatValue]*10000];
        v = nil;
        // 市盈率 静态市盈
        v = (UILabel*)[views objectAtIndex:16];
        v.text = [DCommon stringChange:_betsData.peRatioB];
        v = nil;
        // 市净率
        v = (UILabel*)[views objectAtIndex:17];
        v.text = [DCommon stringChange:_betsData.pbRatio];
        v = nil;
        // 更新标题
        // NSLog(@"---DFM---标题是：%@",self.kLineView.kNameLabel);
        if (![self.kLineView.kNameLabel.text isEqualToString:@""]) {
            NSString *tempName = _betsData.stockName;
            //tempName = [tempName stringByReplacingOccurrencesOfString:@"指数" withString:@""];
            if (self.kLineView) {
                self.kLineView.kName = tempName;
                [self.kLineView setKTitle:tempName];
            }
            tempName = nil;
        }
    }
}


#pragma mark -------------------------视图事件响应-----------------------------
#pragma mark 五档明细按钮点击事件
-(void)clickFiveButton:(UIButton*)button{
    if (!_fview) {
        [self addFiveButton:YES];
    }

    if ([[button class] isSubclassOfClass:[UIButton class]]) {
        _currentFiveButton = button;
    }
    
    if ([[button class] isSubclassOfClass:[UITapGestureRecognizer class]]) {
        if (_currentFiveButton.tag==0) {
            button = (UIButton*)[_fview.subviews objectAtIndex:1];
        }else{
            button = (UIButton*)[_fview.subviews objectAtIndex:0];
        }
        
        _currentFiveButton = button;
    }
    for (int i=0; i<2; i++) {
        UIButton *buttontemp = (UIButton*)[_fview.subviews objectAtIndex:i];
        [buttontemp setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
        [buttontemp setTitleColor:kBrownColor forState:UIControlStateSelected];
        buttontemp = nil;
    }
    [button setTitleColor:kBrownColor forState:UIControlStateNormal];
    // 移动底线
    UIView *fiveLine = (UIView*)[_fview.subviews objectAtIndex:2];
    [UIView animateWithDuration:0.2 animations:^{
        fiveLine.frame = CGRectMake(button.frame.origin.x, fiveLine.frame.origin.y, fiveLine.frame.size.width, fiveLine.frame.size.height) ;
    }];
    // 显示五档或者明细视图
    [self addFiveView:button.tag];
}
#pragma mark 点击复权按钮
-(void)clickRestorationButton{
    _restorationButton.enabled = NO;
    if ([_restorationButton.titleLabel.text isEqualToString:@"不复权"]) {
        [_restorationButton setTitle:@"复权" forState:UIControlStateNormal];
        _isRestoration = NO;
    }else{
        [_restorationButton setTitle:@"不复权" forState:UIControlStateNormal];
        _isRestoration = YES;
    }
    // 切换
    if (_currentButtonIndex>1) {
        [self changeViewWithTag:_currentButtonIndex];
    }
    _restorationButton.enabled = YES;
}

#pragma mark 点击k线类型切换按钮
-(void)clickButtonAction:(UIButton*)button{
    NSInteger tag = button.tag;
    if (!button) {
        tag = 0;
        button = (UIButton*)[_butonView.subviews objectAtIndex:0];
    }
    // 保存当前点击按钮下标
    _currentButtonIndex = tag;
    for (int i=0;i<_btTitles.count; i++) {
        UIButton *temp = (UIButton*)[_butonView.subviews objectAtIndex:i];
        temp.backgroundColor = UIColorFromRGB(0xe1e1e1);
        [temp setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
        temp.enabled = NO;
        temp = nil;
    }
    [button setTitleColor:kButtonTitleCurrentColor forState:UIControlStateNormal];
    // 移动线
    UIView *line = [_butonView.subviews lastObject];
    [UIView animateWithDuration:0.3 animations:^{
        line.frame = CGRectMake(button.frame.origin.x, line.frame.origin.y, line.frame.size.width, line.frame.size.height);
    }];
    if (tag==0) {
        _kLineType = @"0";
    }
    if (tag==1) {
        _kLineType = @"1";
    }
    if (tag==2) {
        _kLineType = @"d";
    }
    if (tag==3) {
        _kLineType = @"w";
        _isRestoration = 0;
    }
    if (tag==4) {
        _kLineType = @"m";
        _isRestoration = 0;
    }
    // 切换视图
    [self changeViewWithTag:tag];
    // NSLog(@"---DFM---当前tag:%d",_currentButtonIndex);
    // 以下是分钟按钮的逻辑 现在暂时隐藏
//    if (tag==5) {
//        [self changeArrows:kDUpArrowsPng];
//        [self dropDowmMenuWithSuperView:button];
//    }else{
//        UIButton *lastButton = (UIButton*)[_butonView.subviews lastObject];
//        [lastButton setTitle:[_btTitles lastObject] forState:UIControlStateNormal];
//        lastButton = nil;
//        if (_minuteView) {
//            _minuteView.dropState = DrowDownState;
//            _minuteView.clickIndex = -1;
//            [_minuteView setNeedsDisplay];
//            [_minuteView dropDown];
//        }
//        [self changeArrows:kDDownArrowsPng];
//    }
}
#pragma mark 开启或关闭按钮
-(void)buttonEnabled:(BOOL)enabled{
    for (int i=0;i<_btTitles.count; i++) {
        UIButton *temp = (UIButton*)[_butonView.subviews objectAtIndex:i];
        temp.enabled = enabled;
        temp = nil;
    }
}
#pragma mark 切换视图
-(void)changeViewWithTag:(NSInteger)tag{
    _days = 1;
    switch (tag) {
        case 0:{
            
            [self addkChartTimeShareView:YES];
        }
            break;
        case 1:
            _days = 5;
            [self addkChartTimeShareView:YES];
            break;
        case 2:
            [self addkChartView];
            break;
        case 3:
            [self addkChartView];
            break;
        case 4:{
            [self addkChartView];
        }
            break;
        default:
            break;
    }
    
    
}
/*
 分钟暂时隐藏
#pragma mark 改变分钟按钮箭头的方向
-(void)changeArrows:(UIImage*)image{
    // 隐藏分钟选项
//    UIButton *b = (UIButton*)[_butonView.subviews lastObject];
//    UIImageView *i = (UIImageView*)[b.subviews objectAtIndex:1];
//    i.image = image;
//    i = nil;
//    b = nil;
}
#pragma mark 弹出菜单
-(void)dropDowmMenuWithSuperView:(UIView*)superView{
    CGFloat viewWidth = 100;
    NSArray *minute = [[NSArray alloc] initWithObjects:@"120分钟",@"60分钟",@"30分钟",@"15分钟",@"5分钟", nil];
    if (!_minuteView) {
        _minuteView = [[dropDownMenu alloc] initWithFrame:CGRectMake(self.view.frame.size.width-viewWidth-5,
                                                                     superView.frame.size.height + superView.frame.origin.y + 5,
                                                                     viewWidth,
                                                                     0)];
        _minuteView.font = [UIFont systemFontOfSize:14];
        _minuteView.color = UIColorFromRGB(0x333333);
        _minuteView.changeColor = kBrownColor;
        _minuteView.defaultBackgroundColor = UIColorFromRGB(0xCCCCCC);
        _minuteView.changeBackgroundColor = UIColorFromRGB(0xDDDDDD);
        _minuteView.oldBackgroundColor = [UIColor whiteColor];
        _minuteView.titles = minute;
        __unsafe_unretained kChartViewController *kc = self;
        // 点击菜单
        _minuteView.dropMenuBlock = ^(dropDownMenu *dropMenu){
            NSLog(@"---DFM---点击菜单：%d",dropMenu.clickIndex);
            NSString *miTitle = [minute objectAtIndex:dropMenu.clickIndex];
            UIButton *currentButton = (UIButton*)superView;
            // 保存当前点击按钮下标
            kc->_currentButtonIndex = currentButton.tag;
            miTitle = [miTitle substringToIndex:miTitle.length-1];
            [currentButton setTitle:miTitle forState:UIControlStateNormal];
            if (dropMenu.clickIndex==0) {
                currentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 10);
            }else{
                currentButton.titleEdgeInsets = UIEdgeInsetsZero;
            }
            currentButton = nil;
        };
        // 伸展菜单弹出收起事件回调block
        _minuteView.dropDownBlocks = ^(dropDownMenu *dropMenu){
            // 如果已经收起
            if (dropMenu.dropState==DrowDownState) {
                NSLog(@"---DFM---收起");
                [kc changeArrows:kDDownArrowsWhitePng];
            }
        };
        [self.view addSubview:_minuteView];
    }
    [_minuteView setNeedsDisplay];
    [_minuteView dropDown];
}
#pragma mark 跳回前面点击的按钮高亮
-(void)backPreClickButton{
    // 当下拉菜单弹出，用户触摸屏幕时执行菜单收起，并且恢复上一点击的按钮高亮状态
    // 把下拉菜单给隐藏掉
    if (_butonView && _currentButtonIndex!=_btTitles.count-1) {
        UIButton *lastButton = (UIButton*)[_butonView.subviews lastObject];
        [lastButton setTitle:[_btTitles lastObject] forState:UIControlStateNormal];
        lastButton = nil;
        if (_minuteView) {
            _minuteView.dropState = DrowDownState;
            _minuteView.clickIndex = -1;
            [_minuteView setNeedsDisplay];
            [_minuteView dropDown];
        }
        for (int i=0;i<_btTitles.count; i++) {
            UIButton *temp = (UIButton*)[_butonView.subviews objectAtIndex:i];
            temp.backgroundColor = kBackgroundcolor;
            [temp setTitleColor:kButtonTitleColor forState:UIControlStateNormal];
            temp = nil;
        }
        // 恢复前面点亮的按钮
        UIButton *preButton = (UIButton*)[_butonView.subviews objectAtIndex:_currentButtonIndex];
        preButton.backgroundColor = UIColorFromRGB(0xee5909);
        [preButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        preButton = nil;
        // 得恢复最后一个按钮的三角图片
        [self changeArrows:kDDownArrowsPng];
    }
}
*/

#pragma mark 放大缩小事件
-(void)clickZoomButtonAction:(UIButton*)button{
    // 按钮无效
    button.enabled = NO;
    if (button==_zoomInButton) {
        // 按钮变灰
        [button setImage:kDZoomInHoverPng forState:UIControlStateNormal];
        // 放大
        _klineWidth ++;
        [self updateKLine];
        
    }else{
        // 按钮变灰
        [button setImage:kDZoomOutHoverPng forState:UIControlStateNormal];
        // 缩小
        _klineWidth --;
        [self updateKLine];
    }
    
}

#pragma mark 切换按钮响应事件
-(void)clickTransformButtonAction:(UIButton*)button{
    self.kLineView.isClickTransformButton = YES;
    // NSLog(@"---DFM---切换横屏");
    // 动画过度效果
    NSTimeInterval time = 0.2;
    CGRect fiveframe = _fview.frame; // 五档
    CGRect timeframe = _kChartTimeShare.frame; // 分时图
    CGRect topFrame = self.kLineView.topView.frame; // 顶部导航
    CGRect footerFrame = self.kLineView.preAndNextView.frame; // 上一只 下一只
    CGRect paramFrame = self.kLineView.kTopView.frame; // 参数
    CGRect titleFrame = self.kLineView.titleView.frame; // 横屏标题
    CGRect tabFrame = _butonView.frame; // 切换按钮
    CGRect transFrame = _transButton.frame;// 横屏按钮
    CGRect mainFrame = self.kLineView.mainScrollView.frame;// 主滚动视图
    CGRect mFrame = self.kLineView.mainView.frame;// 主滚动视图
    CGRect bottomFrame = self.kLineView.bottomController.view.frame;// 底部视图
    CGRect zoomInFrame = _zoomInButton.frame; // 放小镜
    CGRect zoomOutFrame = _zoomOutButton.frame; // 放大镜
    self.kLineView.currentButtonIndex = _currentButtonIndex;
    // 隐藏复权按钮
    _restorationButton.hidden = YES;
    // 如果已经横屏
    if (self.kLineView.isHorizontal) {
        [UIView animateWithDuration:time animations:^{
            // 当前视图分离并隐藏
            // 左右分离
            _fview.frame = CGRectMake(self.view.frame.size.width,fiveframe.origin.y,fiveframe.size.width, fiveframe.size.height);
            _kChartTimeShare.frame = CGRectMake(-self.view.frame.size.width, timeframe.origin.y, timeframe.size.width, timeframe.size.height);
            _kChart.frame = CGRectMake(-self.view.frame.size.width, _kChart.frame.origin.y, _kChart.frame.size.width, _kChart.frame.size.height);
            // 上下分离
            self.kLineView.titleView.frame = CGRectMake(titleFrame.origin.x, -(titleFrame.origin.y+titleFrame.size.height), titleFrame.size.width, titleFrame.size.height);
            self.kLineView.kTopView.frame = CGRectMake(paramFrame.origin.x, -(paramFrame.origin.y+paramFrame.size.height), paramFrame.size.width, paramFrame.size.height);
            self.kLineView.preAndNextView.frame = CGRectMake(footerFrame.origin.x, (footerFrame.origin.y+footerFrame.size.height), footerFrame.size.width, footerFrame.size.height);
            _butonView.frame = CGRectMake(tabFrame.origin.x, (tabFrame.origin.y+tabFrame.size.height+20), tabFrame.size.width, tabFrame.size.height);
            _transButton.frame = CGRectMake(transFrame.origin.x, (transFrame.origin.y+transFrame.size.height+20), transFrame.size.width, transFrame.size.height);
            _zoomInButton.frame = CGRectMake(zoomInFrame.origin.x, (zoomInFrame.origin.y+zoomInFrame.size.height+20), zoomInFrame.size.width, zoomInFrame.size.height);
            _zoomOutButton.frame = CGRectMake(zoomOutFrame.origin.x, (zoomOutFrame.origin.y+zoomOutFrame.size.height+20), zoomOutFrame.size.width, zoomOutFrame.size.height);
            // 显示
            // NSLog(@"---DFM---转动中...%f",_kChart.frame.origin.y);
            self.kLineView.mainView.alpha = 0.3;
        } completion:^(BOOL finish){
            
            self.kLineView.isHorizontal = NO;// 不是横屏
            [self.kLineView show];
        }];
    }else{
        self.kLineView.mainScrollView.frame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height+mainFrame.origin.y);
        self.kLineView.mainView.frame = CGRectMake(mFrame.origin.x , mFrame.origin.y, mFrame.size.width, mFrame.size.height+mainFrame.origin.y);
        [UIView animateWithDuration:time animations:^{
            // 当前视图分离并隐藏
            // 左右分离
            _fview.frame = CGRectMake(self.view.frame.size.width,fiveframe.origin.y+mainFrame.origin.y,fiveframe.size.width, fiveframe.size.height);
            _kChartTimeShare.frame = CGRectMake(-self.view.frame.size.width, timeframe.origin.y+mainFrame.origin.y, timeframe.size.width, timeframe.size.height);
            _kChart.frame = CGRectMake(-self.view.frame.size.width, _kChart.frame.origin.y+mainFrame.origin.y, _kChart.frame.size.width, _kChart.frame.size.height);
            // 上下分离
            self.kLineView.topView.frame = CGRectMake(topFrame.origin.x, -(topFrame.origin.y+topFrame.size.height), topFrame.size.width, topFrame.size.height);
            self.kLineView.mainScrollView.frame = CGRectMake(mainFrame.origin.x, 0, mainFrame.size.width, mainFrame.size.height);
            self.kLineView.kTopView.frame = CGRectMake(paramFrame.origin.x, -(topFrame.size.height+topFrame.origin.y+paramFrame.size.height+paramFrame.origin.y), paramFrame.size.width, paramFrame.size.height);
            self.kLineView.preAndNextView.frame = CGRectMake(footerFrame.origin.x, (footerFrame.origin.y+footerFrame.size.height), footerFrame.size.width, footerFrame.size.height);
            self.kLineView.bottomController.view.frame = CGRectMake(bottomFrame.origin.x, (bottomFrame.origin.y+bottomFrame.size.height+100), bottomFrame.size.width, bottomFrame.size.height);
            _transButton.frame = CGRectMake(transFrame.origin.x, (bottomFrame.origin.y+bottomFrame.size.height+100), transFrame.size.width, transFrame.size.height);
            _butonView.frame = CGRectMake(tabFrame.origin.x, -(topFrame.size.height+topFrame.origin.y+paramFrame.size.height+paramFrame.origin.y+tabFrame.origin.y+tabFrame.size.height), tabFrame.size.width, tabFrame.size.height);
            _zoomInButton.frame = CGRectMake(zoomInFrame.origin.x, (bottomFrame.origin.y+bottomFrame.size.height+100), zoomInFrame.size.width, zoomInFrame.size.height);
            _zoomOutButton.frame = CGRectMake(zoomOutFrame.origin.x, (bottomFrame.origin.y+bottomFrame.size.height+100), zoomOutFrame.size.width, zoomOutFrame.size.height);
            self.kLineView.mainView.alpha = 0.3;
        } completion:^(BOOL finish){
            self.kLineView.isHorizontal = YES;// 是横屏
            // 显示
            [self.kLineView show];
        }];

    }
}

#pragma mark 动画显示主要视图
-(void)intoShow{

    // 默认点击第一个视图
    [self clickButtonAction:(UIButton*)[_butonView.subviews objectAtIndex:self.kLineView.currentButtonIndex]];
    CGFloat width = self.view.frame.size.width;
    if (self.kLineView.isClickTransformButton || self.kLineView.isHorizontal) {
        // 左右收起
        _kChart.frame = CGRectMake(-width, _kChart.frame.origin.y, _kChart.frame.size.width, _kChart.frame.size.height);
        _kChartTimeShare.frame = CGRectMake(-width, _kChartTimeShare.frame.origin.y, _kChartTimeShare.frame.size.width, _kChartTimeShare.frame.size.height);
        _fview.frame = CGRectMake(width,_fview.frame.origin.y,_fview.frame.size.width,_fview.frame.size.height);
        // 动画弹出
        [UIView animateWithDuration:0.5 animations:^{
            if (self.kLineView.currentButtonIndex>=2) {
                // 日k，周k，月k 弹出效果
                _kChart.frame = CGRectMake(5, _kChart.frame.origin.y, _kChart.frame.size.width, _kChart.frame.size.height);
            }else{
                // 分时图，5日分时图弹出效果
                _kChartTimeShare.frame = CGRectMake(5, _kChartTimeShare.frame.origin.y, _kChartTimeShare.frame.size.width, _kChartTimeShare.frame.size.height);
                CGFloat x = _kChartTimeShare.width+5-0.5;
                // 按钮盒子
                _fview.frame = CGRectMake(x,_fview.frame.origin.y,_fview.frame.size.width,_fview.frame.size.height);
                
            }
            
        } completion:^(BOOL isfinish){
            self.kLineView.isClickTransformButton = NO;
        }];
    }
    
}

#pragma mark --------------------------Http接口处理------------------------------
#pragma mark 请求数据
-(void)getkLineIndex:(BOOL)isAsyn{
    // 对type进行一下处理
    if (self.kLineView.kType>1)
        self.kLineView.kType = 1;
    
    // 切换视图就开启加载视图
    [self hideLoadingView:NO];
    // 清除
    [self clearTimer];
    // 如果还没盘口数据或者正在刷新都加载盘口接口
    if (!self.kLineView.pDatas || !_isStop) {
        // 加载盘口数据
        [_requestBets requestStocksBets:self Type:self.kLineView.kType andkId:self.kLineView.kId isAsyn:isAsyn];
    }
    // 分别加载分时图K线图等
    switch (_currentButtonIndex) {
        case 0:
        case 1:{
            [_request requestTimeShareChart:self Type:self.kLineView.kType andkId:self.kLineView.kId andDays:_days isAsyn:isAsyn];
        }
            break;
        case 2:
        case 3:
        case 4:{
            // 如果已经看了当前视图，并且不是第一次加载，并且是横屏则不用加载网络数据
//            if (_data.count>0 && self.kLineView.isFirst && self.kLineView.isHorizontal) {
//                // 直接返回缓存数据
//                [self getkLineIndexBundle:_data];
//                return;
//            }
            // 每次请求都请求最大的k线数量
            NSMutableArray *cacheDatas = [DCommon setKLineToLocalWithDatas:_data andKID:self.kLineView.kId andType:self.kLineView.kType andTimes:_kLineType andIsRestoration:_isRestoration andIsGet:YES];
            // 如果有缓存就调用缓存数据，没有就查网络的数据
            if (cacheDatas) {
                // 提取缓存
                [self getkLineIndexCacheBundle:cacheDatas];
            }else{
                [_request requestKLineIndex:self kLineType:_kLineType andCount:_allCount andIsRestoration:_isRestoration andkId:self.kLineView.kId type:[[NSString alloc] initWithFormat:@"%d",self.kLineView.kType] isAsyn:isAsyn];
            }
        }
            break;
        default:
            break;
    }
    
}
#pragma mark k线图数据返回处理
-(void)getkLineIndexBundle:(NSMutableArray*)data{
    [self hideLoadingView:YES];
    _data = data;
    // 归档缓存
    if (_data.count>0) {
        [DCommon setKLineToLocalWithDatas:_data andKID:self.kLineView.kId andType:self.kLineView.kType andTimes:_kLineType andIsRestoration:_isRestoration andIsGet:NO];
    }
    [self updateKLine];
    // 完成加载反馈给主视图
    [self.kLineView whenLoadOverAction];
}

#pragma mark k线图缓存数据返回处理
-(void)getkLineIndexCacheBundle:(NSMutableArray*)data{
    [self hideLoadingView:YES];
    _data = data;
    [self updateKLine];
    // 完成加载反馈给主视图
    [self.kLineView whenLoadOverAction];
}

#pragma mark 分时图数据返回处理
-(void)getTimeShareChartBundle:(NSMutableArray*)data heightPrice:(CGFloat)heightPrice closePrice:(CGFloat)closePrice isStop:(BOOL)stop seconds:(double)seconds timeFrame:(NSString*)timeFrame{

    [self hideLoadingView:YES];
    _seconds = seconds;
    _heightPrice = heightPrice;
    _closePrice = closePrice;
    _isStop = stop;
    _data = data;
    _timeFrame = timeFrame;
    [self updateKLine];
    self.kLineView.isStop = stop;
    // 如果开盘则开始刷新
    if (!stop && _currentButtonIndex<=1 && !_stopRefresh) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kDRefreshTime target:self selector:@selector(getkLineIndex:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        // NSLog(@"---DFM---分时图刷新数据：%f",seconds);
    }else{
        [self clearTimer];
    }
    // 完成加载反馈给主视图
    [self.kLineView whenLoadOverAction];
}
#pragma mark 盘口数据返回处理
-(void)getkStockBetsBundle:(stockBetsModel*)data{
    if (data) {
        NSMutableArray *dataArray = [NSMutableArray arrayWithObject:data.dic];
        [DCommon setPanKouToLocalWithDatas:dataArray andkId:self.kLineView.kId andkType:self.kLineView.kType andIsGet:NO];
        dataArray = nil;
    }
    
    //[self hideLoadingView:YES];
    _betsData = data;
    
    if (_betsData) {
        // 拿到数据给盘口视图
        self.kLineView.pDatas = _betsData;
        // 拿到数据后更新头部参数数据
        [self updateStockBetsView];
    }
    // 默认点击五档按钮
    [self clickFiveButton:_currentFiveButton];
    // 完成加载反馈给主视图
    [self.kLineView whenLoadOverAction];
}
#pragma mark 清除timer
-(void)clearTimer{
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}



@end
