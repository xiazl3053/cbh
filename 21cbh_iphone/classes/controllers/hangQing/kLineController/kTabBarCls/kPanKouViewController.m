//
//  kPanKouViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kPanKouViewController.h"
#import "baseTableView.h"
#import "basehqCell.h"
#import "hangqingHttpRequest.h"
#import "volDetailListModel.h"
#import "stockBetsModel.h"
#import "fiveAndDetailModel.h"
#import "DCommon.h"

#define ktitleViewHeight 40
#define ktitleFont [UIFont fontWithName:kFontName size:15];
#define kPanKouTitleBackground UIColorFromRGB(0x000000)
#define kD_kDownPng [UIImage imageNamed:@"D_kDown.png"]
#define kD_kUpPng [UIImage imageNamed:@"D_kUp.png"]

@interface kPanKouViewController (){
    NSMutableArray *_firstTitles; // 第一栏下的标签集合
    NSMutableArray *_firstValues; // 第一栏下的标签值集合
    NSMutableArray *_firstColors; // 第一栏下的标签颜色集合
    UITableView *_tableView; // 成交量明细表格
    NSMutableArray *_data; // 详细描述数据
    NSMutableArray *_volData; // 成交量明细数据
    NSTimer *_timer;// 定时刷新
    hangqingHttpRequest *_request;
    hangqingHttpRequest *_requestBets;
    //fiveAndDetailModel *_volModel; // 成交量明细模型
    BOOL _isStopStocks;// 是否停牌
    CGFloat _preValue;// 上一个值
    BOOL isStopRefresh;
}

@end

@implementation kPanKouViewController

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
    isStopRefresh = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    isStopRefresh = NO;
    [self clearTimer];
    [self.view removeAllSubviews];
    // 初始化参数
    [self initParam];
    // 初始化界面
    [self initViews];
    // 请求盘口成交明细数据
    [self getFiveAndDetail:YES];
    // 更新视图
    [self updateView];
}

-(void)viewWillDisappear:(BOOL)animated{
    isStopRefresh = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self free];
}

#pragma mark ---------------------------自定义方法--------------------------
-(void)free{
    // 清除请求
    [_request clearRequest];
    _request = nil;
    // 清除请求
    [_requestBets clearRequest];
    _requestBets = nil;
    _data = nil;
    _volData = nil;
    _tableView = nil;
    _firstColors = nil;
    _firstValues = nil;
    _firstTitles = nil;
    [self.view removeAllSubviews];
}
-(void)clear{}
-(void)show{}
#pragma mark 初始化参数
-(void)initParam{
    _isStopStocks = NO;
    _firstTitles = [[NSMutableArray alloc] initWithObjects:
                    @"最新:",
                    @"涨跌:",
                    @"最高:",
                    @"成交量:",
                    @"涨停:",
                    @"外盘:",
                    @"量比:",
                    @"市盈(动):",
                    @"净资产:",
                    @"总股本:",
                    @"流通股本:",
                    
                    @"涨幅:",
                    @"换手:",
                    @"最低:",
                    @"成交额:",
                    @"跌停:",
                    @"内盘:",
                    @"收盘(三):",
                    @"市盈(静):",
                    @"市净率:",
                    @"总市值:",
                    @"流通市值:",
                    
                    nil];
    // 如果是盘口则是另外的标题
    if (self.kLineView.kType==0) {
        _firstTitles = [[NSMutableArray alloc] initWithObjects:
                        @"最新:",
                        @"今开:",
                        @"最高:",
                        @"量比:",
                        @"成交量:",
                        @"外盘:",
                        @"上涨",
                        @"下跌",
                        
                        @"涨幅:",
                        @"昨收:",
                        @"最低:",
                        @"换手:",
                        @"成交额:",
                        @"内盘:",
                        @"平盘",
                        nil];
    }
 
    if (self.kLineView.pDatas) {
        // 主力流入流出换算
        NSString *mainIn = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.mainIn floatValue]/10000];
        NSString *mainOut = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.mainOut floatValue]/10000];
        NSString *mainNetIn = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.mainNetIn floatValue]/10000];
        // 大单小单换算
        NSString *hugeOrder = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.hugeOrder floatValue]/10000];
        NSString *bigOrder = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.bigOrder floatValue]/10000];
        NSString *middleOrder = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.middleOrder floatValue]/10000];
        NSString *smallOrder = [[NSString alloc] initWithFormat:@"%.0f",[self.kLineView.pDatas.smallOrder floatValue]/10000];
        // 总股本换算
        NSString *totalStock = [DCommon numToUnits:[self.kLineView.pDatas.totalStock floatValue]*10000];
        NSString *flowOfEquity = [DCommon numToUnits:[self.kLineView.pDatas.flowOfEquity floatValue]*10000];
        if ([self.kLineView.pDatas.newsValue floatValue]<=0 && [self.kLineView.pDatas.volumePrice floatValue]<=0) {
            _isStopStocks = YES;
        }
        
        // 停盘的股票
        if (_isStopStocks) {
            _firstValues = [[NSMutableArray alloc]initWithObjects:
                            @"0",
                            @"0",
                            @"0",
                            @"0", // 成交量
                            self.kLineView.pDatas.upStop, // 涨停
                            @"0", // 外盘
                            self.kLineView.pDatas.quantityRatio, // 量比
                            self.kLineView.pDatas.peRatioA, // 市盈（动）
                            self.kLineView.pDatas.netAsset, // 净资产
                            totalStock, // 总股本
                            flowOfEquity, // 流通股本
                            @"0", // 涨跌幅
                            self.kLineView.pDatas.turnoverRate, // 换手率
                            @"0",// 最低价
                            @"0", // 成交额
                            self.kLineView.pDatas.downStop, // 跌停
                            @"0", // 内盘
                            @"0", // 收盘（三）
                            self.kLineView.pDatas.peRatioB, // 市盈（静）
                            self.kLineView.pDatas.pbRatio, // 市净率
                            [DCommon numToUnits:[self.kLineView.pDatas.totalPrice floatValue]*10000], // 总市值
                            [DCommon numToUnits:[self.kLineView.pDatas.flowPrice floatValue]*10000], // 流通市值
                            mainIn, // 主力流入
                            mainOut, // 主力流出
                            mainNetIn, // 主力净流出
                            hugeOrder,
                            bigOrder,
                            middleOrder,
                            smallOrder,
                            nil];
        }else{
            _firstValues = [[NSMutableArray alloc]initWithObjects:
                            self.kLineView.pDatas.newsValue,
                            self.kLineView.pDatas.changeValue,
                            self.kLineView.pDatas.heightPrice,
                            [DCommon numToUnits:[self.kLineView.pDatas.volume floatValue]/100], // 成交量
                            self.kLineView.pDatas.upStop, // 涨停
                            [DCommon numToUnits:[self.kLineView.pDatas.outerDish floatValue]/100], // 外盘
                            self.kLineView.pDatas.quantityRatio, // 量比
                            self.kLineView.pDatas.peRatioA, // 市盈（动）
                            self.kLineView.pDatas.netAsset, // 净资产
                            totalStock, // 总股本
                            flowOfEquity, // 流通股本
                            self.kLineView.pDatas.changeRate, // 涨跌幅
                            self.kLineView.pDatas.turnoverRate, // 换手率
                            self.kLineView.pDatas.lowPrice,// 最低价
                            [DCommon numToUnits:[self.kLineView.pDatas.volumePrice floatValue]], // 成交额
                            self.kLineView.pDatas.downStop, // 跌停
                            [DCommon numToUnits:[self.kLineView.pDatas.innerDish floatValue]/100], // 内盘
                            self.kLineView.pDatas.earningsThree, // 收盘（三）
                            self.kLineView.pDatas.peRatioB, // 市盈（静）
                            self.kLineView.pDatas.pbRatio, // 市净率
                            [DCommon numToUnits:[self.kLineView.pDatas.totalPrice floatValue]*10000], // 总市值
                            [DCommon numToUnits:[self.kLineView.pDatas.flowPrice floatValue]*10000], // 流通市值
                            mainIn, // 主力流入
                            mainOut, // 主力流出
                            mainNetIn, // 主力净流出
                            hugeOrder,
                            bigOrder,
                            middleOrder,
                            smallOrder,
                            nil];
        }
        
        NSLog(@"---DFM---盘口：%@",self.kLineView.pDatas);
        // 如果是大盘则是另外的字段
        if (self.kLineView.kType==0) {
            _firstValues = [[NSMutableArray alloc]initWithObjects:
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.newsValue floatValue]], // 最新价
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.openPrice floatValue]], // 今开
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.heightPrice floatValue]], // 最高
                            self.kLineView.pDatas.quantityRatio, // 量比
                            [DCommon numToUnits:[self.kLineView.pDatas.volume floatValue]], // 成交量
                            [DCommon numToUnits:[self.kLineView.pDatas.outerDish floatValue]], // 外盘
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.changeUpValue floatValue]], // 上涨
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.changeDownValue floatValue]], // 下跌
                            
                            self.kLineView.pDatas.changeRate, // 涨幅
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.yesterdayPrice floatValue]], // 昨收
                            [NSString stringWithFormat:@"%0.2f",[self.kLineView.pDatas.lowPrice floatValue]], // 最低
                            self.kLineView.pDatas.turnoverRate, // 换手率
                            [DCommon numToUnits:[self.kLineView.pDatas.volumePrice floatValue]],// 成交额
                            [DCommon numToUnits:[self.kLineView.pDatas.innerDish floatValue]], // 内盘
                            self.kLineView.pDatas.pbRatio, // 平盘
                            nil];
        }
        
    }else{
        _firstValues = [[NSMutableArray alloc] initWithObjects:
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                        @"--",
                                            nil];
    }
    _firstColors = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithInt:0],
                    [NSNumber numberWithInt:1],
                    [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:4],
                    [NSNumber numberWithInt:5],
                    [NSNumber numberWithInt:11],
                    [NSNumber numberWithInt:13],
                    [NSNumber numberWithInt:15],
                    [NSNumber numberWithInt:16],
                    
                    nil];
    if (self.kLineView.kType==0) {
        _firstColors = [[NSMutableArray alloc] initWithObjects:
                        [NSNumber numberWithInt:0],
                        [NSNumber numberWithInt:1],
                        [NSNumber numberWithInt:2],
                        [NSNumber numberWithInt:5],
                        [NSNumber numberWithInt:6],
                        [NSNumber numberWithInt:7],
                        [NSNumber numberWithInt:8],
                        [NSNumber numberWithInt:10],
                        [NSNumber numberWithInt:13],
                        
                        nil];
    }
    _request = [[hangqingHttpRequest alloc] init];
    _requestBets = [[hangqingHttpRequest alloc] init];
}

#pragma mark 初始化界面
-(void)initViews{
    // 第一个分栏
    UIView *firstColumn = [self createTitleView:CGRectMake(0, 0, self.view.frame.size.width, ktitleViewHeight) andTitle:@"行情报价"];
    // 添加第一个分栏的内容视图
    [self addFirstSubViews:firstColumn];
    // 如果是个股才会显示资金流向 成交明细等信息 否则不显示
    if (self.kLineView.kType>0) {
        // 第二个分栏
        NSString *sTitle = @"资金流向(万元)";
        if ([[_firstValues objectAtIndex:22] floatValue]>10000) {
            sTitle = @"资金流向(亿元)";
            [_firstValues replaceObjectAtIndex:22 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:22] floatValue]/10000]];
            [_firstValues replaceObjectAtIndex:23 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:23] floatValue]/10000]];
            [_firstValues replaceObjectAtIndex:24 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:24] floatValue]/10000]];
            [_firstValues replaceObjectAtIndex:25 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:25] floatValue]/10000]];
            [_firstValues replaceObjectAtIndex:26 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:26] floatValue]/10000]];
            [_firstValues replaceObjectAtIndex:27 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:27] floatValue]/10000]];
            [_firstValues replaceObjectAtIndex:28 withObject:[[NSString alloc] initWithFormat:@"%.2f",[[_firstValues objectAtIndex:28] floatValue]/10000]];
        }
        UIView *secondColumn = [self createTitleView:CGRectMake(0, 380, self.view.frame.size.width, ktitleViewHeight) andTitle:sTitle];
        // 添加第二个分栏的内容视图
        [self addSencondSubViews:secondColumn];
        // 第三个分栏
        UIView *threeColumn = [self createTitleView:CGRectMake(0, 600, self.view.frame.size.width, ktitleViewHeight) andTitle:@"成交明细"];
        // 添加第三个分栏的内容视图
        [self addThreeSubViews:threeColumn];
    }
    

}

#pragma mark 更新视图
-(void)updateView{
    // 更新主视图的高度
    UIView *lastView = (UIView*)[[self.view subviews] lastObject];
    if (self.kLineView) {
        [self.kLineView updateMainViewHeight:(lastView.frame.size.height+lastView.frame.origin.y+30)];
    }
    
}

#pragma mark 创建一根标题视图
-(UIView*)createTitleView:(CGRect)frame andTitle:(NSString*)title{
    // 添加栏目视图
    UIView *titleView = [[UIView alloc] initWithFrame:frame];
    titleView.backgroundColor = UIColorFromRGB(0xe1e1e1);
    // 添加标题
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    t.text = title;
    t.textColor = UIColorFromRGB(0x000000);
    t.textAlignment = NSTextAlignmentCenter;
    t.font = [UIFont fontWithName:kFontName size:16];;
    t.backgroundColor = ClearColor;
    [titleView addSubview:t];
    [self.view addSubview:titleView];
    // 底线
//    UIView *bottomline = [DCommon drawLineWithSuperView:titleView position:NO];
//    bottomline.backgroundColor = UIColorFromRGB(0x808080);
//    
//    UIView *topline = [DCommon drawLineWithSuperView:titleView position:YES];
//    topline.backgroundColor = UIColorFromRGB(0x808080);
    
    return titleView;
}
#pragma mark 添加第一个分栏下的子视图
-(void)addFirstSubViews:(UIView*)superView{
    CGFloat x = 15;
    CGFloat y = superView.frame.size.height+superView.frame.origin.y + 10;
    CGFloat width = (superView.frame.size.width-40)/2;
    CGFloat height = 30;
    // 循环添加子标签
    for (int i=0; i<_firstTitles.count; i++) {
        // 添加名称
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        l.text = [_firstTitles objectAtIndex:i];
        l.textAlignment = NSTextAlignmentLeft;
        l.font = ktitleFont;
        l.textColor = UIColorFromRGB(0x000000);
        l.backgroundColor = ClearColor;
        [l sizeToFit];
        [self.view addSubview:l];
        // 添加对应的数值
        UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake(l.frame.size.width+l.frame.origin.x+5, y-6, width, height)];
        v.textAlignment = NSTextAlignmentLeft;
        NSString *vvalue = @"--";
        
        if (i<_firstValues.count){
            vvalue = [_firstValues objectAtIndex:i];
            if ([vvalue floatValue]==0) {
                vvalue = @"--";
            }
        }
        v.text = vvalue ;
        v.textColor = UIColorFromRGB(0x000000);
        v.backgroundColor = ClearColor;
        //[v sizeToFit];
        // 制定下标改变颜色
        if ([_firstColors containsObject:[NSNumber numberWithInt:i]]) {
            // 如果是负的值就是绿色，否则红色
            if (i<_firstValues.count && vvalue.length>0){
                if ([[v.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"]) {
                    v.textColor = kGreenColor;
                }else{
                    v.textColor = kRedColor;
                }
                if ([v.text intValue]==0) {
                    v.textColor = UIColorFromRGB(0x000000);
                }
            }
            if (self.kLineView.kType==0) {
                // 大盘处理
                CGFloat yestodayClosePrice = [self.kLineView.pDatas.yesterdayPrice floatValue];
                if (i==0 || i==1 || i==2 || i==8 || i==9 || i==10) {
                    if ([v.text floatValue]<yestodayClosePrice) {
                        v.textColor = kGreenColor;
                    }
                    else{
                        v.textColor = kRedColor;
                    }
                }
                if (i==5 || i==6) {
                    v.textColor = kRedColor;
                }
                if (i==7 || i==13) {
                    v.textColor = kGreenColor;
                }
            }
            
        }
        v.font = ktitleFont;
        [self.view addSubview:v];
        y +=height; // y轴自增
        // x轴变换
        int changeX = _firstTitles.count/2-1;// 个股的
        if (self.kLineView.kType==0) {
            changeX = 7; // 大盘的
        }
        if (i==changeX) {
            x += width+10;
            y = superView.frame.size.height+superView.frame.origin.y + 10;
        }
    }
}

#pragma mark 添加第二个分栏下的子视图
-(void)addSencondSubViews:(UIView*)superView{
    CGFloat x = 5;
    CGFloat y = superView.frame.size.height+superView.frame.origin.y + 10;
    CGFloat width = (superView.frame.size.width-10)/2;
    CGFloat height = 150;
    // 左边视图
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(x, y, width+0.5, height)];
    lv.layer.borderWidth = 0.5;
    lv.layer.borderColor = UIColorFromRGB(0x898989).CGColor;
    lv.backgroundColor = ClearColor;
    [self.view addSubview:lv];
    // 右边视图
    UIView *rv = [[UIView alloc] initWithFrame:CGRectMake(x+width, y, width, height)];
    rv.layer.borderWidth = 0.5;
    rv.layer.borderColor = UIColorFromRGB(0x898989).CGColor;
    rv.backgroundColor = ClearColor;
    [self.view addSubview:rv];
    // 左边视图加三行标题描述
    NSArray *t = [[NSArray alloc] initWithObjects:@"主力流入",@"主力流出",@"主力净流入", nil];
    CGFloat sY = 15; // y轴开始
    CGFloat lH = 40; // label高度
    UIFont *lF = [UIFont fontWithName:kFontName size:14]; // 字体大小
    for (int i=0; i<3; i++) {
        // 添加名称
        UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake(5, sY, width, lH)];
        v.backgroundColor = ClearColor;
        v.font = lF;
        v.text = [t objectAtIndex:i];
        v.textColor = UIColorFromRGB(0x000000);
        [v sizeToFit];
        [lv addSubview:v];
        // 添加对应数值
        UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(100, v.frame.origin.y, width-15, lH)];
        value.backgroundColor = ClearColor;
        value.font = lF;
        value.textAlignment = NSTextAlignmentRight;
        value.textColor = UIColorFromRGB(0xFFFFFF);
        
        if (i==0) {
            if (_firstValues.count>22) {
                value.text = [_firstValues objectAtIndex:22];
            }
            value.textColor = kRedColor;
        }
        if (i==1) {
            if (_firstValues.count>23) {
            value.text = [_firstValues objectAtIndex:23];
            }
            value.textColor = kBlueColor;
        }
        if (i==2) {
            if (_firstValues.count>24) {
                value.text = [[NSString alloc] initWithFormat:@"%d",abs([[_firstValues objectAtIndex:24] floatValue])];
                value.textColor = kRedColor;
                if ([[_firstValues objectAtIndex:24] floatValue]<0) {
                    value.textColor = kBlueColor;
                    v.text = @"主力净流出";
                }
            }
        }
        [value sizeToFit];
        [lv addSubview:value];
        value = nil;
        sY += lH;
        v = nil;
    }
    // 右边加柱状图
    // 加四个柱状图
    sY = 10;
    CGFloat sX = 5;
    CGFloat vW = (width-25)/4; // 圆柱体宽度
    NSArray *tt = [[NSArray alloc] initWithObjects:@"超大",@"大单",@"中单",@"小单", nil];
    NSArray *vv = [[NSArray alloc] initWithObjects:
                   [_firstValues objectAtIndex:25],
                   [_firstValues objectAtIndex:26],
                   [_firstValues objectAtIndex:27],
                   [_firstValues objectAtIndex:28],
                   nil];
    if (vv.count<4)
    vv = [[NSArray alloc] initWithObjects:@"373",@"520",@"-665",@"-228", nil];
    // 计算柱状图最大值
    CGFloat maxHeight = 1;
    for (int i=0; i<vv.count; i++) {
        if (fabsf([[vv objectAtIndex:i] floatValue])>maxHeight) {
            maxHeight = fabsf([[vv objectAtIndex:i] floatValue]);
        }
    }
    CGFloat lbHeight = 30; // 超大单等文字视图高度
    CGFloat realHeight = rv.height - lbHeight - 20; // 柱状图实际像素高度
    CGFloat bili = realHeight/maxHeight/2;// 柱状图数值与实际像素的比例
    for (int i=0; i<4; i++) {
        NSString *value = [vv objectAtIndex:i];
        CGFloat height = bili * [value floatValue];
        if (height<=1 && height>=0 && [value floatValue]>0) {
            height = 1;
        }
        if (height>-1 && height<=0 && [value floatValue]<0) {
            height = -1;
        }
        // 圆柱体
        [self columnChartWithSuperView:rv andFrame:CGRectMake(sX, sY+realHeight/2, vW, -height) andValue:value];
        // 底部放个描述
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(sX, rv.frame.size.height-lbHeight, (width-25)/4, lbHeight)];
        l.backgroundColor = ClearColor;
        l.text = [tt objectAtIndex:i];
        l.textColor = UIColorFromRGB(0x000000);
        l.font = lF;
        l.textAlignment = NSTextAlignmentCenter;
        [rv addSubview:l];
        l = nil;
        sX += vW +5;
    }
    tt = nil;
    vv = nil;
}

#pragma mark 添加第三个分栏下的子视图
-(void)addThreeSubViews:(UIView*)superView{
    // 添加表格上的标题
    CGFloat width = superView.frame.size.width/3;
    CGFloat sY = superView.frame.size.height+superView.frame.origin.y; // y轴开始
    CGFloat sX = 0; // x轴开始
    CGFloat lH = 40; // label高度
    UIFont *lF = [UIFont fontWithName:kFontName size:16];; // 字体大小
    NSArray *t = [[NSArray alloc] initWithObjects:@"时间",@"价格",@"现手", nil];
    for (int i=0; i<3; i++) {
        // 添加名称
        UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake(sX, sY, width, lH)];
        v.backgroundColor = ClearColor;
        v.font = lF;
        v.text = [t objectAtIndex:i];
        v.textColor = UIColorFromRGB(0x808080);
        v.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:v];
        sX += width;
        v = nil;
    }
    // 加根线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, sY+lH, superView.frame.size.width-10*2, 0.5)];
    line.backgroundColor = UIColorFromRGB(0x898989);
    [self.view addSubview:line];

    _tableView = [[baseTableView alloc] initWithFrame:
                  CGRectMake(superView.frame.origin.x,
                             sY+lH+0.5,
                             superView.frame.size.width,
                             250)
                  style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = ClearColor;
    _tableView.separatorColor = UIColorFromRGB(0x636363);
    // 适配ios7
    if (kDeviceVersion>=7) {
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    [self.view addSubview:_tableView];
    
}

#pragma mark 生成一个柱状图
// 包括柱状图以及值描述标题
-(void)columnChartWithSuperView:(UIView*)superView andFrame:(CGRect)frame andValue:(NSString*)value{
    UIColor *c = kRedColor;
    UIView *chart = [[UIView alloc] initWithFrame:frame];
    [superView addSubview:chart];
    if (value.length>0) {
        CGFloat y = frame.origin.y;
        // 设置柱状图的颜色
        c = kRedColor;
        if ([[value substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"]) {
            c = kBlueColor;
            c = [UIColor colorWithRed:21/255.0f green:65/255.0f blue:145/255.0f alpha:1];
            y = frame.origin.y -20;
        }
        chart.backgroundColor = c;
        // 值标题
        UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, y, frame.size.width,20)];
        v.backgroundColor = ClearColor;
        v.font = [UIFont fontWithName:kFontName size:10];;
        v.text = value;

        
        v.textColor = c;
        v.textAlignment = NSTextAlignmentCenter;
        [superView addSubview:v];
    }
}

#pragma mark ---------------------------------UITableViewDelegate代理实现-------------------------------------
#pragma mark 表格总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _volData.count;
}
#pragma mark 表格cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
#pragma mark 表格cell的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [[NSString alloc] initWithFormat:@"pankouCell_%d",indexPath.row];
    basehqCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell==nil) {
        cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;

        // 第一列
        UILabel *a = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, cell.frame.size.width/3, cell.frame.size.height)];
        a.text = @"-";
        a.backgroundColor = ClearColor;
        a.textColor = UIColorFromRGB(0x000000);
        [cell.contentView addSubview:a];
        a = nil;
        // 第二列
        UILabel *b = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/3, 0, cell.frame.size.width/3, cell.frame.size.height)];
        b.text = @"-";
        b.backgroundColor = ClearColor;
        b.textColor = UIColorFromRGB(0xFFFFFF);
        b.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:b];
        
        // 第二列上下箭头
        // {...}
        
        // 第三列
        UILabel *c = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/3*2, 0, cell.frame.size.width/3, cell.frame.size.height)];
        c.text = @"-";
        c.backgroundColor = ClearColor;
        c.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:c];
        c = nil;
        
        NSString *path=[[NSBundle mainBundle]pathForResource:@"D_kDown@2x" ofType:@"png"];
        UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
        
        // 箭头
        UIImageView *jiantou = [[UIImageView alloc] initWithFrame:CGRectMake(b.frame.origin.x+b.frame.size.width, b.frame.origin.y, imageSize.size.width, imageSize.size.height)];
        jiantou.image = kD_kDownPng;
        [cell.contentView addSubview:jiantou];
        jiantou = nil;

        b = nil;
        
        [cell show];
    }
    if (indexPath.row<_volData.count) {
        UIColor *color = kRedColor; // 默认红色
        CGFloat index0 = 0;
        CGFloat index1 = 1;
        CGFloat index2 = 2;
        CGFloat index3 = 3;
        if (cell.contentView.subviews.count>4) {
            index0 = 1;
            index1 = 2;
            index2 = 3;
            index3 = 4;
        }
        // 得到成交量模型
        fiveAndDetailModel *_volModel = (fiveAndDetailModel*)[_volData objectAtIndex:indexPath.row];
        if (indexPath.row+1<_volData.count) {
            fiveAndDetailModel *pre = (fiveAndDetailModel*)[_volData objectAtIndex:indexPath.row+1];
            _preValue = [pre.two floatValue];
        }else
        {
            _preValue = 0;
        }
        color = kRedColor;
        UIImage *img = kD_kDownPng;
        CGFloat yestodayClosePrice = [self.kLineView.pDatas.yesterdayPrice floatValue];
        UILabel *one = (UILabel*)[cell.contentView.subviews objectAtIndex:index0];
        one.text = _volModel.one;
        one = nil;
        
        if ([_volModel.two floatValue]<yestodayClosePrice) {
            color = kGreenColor;
        }
        
        UILabel *two = (UILabel*)[cell.contentView.subviews objectAtIndex:index1];
        two.text = _volModel.two;
        two.textColor = color;
        two = nil;
        // 根据与上一分钟的价格对比得出红绿色箭头
        if ([_volModel.two floatValue]<_preValue) {
            img = kD_kDownPng;
        }
        if ([_volModel.two floatValue]>_preValue) {
            img = kD_kUpPng;
        }
        if ([_volModel.two floatValue]==_preValue) {
            img = nil;
        }
        // 根据价格类型来定义成交量的红绿色
        if ([_volModel.priceType floatValue]==1) {
            color = kRedColor;
        }
        if ([_volModel.priceType intValue]==-1) {
            color = kGreenColor;
        }
        
        UILabel *three = (UILabel*)[cell.contentView.subviews objectAtIndex:index2];
        three.text = [[NSString alloc] initWithFormat:@"%0.0f",round([_volModel.three floatValue])];
        three.textColor = color;
        three.textAlignment = NSTextAlignmentCenter;
        [three sizeToFit];
        three.frame = CGRectMake(cell.frame.size.width/3*2+(cell.frame.size.width/3-three.frame.size.width)/2, 0, three.frame.size.width, cell.frame.size.height);
        UIImageView *jiantou = (UIImageView*)[cell.contentView.subviews objectAtIndex:index3];
        jiantou.image = img;
        jiantou.frame = CGRectMake(three.frame.size.width+three.frame.origin.x+5, (cell.frame.size.height-kD_kUpPng.size.height)/2, kD_kUpPng.size.width, kD_kUpPng.size.height);
        
        three = nil;
        _volModel = nil;
        
    }
    return cell;
}


#pragma mark --------------------------------接口处理------------------------------
#pragma mark 请求接口
-(void)getFiveAndDetail:(BOOL)isAsyn{
    [self clearTimer];
    [_request requestFiveAndDetail:self Class:@"2" andkId:self.kLineView.kId  andType:[[NSString alloc] initWithFormat:@"%d",self.kLineView.kType] isAsyn:isAsyn];
}
#pragma mark 数据返回
-(void)getFiveAndDetailBundle:(NSMutableArray*)data{
    _volData = data;
    [_tableView reloadData];
    // 如果开盘则开始刷新
    if (!self.kLineView.isStop && !isStopRefresh) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getFiveAndDetail:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{
        [self clearTimer];
    }
}
#pragma mark 清除timer
-(void)clearTimer{
    // NSLog(@"---DFM---清除Timer");
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}

@end
