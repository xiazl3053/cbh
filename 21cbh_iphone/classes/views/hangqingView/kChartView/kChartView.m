//
//  kChartView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kChartView.h"
#import "kLine.h"
#import "kLineModel.h"
#import "UIColor+helper.h"
#import "DCommon.h"
#import "StockIndexOperation.h"
#import "KLineViewController.h"

@implementation kChartParamModel

@end

@interface kChartView()<UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *mainboxView; // k线主视图
    UIView *bottomBoxView; // 成交量视图
    UIView *movelineone; // 手指按下后显示的两根白色十字线
    UIView *movelinetwo;
    UILabel *movelineoneLable;
    UILabel *movelinetwoLable;
    NSMutableArray *pointArray; // k线所有坐标数组
    CGFloat MADays;
    UILabel *MA5; // 5均线显示
    UILabel *MA10; // 10均线
    UILabel *MA20; // 20均线
    UILabel *volLb ;// 当前成交量
    UILabel *volMA5; // 成交量MA5
    UILabel *volMA10 ;// 成交量MA10;
    UILabel *startDateLab;
    UILabel *endDateLab;
    UILabel *volMaxValueLab; // 显示成交量最大值
    NSMutableArray *lineArray ; // k线数组
    NSMutableArray *lineOldArray ; // k线数组
    UIPinchGestureRecognizer *pinchGesture; // 放大缩小手势
    UILongPressGestureRecognizer *longPressGestureRecognizer;// 长按手势
    UITapGestureRecognizer *chartTapGesture; //点击手势
    CGPoint touchViewPoint;
    CGFloat maxValue; // 最大值
    CGFloat minValue; // 最小值
    CGFloat volMaxValue ; // 指标视图最大值
    CGFloat volMinValue ; // 指标视图最小值
    CGFloat MACDMaxValue; // MACD视图的最大值
    CGFloat MACDMinValue; // MACD视图的最小值
    CGFloat KDJMaxValue; // KDJ视图的最大值
    CGFloat KDJMinValue; // KDJ视图的最小值
    UIColor *MA5Color;// MA5颜色
    UIColor *MA10Color;// MA10颜色
    UIColor *MA20Color;// MA20颜色
    UIColor *DIFColor;// MACD中DIF线颜色
    UIColor *DEAColor;// MACD中DEA线颜色
    UIColor *MColor;// MACD中M线的颜色
    UIColor *KColor;// KDG中K线颜色
    UIColor *DColor;// KDG中D线颜色
    UIColor *JColor;// KDG中G线的颜色
    NSString *titleColor; // 文字颜色
    UIFont *MAFont; // 均线字体
    UIButton *indexButton;// 指标选择按钮
    // 当前指标视图
    UIScrollView *_indexViews;// 当前滚动视图
    UIView *_MACDViews;// macd视图
    UIView *_KDJViews;// kdj视图
    NSMutableArray *_pickerArray;// 指标集合
    UIView *_pickerView;// 指标选择器盒子
    UIPickerView *_picker;//选择器控件
    NSMutableArray *_locaDatas;// 页面缓存数据
    NSOperationQueue *_queue;// 线程
    
    BOOL isUpdate;
    BOOL isUpdateFinish;
    BOOL _isFirst;// 是否第一次加载
    BOOL isPinch;
    BOOL isC ;
    int _page;
    int _pageCount; //总页数
    int leftPadding;// 画图时左边开始的间隔 用来修正画图缺陷
    
}

@end

@implementation kChartView

-(id)init{
    self = [super init];
    if (self) {
        // 初始化参数
        [self initParam];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化参数
        [self initParam];
    }
    return self;
}

-(void)dealloc{
    [self free];
}

-(void)free{
    // 释放子线程
    [_queue cancelAllOperations];
    _queue = nil;
    if (lineArray) {
        [lineArray removeAllObjects];
    }
    [self removeOldKLine];
    [self removeAllSubviews];
    if (_locaDatas) {
        [_locaDatas removeAllObjects];
        _locaDatas = nil;
    }
    [mainboxView removeGestureRecognizer:pinchGesture];
    [mainboxView removeGestureRecognizer:longPressGestureRecognizer];
    self.data = nil;
    mainboxView = nil;
    bottomBoxView = nil;
    movelineone = nil;
    movelinetwo = nil;
    movelinetwoLable = nil;
    movelineoneLable = nil;
    pointArray = nil;
    MA5 = nil;
    MA10 = nil;
    MA20 = nil;
    startDateLab = nil;
    endDateLab = nil;
    volMaxValueLab = nil;
    lineArray = nil;
    lineOldArray = nil;
    _pickerView = nil;
    _picker = nil;
    _pickerArray = nil;
}

-(void)didReceiveMemoryWarning{
    
}

#pragma mark ---------------------------自定义方法------------------------------
#pragma mark 初始化参数
-(void)initParam{
    
    self.xWidth = 280; // k线图宽度
    self.yHeight = 140; // k线图高度
    self.bottomBoxHeight = 40; // 底部成交量图的高度
    self.kLineWidth = 5;// k线实体的宽度
    self.kLinePadding = 1; // k实体的间隔
    self.font = [UIFont fontWithName:kFontName size:9]; // 字体
    _page = 1;// 当前页
    _pageCount = 3; // 总页数
    leftPadding = 0;
    MAFont = [UIFont fontWithName:kFontName size:10];
    MADays = 20;
    lineArray = [[NSMutableArray alloc] init];
    lineOldArray = [[NSMutableArray alloc] init];
    _pickerArray = [[NSMutableArray alloc] initWithObjects:@"VOL",@"MACD",@"KDJ", nil];
    _locaDatas = [[NSMutableArray alloc] init];
    maxValue = 0;
    minValue = CGFLOAT_MAX;
    volMaxValue = 0;
    volMinValue = CGFLOAT_MAX;
    MA5Color = UIColorFromRGB(0x0033CC) ;
    MA10Color = UIColorFromRGB(0xCC9909) ;
    MA20Color = UIColorFromRGB(0xCD3333) ;
    DIFColor = UIColorFromRGB(0xFFFFFF) ;
    DEAColor = UIColorFromRGB(0xFFFF00) ;
    MColor = UIColorFromRGB(0x00FFFF) ;
    KColor = UIColorFromRGB(0xFFFFFF) ;
    DColor = UIColorFromRGB(0xFFFF00) ;
    JColor = UIColorFromRGB(0x00FFFF) ;
    titleColor = @"#333333";
    _isFirst = NO;
    isUpdate = NO;
    isUpdateFinish = YES;
    isPinch = NO;
    _queue = [[NSOperationQueue alloc] init];
    // 完成更新本视图回调
    self.finishUpdateBlock = ^(id self){
        [self updateNib];
    };
}

#pragma mark 启动
-(void)startWith:(kChartParamModel *)model{
    if (model) {
        self.xWidth = model.width;
        self.parent = model.parent;
    }
    self.backgroundColor = ClearColor;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.yHeight);
    [self drawBox];
    [_queue addOperationWithBlock:^{
        [self drawLine];
    }];
    
}
#pragma mark 更新
-(void)updateWith:(kChartParamModel *)model{
    if (model) {
        self.xWidth = model.width;
        self.kLineWidth = model.kLineWidth;
        self.data = model.data;
        self.kLinePadding = model.padding;
        self.kCount = model.count;
        self.parent = model.parent;
    }
    if (self.kLineWidth>20)
        self.kLineWidth = 20;
    if (self.kLineWidth<1)
        self.kLineWidth = 1;
    isUpdate = YES;
    [_queue addOperationWithBlock:^{
        [self drawLine];
    }];
    
}
#pragma mark 私有更新
-(void)updateSelf{
    if (isUpdateFinish) {
        if (self.kLineWidth>10)
            self.kLineWidth = 10;
        if (self.kLineWidth<2)
            self.kLineWidth = 2;
        isUpdateFinish = NO;
        isUpdate = YES;
        [_queue addOperationWithBlock:^{
            [self drawLine];
        }];
    }
}

#pragma mark 画k线
-(void)drawLine{
    if (self.data.count>0) {
        NSLog(@"---DFM---开始生产k线图");
        @try {
            if (lineArray) {
                [lineArray removeAllObjects];
            }
            // 换算一下数据
            [self dataBundle];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新界面
                // 开始画K线图
                [self drawBoxWithKline];
                // 清除旧的k线
                [self removeOldKLine];
                lineOldArray = lineArray.copy;
                if (_finishUpdateBlock && isPinch) {
                    _finishUpdateBlock(self);
                }
                isUpdateFinish = YES;
                // 处理完成调用
                if (self.finishedBlock) {
                    if (!chartTapGesture) {
                        // 点击手势
                        chartTapGesture = [[UITapGestureRecognizer alloc] init];
                        chartTapGesture.numberOfTapsRequired = 1;
                        chartTapGesture.numberOfTouchesRequired = 1;
                        [chartTapGesture addTarget:self action:@selector(chartTapGestureAction:)];
                        [mainboxView addGestureRecognizer:chartTapGesture];
                    }
                    
                    self.finishedBlock(self);
                }
            });
        }
        @catch (NSException *exception) {
            NSLog(@"---DFM---K线图生产有误");
        }
        @finally {
            
        }
        NSLog(@"---DFM---完成生产k线图");
        
    }
}
#pragma mark 清除旧的k线
-(void)removeOldKLine{
    // 清除旧的k线
    if (lineOldArray.count>0 && isUpdate) {
        for (id item in lineOldArray) {
            UIView *line = (UIView*)item;
            //NSLog(@"---DFM---清除旧的K线%@",line);
            [line removeFromSuperview];
            line = nil;
        }
    }
}

#pragma mark 数据换算处理
-(void)dataBundle{
    if (self.data.count>0) {
        if (_locaDatas.count<=0) {
            NSLog(@"---DFM---开始缓存数据处理");
            // 存入缓存
            [self saveToLocaDatas:self.data];
            NSLog(@"---DFM---结束缓存数据处理");
        }
        // 初始化最高最低值
        maxValue = 0;
        minValue = CGFLOAT_MAX;
        volMaxValue = 0;
        volMinValue = CGFLOAT_MAX;
        MACDMaxValue = 0;
        MACDMinValue = CGFLOAT_MAX;
        KDJMaxValue = 0;
        KDJMinValue = CGFLOAT_MAX;
        NSLog(@"---DFM---开始大小计算数据处理");
        
        
        int startIndex = _locaDatas.count-self.kCount-1;
        if (startIndex<=0) {
            startIndex = 0;
        }
        /**
         *  change
         */
        int len = self.kCount+1;
        if (len>_locaDatas.count) {
            len=_locaDatas.count;
        }
        
        
        @try {
            
            self.data = [NSMutableArray arrayWithArray:[_locaDatas subarrayWithRange:NSMakeRange(startIndex, len)]];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        
       // NSMutableArray *newData = [[NSMutableArray alloc] init];
        int nowi = 0;
        for (int i=0;i<self.data.count;i++) {
        //for (int i=0;i<_locaDatas.count;i++) {
           // kLineModel *item = [_locaDatas objectAtIndex:i];
            kLineModel *item = [self.data objectAtIndex:i];
            if ([item.openPrice floatValue]<=0) {
                nowi ++;
                continue;
            }
            
           // [newData addObject:item];
            float M = 0;
            float J = 0;
            M = [item.MACD_M floatValue];
            J = [item.KDJ_J floatValue];
            // 计算MACD的最大最小
            if (M > MACDMaxValue) {
                MACDMaxValue = M;
            }
            if (M < MACDMinValue) {
                MACDMinValue = M;
            }
            // 计算KDJ的最大最小值
            if (J > KDJMaxValue) {
                KDJMaxValue = J;
            }
            if (J < KDJMinValue) {
                KDJMinValue = J;
            }
            
            if ([item.heightPrice isEqual:[NSNull null]]) {
                item.heightPrice = @"";
            }
            if ([item.volume isEqual:[NSNull null]]) {
                item.volume = @"";
            }
            if ([item.volumePrice isEqual:[NSNull null]]) {
                item.volumePrice = @"";
            }
            if ([item.lowPrice isEqual:[NSNull null]]) {
                item.lowPrice = @"";
            }
            if ([item.turnoverRate isEqual:[NSNull null]]) {
                item.turnoverRate = @"";
            }
            // y轴最大值
            CGFloat curentMaxValue = [item.heightPrice floatValue];
            if (curentMaxValue>maxValue) {
                maxValue = curentMaxValue;
                NSLog(@"curentMaxValue===%f",curentMaxValue);
            }
            // y轴最小值
            CGFloat curentMinValue = [item.lowPrice floatValue];
            if (curentMinValue<minValue && curentMaxValue>0) {
                minValue = curentMinValue;
            }
            // 成交量最大值
            CGFloat curentValue = [item.volume floatValue];
            if (curentValue>volMaxValue) {
                volMaxValue = curentValue;
            }
            // 成交量最小值
            if (curentValue<volMinValue && curentValue>0) {
                volMinValue = curentValue;
            }

            item = nil;
            
        }
//        int startIndex = newData.count-self.kCount-1;
//        if (startIndex<=0) {
//            startIndex = 0;
//        }
//        /**
//         *  change
//         */
//        int len = self.kCount+1;
//        if (len>newData.count) {
//            len=newData.count;
//        }
//        self.data = [NSMutableArray arrayWithArray:[newData subarrayWithRange:NSMakeRange(startIndex, len)]];
        NSLog(@"---DFM---结束大小计算数据处理");
    }
}
#pragma mark 数据第一次计算并存入页面缓存
-(void)saveToLocaDatas:(NSMutableArray*)data{
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    NSMutableArray *MACDList = [[NSMutableArray alloc] init];
    // 倒一次数据
    for (int i=data.count-1;i>=0;i--){
        kLineModel *item = [data objectAtIndex:i];
        if ([item.openPrice floatValue]<=0) {
            continue;
        }
        [newData addObject:[data objectAtIndex:i]];
    }
    data = newData.copy;
    [newData removeAllObjects];
    // 计算各种指标值
    // 计算每天KDJ值
    NSLog(@"---DFM---开始计算KDJ的值");
    NSMutableDictionary *KDJ = [StockIndexOperation getKDJMap:data];
    NSLog(@"---DFM---结束计算KDJ的值");
    // 循环计算每天的指标值
    for (int i=0;i<data.count;i++) {
        kLineModel *item = [data objectAtIndex:i];
        float DIF = 0;
        float DEA = 0;
        float M = 0;
        float K = 0;
        float D = 0;
        float J = 0;
        
        // 计算每天的MACD值
        NSMutableDictionary *MACD = [StockIndexOperation getMACD:data andDays:i DhortPeriod:12 LongPeriod:26 MidPeriod:9];
        if (MACD) {
            DIF = [[MACD valueForKey:@"DIF"] floatValue];
            DEA = [[MACD valueForKey:@"DEA"] floatValue];
            M = [[MACD valueForKey:@"M"] floatValue];
        }
        item.MACD_DIF = [NSString stringWithFormat:@"%f",DIF];
        item.MACD_DEA = [NSString stringWithFormat:@"%f",DEA];
        item.MACD_M = [NSString stringWithFormat:@"%f",M];
        MACD = nil;
        if (KDJ) {
            K = [[[KDJ valueForKey:@"K"] objectAtIndex:i] floatValue];
            D = [[[KDJ valueForKey:@"D"] objectAtIndex:i] floatValue];
            J = [[[KDJ valueForKey:@"J"] objectAtIndex:i] floatValue];
        }
        item.KDJ_K = [NSString stringWithFormat:@"%f",K];
        item.KDJ_D = [NSString stringWithFormat:@"%f",D];
        item.KDJ_J = [NSString stringWithFormat:@"%f",J];
        
        // 保存修改过的项
        [newData addObject:item];
        item = nil;
    }
    // 重新指向新数据
    data = newData;
    MACDList = nil;
    newData = nil;
    // 计算MA均线
    NSLog(@"---DFM---开始计算MA的值");
    [StockIndexOperation CalculateMA:data];
    NSLog(@"---DFM---结束计算MA的值");
    // 存入缓存
    _locaDatas = data;
    data = nil;
}


#pragma mark 在框框里画k线
-(void)drawBoxWithKline{
    // 分割线线
    CGFloat padValue = (maxValue - minValue) / 6;
    CGFloat padRealValue = mainboxView.frame.size.height / 6;
    for (int i = 0; i<7; i++) {
        CGFloat y = mainboxView.frame.size.height-padRealValue * i;
        // lable
        UILabel *leftTag = [[UILabel alloc] initWithFrame:CGRectMake(self.xWidth-self.frame.size.width, y-30/2, self.frame.size.width-self.xWidth-3, 30)];
        leftTag.text = [[NSString alloc] initWithFormat:@"%.2f",padValue*i+minValue];
        leftTag.textColor = [UIColor colorWithHexString:titleColor withAlpha:1];
        leftTag.font = self.font;
        leftTag.textColor = UIColorFromRGB(0x808080);
        leftTag.textAlignment = NSTextAlignmentRight;
        leftTag.backgroundColor = [UIColor clearColor];
        //[leftTag sizeToFit];
        [mainboxView addSubview:leftTag];
        [lineArray addObject:leftTag];
        leftTag = nil;
    }
    
    // 开始画连K线
    NSArray *ktempArray = [self changeKPointWithData:self.data]; // 换算成实际每天收盘价坐标数组
    kLine *kline = [[kLine alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
    kline.points = ktempArray;
    kline.lineWidth = self.kLineWidth;
    kline.isK = YES;
    [mainboxView addSubview:kline];
    [lineArray addObject:kline];
    kline = nil;
    ktempArray = nil;
    // 开始画均线
    // MA5
    [self drawMAWithIndex:5 andColor:MA5Color];
    // MA10
    [self drawMAWithIndex:10 andColor:MA10Color];
    // MA20
    [self drawMAWithIndex:20 andColor:MA20Color];
    
    // 开始画连成交量
    NSArray *voltempArray = [self changeVolumePointWithData:self.data]; // 换算成实际成交量坐标数组
    kLine *volline = [[kLine alloc] initWithFrame:CGRectMake(0, 0, bottomBoxView.frame.size.width, bottomBoxView.frame.size.height)];
    volline.points = voltempArray;
    volline.lineWidth = self.kLineWidth;
    volline.isK = YES;
    volline.isVol = YES;
    [bottomBoxView addSubview:volline];
    volMaxValueLab.text = [DCommon numToIntString:volMaxValue/100];
    [lineArray addObject:volline];
    volline = nil;
    // 开始画成交量的均线
    // MA5
    [self drawVolMAWithIndex:5 andColor:MA5Color];
    // MA10
    [self drawVolMAWithIndex:10 andColor:MA10Color];
    // 画MACD
    [self drawMACDIndex:@"DIF" andColor:DIFColor];
    [self drawMACDIndex:@"DEA" andColor:DEAColor];
    [self drawMACDWithColor:MColor]; // 画MACD的M线
    // 画KDJ指标
    [self drawKDJIndex:@"K" andColor:KColor];
    [self drawKDJIndex:@"D" andColor:DColor];
    [self drawKDJIndex:@"J" andColor:JColor];
}

#pragma mark ------------------------------画底部指标视图------------------------------

#pragma mark 画各种均线
-(void)drawMAWithIndex:(int)index andColor:(UIColor*)color{
    NSArray *tempArray = [self changePointWithData:self.data andMA:index]; // 换算成实际坐标数组
    kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
    line.color = color;
    line.points = tempArray;
    line.isK = NO;
    [mainboxView addSubview:line];
    [lineArray addObject:line];
    line = nil;
    tempArray = nil;
}

#pragma mark 画成交量的均线
-(void)drawVolMAWithIndex:(int)index andColor:(UIColor*)color{
    NSArray *tempArray = [self changeVolPointWithData:self.data andMA:index]; // 换算成实际坐标数组
    kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, _indexViews.frame.size.width, _indexViews.frame.size.height)];
    line.color = color;
    line.points = tempArray;
    line.isK = NO;
    [bottomBoxView addSubview:line];
    [lineArray addObject:line];
    line = nil;
    tempArray = nil;
}

#pragma mark 画MACD图 DIF DEA
-(void)drawMACDIndex:(NSString*)type andColor:(UIColor*)color{
    NSArray *tempArray = [self changeMACDPointWithData:self.data andType:type ]; // 换算成实际坐标数组
    kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, _indexViews.frame.size.width, _indexViews.frame.size.height)];
    line.color = color;
    line.points = tempArray;
    line.isK = NO;
    [_MACDViews addSubview:line];
    [lineArray addObject:line];
    line = nil;
    tempArray = nil;
}

#pragma mark 画MACD柱状图
-(void)drawMACDWithColor:(UIColor*)color{
    NSArray *tempArray = [self changeMACDPointWithData:self.data andType:@"M" ]; // 换算成实际坐标数组
    kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, _indexViews.frame.size.width, _indexViews.frame.size.height)];
    line.points = tempArray;
    line.color = color;
    line.isMACDM = YES;
    line.lineWidth = 2;
    [_MACDViews addSubview:line];
    [lineArray addObject:line];
    line = nil;
    tempArray = nil;
}

#pragma mark 画KDJ图 K D J
-(void)drawKDJIndex:(NSString*)type andColor:(UIColor*)color{
    NSArray *tempArray = [self changeKDJPointWithData:self.data andType:type ]; // 换算成实际坐标数组
    kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, _indexViews.frame.size.width, _indexViews.frame.size.height)];
    line.color = color;
    line.points = tempArray;
    line.isK = NO;
    [_KDJViews addSubview:line];
    [lineArray addObject:line];
    line = nil;
    tempArray = nil;
}


#pragma mark -----------------------------底部视图数据换算-----------------------------------

#pragma mark 把股市数据换算成实际的点坐标数组  MA = 5 为MA5 MA=10 MA10  MA =20 为MA20
-(NSArray*)changePointWithData:(NSArray*)data andMA:(int)MAIndex{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2+leftPadding; // 起始点坐标
    for (kLineModel *item in data) {
        CGFloat currentValue = [item.MA5 floatValue];// 得到前五天的均价价格
        if (MAIndex==10) {
            currentValue = [item.MA10 floatValue];
        }
        if (MAIndex==20) {
            currentValue = [item.MA20 floatValue];
        }
        // 换算成实际的坐标
        CGFloat currentPointY = mainboxView.frame.size.height - ((currentValue - minValue) / (maxValue - minValue) * mainboxView.frame.size.height);
        CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
        [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    return tempArray;
}
#pragma mark 换算成交量均线坐标
-(NSArray*)changeVolPointWithData:(NSArray*)data andMA:(int)MAIndex{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2+leftPadding; // 起始点坐标
    for (kLineModel *item in data) {
        CGFloat currentValue = [item.volMA5 floatValue];
        if (MAIndex==10) {
            currentValue = [item.volMA10 floatValue];
        }
        // 换算成实际的坐标
        CGFloat height = bottomBoxView.frame.size.height;
        CGFloat currentPointY = height - ((currentValue - volMinValue) / (volMaxValue - volMinValue) * height);
        CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
        [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    return tempArray;
}

#pragma mark 把MACD数据换算成实际的点坐标数组  DIF DEA M
-(NSArray*)changeMACDPointWithData:(NSArray*)data andType:(NSString*)type{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2+leftPadding; // 起始点坐标
    for (kLineModel *item in data) {
        CGFloat currentValue = 0;;// 得到
        if ([type isEqualToString:@"DIF"]) {
            currentValue = [item.MACD_DIF floatValue];
        }
        if ([type isEqualToString:@"DEA"]) {
            currentValue = [item.MACD_DEA floatValue];
        }
        if ([type isEqualToString:@"M"]) {
            currentValue = [item.MACD_M floatValue];
        }
        // 换算成实际的坐标
        CGFloat currentPointY = _indexViews.frame.size.height - ((currentValue - MACDMinValue) / (MACDMaxValue - MACDMinValue) * _indexViews.frame.size.height)+0.5;
        // 盒子一半的点坐标
        CGFloat halfY = _indexViews.frame.size.height * (fabsf(MACDMaxValue)/(fabsf(MACDMaxValue)+fabsf(MACDMinValue)));
        
        CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
        
        // 如果是M线则单独处理
        if ([type isEqualToString:@"M"]) {
            CGPoint openPoint = CGPointMake(PointStartX, 0);
            CGPoint closePoint = CGPointMake(PointStartX, 0);
            CGPoint heightPoint = CGPointMake(PointStartX, currentPointY);
            CGPoint lowPoint = CGPointMake(PointStartX, halfY);// 连接到中间
            if (currentPointY >halfY) {
                closePoint = CGPointMake(PointStartX, 0.1);
            }
            
            // 实际坐标组装为数组
            NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                     NSStringFromCGPoint(heightPoint),
                                     NSStringFromCGPoint(lowPoint),
                                     NSStringFromCGPoint(openPoint),
                                     NSStringFromCGPoint(closePoint),
                                    nil];
            [tempArray addObject:currentArray]; // 把坐标添加进新数组
            currentArray = nil;
        }else
        {
            [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        }
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    return tempArray;
}


#pragma mark 把KDG数据换算成实际的点坐标数组  K D J
-(NSArray*)changeKDJPointWithData:(NSArray*)data andType:(NSString*)type{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2+leftPadding; // 起始点坐标
    for (kLineModel *item in data) {
        CGFloat currentValue = 0;;// 得到
        if ([type isEqualToString:@"K"]) {
            currentValue = [item.KDJ_K floatValue];
        }
        if ([type isEqualToString:@"D"]) {
            currentValue = [item.KDJ_D floatValue];
        }
        if ([type isEqualToString:@"J"]) {
            currentValue = [item.KDJ_J floatValue];
        }
        // 换算成实际的坐标
        CGFloat currentPointY = _indexViews.frame.size.height - ((currentValue - KDJMinValue) / (KDJMaxValue - KDJMinValue) * _indexViews.frame.size.height)+0.5;
        CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
        [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    return tempArray;
}

#pragma mark ---------------------------k线视图数据换算-----------------------------

#pragma mark 把股市数据换算成实际的点坐标数组
-(NSArray*)changeKPointWithData:(NSArray*)data{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (pointArray) {
        [pointArray removeAllObjects];
        pointArray = nil;
    }
    pointArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2+leftPadding; // 起始点坐标
    for (kLineModel *item in data) {

        CGFloat heightvalue = [item.heightPrice floatValue];// 得到最高价
        CGFloat lowvalue = [item.lowPrice floatValue];// 得到最低价
        CGFloat openvalue = [item.openPrice floatValue];// 得到开盘价
        CGFloat closevalue = [item.closePrice floatValue];// 得到收盘价
        CGFloat yHeight = maxValue - minValue ; // y的价格高度
        CGFloat yViewHeight = mainboxView.frame.size.height ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat heightPointY = yViewHeight * (1 - (heightvalue - minValue) / yHeight);
        CGPoint heightPoint =  CGPointMake(PointStartX, heightPointY); // 最高价换算为实际坐标值
        CGFloat lowPointY = yViewHeight * (1 - (lowvalue - minValue) / yHeight);;
        CGPoint lowPoint =  CGPointMake(PointStartX, lowPointY); // 最低价换算为实际坐标值
        CGFloat openPointY = yViewHeight * (1 - (openvalue - minValue) / yHeight);;
        CGPoint openPoint =  CGPointMake(PointStartX, openPointY); // 开盘价换算为实际坐标值
        CGFloat closePointY = yViewHeight * (1 - (closevalue - minValue) / yHeight);;
        CGPoint closePoint =  CGPointMake(PointStartX, closePointY); // 收盘价换算为实际坐标值
        
        // 实际坐标组装为数组
        NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                 NSStringFromCGPoint(heightPoint),
                                 NSStringFromCGPoint(lowPoint),
                                 NSStringFromCGPoint(openPoint),
                                 NSStringFromCGPoint(closePoint),
                                 item.time, // 保存日期时间
                                 item.closePrice, // 收盘价
                                 item.MA5, // MA5
                                 item.MA10, // MA10
                                 item.MA20, // MA20
                                 item.volume,
                                 item.volMA5,
                                 item.volMA10,
                                 item.MACD_DIF,
                                 item.MACD_DEA,
                                 item.MACD_M,
                                 item.KDJ_K,
                                 item.KDJ_D,
                                 item.KDJ_J,
                                 item,
                                 nil];
        [tempArray addObject:currentArray]; // 把坐标添加进新数组
        //[pointArray addObject:[NSNumber numberWithFloat:PointStartX]];
        currentArray = Nil;
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
        
        // 在成交量视图左右下方显示开始和结束日期
        if ([data indexOfObject:item]==0) {
            startDateLab.text = item.time;
        }
        if ([data indexOfObject:item]==data.count-1) {
            [self updateMALableValue:item];
        }
    }
    pointArray = tempArray;
    return tempArray;
}
#pragma mark 更新显示的值
-(void)updateMALableValue:(kLineModel*)item{
    if (_data.count>0) {
        if (!item) {
            item = [_data lastObject];
        }
        endDateLab.text = item.time;
        // 均线值显示
        MA5.text = [[NSString alloc] initWithFormat:@"MA5:%.2f",[item.MA5 floatValue]];
        [MA5 sizeToFit];
        MA10.text = [[NSString alloc] initWithFormat:@"MA10:%.2f",[item.MA10 floatValue]];
        [MA10 sizeToFit];
        MA10.frame = CGRectMake(MA5.frame.origin.x+MA5.frame.size.width+10, MA10.frame.origin.y, MA10.frame.size.width, MA10.frame.size.height);
        MA20.text = [[NSString alloc] initWithFormat:@"MA20:%.2f",[item.MA20 floatValue]];
        [MA20 sizeToFit];
        MA20.frame = CGRectMake(MA10.frame.origin.x+MA10.frame.size.width+10, MA20.frame.origin.y, MA20.frame.size.width, MA20.frame.size.height);
        
        // 成交量均线值显示
        
        NSString *DMA0 = @"";
        NSString *DMA5 = @"MA5";
        NSString *DMA10 = @"MA10";
        NSString *DMName = @"VOL";
        NSString *itemValue0 = [DCommon numToUnits:[item.volume floatValue]/100];
        NSString *itemValue5 = [DCommon numToUnits:[item.volMA5 floatValue]/100];
        NSString *itemValue10 = [DCommon numToUnits:[item.volMA5 floatValue]/100];
        // 显示成交量最大值
        volMaxValueLab.text = [DCommon numToIntString:volMaxValue/100];
        if (_page==2) {
            DMA0 = @"DIF:";
            DMA5 = @"DEA";
            DMA10 = @"M";
            DMName = @"MACD";
            itemValue0 = [DCommon stringChange:item.MACD_DIF];
            itemValue5 = [DCommon stringChange:item.MACD_DEA];
            itemValue10 = [DCommon stringChange:item.MACD_M];
            // 显示MACD最大值
            volMaxValueLab.text = [DCommon numToUnits:MACDMaxValue];
        }
        if (_page==3) {
            DMA0 = @"K:";
            DMA5 = @"D";
            DMA10 = @"J";
            DMName = @"KDJ";
            itemValue0 = [DCommon stringChange:item.KDJ_K];
            itemValue5 = [DCommon stringChange:item.KDJ_D];
            itemValue10 = [DCommon stringChange:item.KDJ_J];
            // 显示KDJ最大值
            volMaxValueLab.text = [DCommon numToUnits:KDJMaxValue];
        }
        // 成交量均线值显示
        volLb.text = [[NSString alloc] initWithFormat:@"%@%@",DMA0,itemValue0];
        [volLb sizeToFit];
        volMA5.text = [[NSString alloc] initWithFormat:@"%@:%@",DMA5,itemValue5];
        [volMA5 sizeToFit];
        volMA5.frame = CGRectMake(volLb.frame.origin.x+volLb.frame.size.width+10, volMA5.frame.origin.y, volMA5.frame.size.width, volMA5.frame.size.height);
        volMA10.text = [[NSString alloc] initWithFormat:@"%@:%@",DMA10,itemValue10];
        [volMA10 sizeToFit];
        volMA10.frame = CGRectMake(volMA5.frame.origin.x+volMA5.frame.size.width+10, volMA10.frame.origin.y, volMA10.frame.size.width, volMA10.frame.size.height);
        // 指标按钮
        [indexButton setTitle:DMName forState:UIControlStateNormal];
    }
}

#pragma mark 把股市数据换算成成交量的实际坐标数组
-(NSArray*)changeVolumePointWithData:(NSArray*)data{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2+leftPadding; // 起始点坐标
//    if (data.count<=0) {
//        return nil;
//    }
    for (kLineModel *item in data) {
        CGFloat volumevalue = [item.volume floatValue];// 得到没份成交量
        CGFloat yHeight = volMaxValue - volMinValue ; // y的价格高度
        CGFloat yViewHeight = bottomBoxView.frame.size.height ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY = yViewHeight * (1 - (volumevalue - volMinValue) / yHeight);
        CGPoint volumePoint =  CGPointMake(PointStartX, volumePointY); // 成交量换算为实际坐标值
        CGPoint volumePointStart = CGPointMake(PointStartX, yViewHeight);
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = [item.openPrice floatValue];// 得到开盘价
        CGFloat closevalue = [item.closePrice floatValue];// 得到收盘价
        CGPoint openPoint =  CGPointMake(PointStartX, closevalue); // 开盘价换算为实际坐标值
        CGPoint closePoint =  CGPointMake(PointStartX, openvalue); // 收盘价换算为实际坐标值
        // 实际坐标组装为数组
        NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                 NSStringFromCGPoint(volumePointStart),
                                 NSStringFromCGPoint(volumePoint),
                                 NSStringFromCGPoint(openPoint),
                                 NSStringFromCGPoint(closePoint),
                                 nil];
        [tempArray addObject:currentArray]; // 把坐标添加进新数组
        currentArray = Nil;
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    NSLog(@"处理完成");
    return tempArray;
}
#pragma mark ----------------------------手势交换-----------------------
-(void)chartTapGestureAction:(UITapGestureRecognizer*)tapGesture{
    // 点击手势
    if (self.chartTapBlock) {
        self.chartTapBlock(self);
    }
}
#pragma mark 手指捏合动作
-(void)touchBoxAction:(UIPinchGestureRecognizer*)pGesture{
    NSLog(@"---DFM---手指捏合手势");
//    isPinch  = NO;
//    if (pGesture.state==2 && isUpdateFinish) {
//        if (pGesture.scale>1) {
//            // 放大手势
//            self.kLineWidth ++;
//            [self updateSelf];
//        }else{
//            // 缩小手势
//            self.kLineWidth --;
//            [self updateSelf];
//        }
//    }
//    if (pGesture.state==3) {
//        //isUpdateFinish = YES;
//        isPinch = NO;
//        [self update];
//    }
}
#pragma mark 长按就开始生成十字线
-(void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)longResture{
    // 至标志为已按下
    isPinch = YES;
    touchViewPoint = [longResture locationInView:mainboxView];
    // 手指长按开始时更新一遍
    if(longResture.state == UIGestureRecognizerStateBegan){
        // 更新一遍k线图
        [self updateNib];
    }
    // 手指移动时候开始显示十字线
    if (longResture.state == UIGestureRecognizerStateChanged) {
        [self isKPointWithPoint:touchViewPoint];
    }
    
    // 手指离开的时候移除十字线
    if (longResture.state == UIGestureRecognizerStateEnded) {
        [self updateMALableValue:nil];
        // 回调block
        if (self.pressUpBlock) {
            self.pressUpBlock(nil);
        }
        [movelineone removeFromSuperview];
        [movelinetwo removeFromSuperview];
        [movelineoneLable removeFromSuperview];
        [movelinetwoLable removeFromSuperview];
        movelineone = nil;
        movelinetwo = nil;
        movelineoneLable = nil;
        movelinetwoLable = nil;
        isPinch = NO;
    }
}

#pragma mark 判断并在十字线上显示提示信息
-(void)isKPointWithPoint:(CGPoint)point{
    CGFloat itemPointX = 0;
    CGPoint itemPoint;
    NSArray *items;
    if (pointArray.count<=0) {
        return;
    }
    for (NSArray *item in pointArray) {
        items = item;
        itemPoint = CGPointFromString([item objectAtIndex:3]);  // 收盘价的坐标
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = (int)point.x;
        if (itemX==pointX || point.x-itemX<=self.kLineWidth/2) {
            break;
        }
    }
    CGFloat leftWidth = self.frame.size.width - self.xWidth;
    itemPoint = CGPointMake(itemPoint.x+leftWidth, itemPoint.y);
    
    movelineone.frame = CGRectMake(itemPoint.x,movelineone.frame.origin.y, movelineone.frame.size.width, movelineone.frame.size.height);
    movelinetwo.frame = CGRectMake(movelinetwo.frame.origin.x,itemPoint.y+10, movelinetwo.frame.size.width, movelinetwo.frame.size.height);
    // 垂直提示日期控件
    movelineoneLable.text = [items objectAtIndex:4]; // 日期
    CGFloat oneLableY = _indexViews.frame.size.height+_indexViews.frame.origin.y;
    CGFloat oneLableX = 0;
    // 移动到左边
    if ((itemPoint.x)<(movelineoneLable.frame.size.width/2+leftWidth)) {
        oneLableX = movelineoneLable.frame.size.width/2 + leftWidth - itemPoint.x;
    }
    if ((mainboxView.frame.size.width - itemPoint.x + leftWidth)<(movelineoneLable.frame.size.width/2)) {
        oneLableX = -(movelineoneLable.frame.size.width/2 - leftWidth - (mainboxView.frame.size.width - itemPoint.x));
    }
    movelineoneLable.frame = CGRectMake(itemPoint.x - movelineoneLable.frame.size.width/2 + oneLableX, oneLableY,
                                        movelineoneLable.frame.size.width, movelineoneLable.frame.size.height);
  
    // 横向提示价格控件
    CGFloat tipPrice = [[items objectAtIndex:5] floatValue];
    NSString *tipValue = [[NSString alloc] initWithFormat:@"%0.2f",tipPrice];
//    // 这里用于大盘显示
//    if (tipPrice>1000) {
//        tipValue = [[NSString alloc] initWithFormat:@"%0.0f",tipPrice];
//    }
    movelinetwoLable.text = tipValue; // 收盘价
//    CGFloat twoLableX = movelinetwoLable.frame.origin.x;
//    // 如果滑动到了左半边则提示向右跳转
//    if ((mainboxView.frame.size.width - itemPointX) > mainboxView.frame.size.width/2) {
//        twoLableX = mainboxView.frame.size.width - movelinetwoLable.frame.size.width;
//    }else{
//        twoLableX = 0;
//    }
    movelinetwoLable.frame = CGRectMake(movelinetwoLable.frame.origin.x,itemPoint.y +10 - movelinetwoLable.frame.size.height/2 ,
                                        movelinetwoLable.frame.size.width, movelinetwoLable.frame.size.height);
    // 均线值显示
    MA5.text = [[NSString alloc] initWithFormat:@"MA5:%.2f",[[items objectAtIndex:6] floatValue]];
    [MA5 sizeToFit];
    MA10.text = [[NSString alloc] initWithFormat:@"MA10:%.2f",[[items objectAtIndex:7] floatValue]];
    [MA10 sizeToFit];
    MA10.frame = CGRectMake(MA5.frame.origin.x+MA5.frame.size.width+10, MA10.frame.origin.y, MA10.frame.size.width, MA10.frame.size.height);
    MA20.text = [[NSString alloc] initWithFormat:@"MA20:%.2f",[[items objectAtIndex:8] floatValue]];
    [MA20 sizeToFit];
    MA20.frame = CGRectMake(MA10.frame.origin.x+MA10.frame.size.width+10, MA20.frame.origin.y, MA20.frame.size.width, MA20.frame.size.height);
    
    NSString *DMA0 = @"";
    NSString *DMA5 = @"MA5";
    NSString *DMA10 = @"MA10";
    NSString *DMName = @"vol";
    NSString *itemValue0 = [DCommon numToUnits:[[items objectAtIndex:9] floatValue]/100] ;
    NSString *itemValue5 = [DCommon numToUnits:[[items objectAtIndex:10] floatValue]/100];
    NSString *itemValue10 = [DCommon numToUnits:[[items objectAtIndex:11] floatValue]/100];
    if (_page==2) {
        DMA0 = @"DIF:";
        DMA5 = @"DEA";
        DMA10 = @"M";
        DMName = @"MACD";
        itemValue0 = [DCommon stringChange:[items objectAtIndex:12]];
        itemValue5 = [DCommon stringChange:[items objectAtIndex:13]];
        itemValue10 = [DCommon stringChange:[items objectAtIndex:14]];
    }
    if (_page==3) {
        DMA0 = @"K:";
        DMA5 = @"D";
        DMA10 = @"J";
        DMName = @"KDJ";
        itemValue0 =  [DCommon stringChange:[items objectAtIndex:15]];
        itemValue5 = [DCommon stringChange:[items objectAtIndex:16]];
        itemValue10 = [DCommon stringChange:[items objectAtIndex:17]];
    }
    // 成交量均线值显示
    volLb.text = [[NSString alloc] initWithFormat:@"%@%@",DMA0,itemValue0];
    [volLb sizeToFit];
    volMA5.text = [[NSString alloc] initWithFormat:@"%@:%@",DMA5,itemValue5];
    [volMA5 sizeToFit];
    volMA5.frame = CGRectMake(volLb.frame.origin.x+volLb.frame.size.width+10, volMA5.frame.origin.y, volMA5.frame.size.width, volMA5.frame.size.height);
    volMA10.text = [[NSString alloc] initWithFormat:@"%@:%@",DMA10,itemValue10];
    [volMA10 sizeToFit];
    volMA10.frame = CGRectMake(volMA5.frame.origin.x+volMA5.frame.size.width+10, volMA10.frame.origin.y, volMA10.frame.size.width, volMA10.frame.size.height);
    // 指标按钮
    [indexButton setTitle:DMName forState:UIControlStateNormal];
    // 通知block
    // 回调block
    if (self.pressDownBlock) {
        self.pressDownBlock([items lastObject]);
    }
    items = nil;
}

#pragma mark 点击指标选择按钮
-(void)clickIndexButtonAction:(UIButton*)button{
    NSLog(@"---DFM---点击指标类型选择框");
    if (_pickerView) {
        [_pickerView removeAllSubviews];
        [_pickerView removeFromSuperview];
        _pickerView = nil;
    }
    // 添加指标选择器
    if (!_pickerView) {
        KLineViewController *kview = (KLineViewController*)self.parent;
        CGRect screenFrame = [[UIScreen mainScreen] bounds] ;
        CGFloat w = 280;
        CGFloat h = 240;
        CGFloat x = (screenFrame.size.width-w)/2;
        CGFloat y = (screenFrame.size.height-h)/2;
        // **********************************
        // 如果横屏
        // **********************************
        if (kview.isHorizontal) {
            x = (screenFrame.size.height-w)/2;
            y = (screenFrame.size.width-h)/2;
        }
        _pickerView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _pickerView.backgroundColor = UIColorFromRGB(0xCCCCCC);
        _pickerView.layer.borderWidth = 5;
        _pickerView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
        _pickerView.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
        _pickerView.layer.shadowOffset = CGSizeMake(3, 3);
        _pickerView.layer.shadowOpacity = 0.8;
        _pickerView.layer.shadowRadius = 5;
        [kview.view addSubview:_pickerView];
        kview = nil;
        // 添加选项框
        UIPickerView *picker = [[UIPickerView alloc] init];
        x = 0;
        y = 0;
        picker.frame = CGRectMake(x, y, w, 20);
        picker.backgroundColor = UIColorFromRGB(0xFFFFFF);
        picker.delegate = self;
        picker.dataSource = self;
        [picker showsSelectionIndicator];
        [_pickerView addSubview:picker];
        _picker = picker;
        // 添加确定按钮
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x+5, picker.frame.size.height+5, w-10, 30)];
        [bt setTitle:@"确定" forState:UIControlStateNormal];
        [bt addTarget:self action:@selector(clickSureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        bt.backgroundColor = UIColorFromRGB(0x000000);
        [_pickerView addSubview:bt];
        
        // 添加取消按钮
        UIButton *exitbt = [[UIButton alloc] initWithFrame:CGRectMake(x+5, bt.frame.size.height+bt.frame.origin.y+5, (w-20)/2, 30)];
        [exitbt setTitle:@"取消" forState:UIControlStateNormal];
        [exitbt addTarget:self action:@selector(clickExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        exitbt.backgroundColor = UIColorFromRGB(0x666666);
        [_pickerView addSubview:exitbt];
        
        // 添加恢复默认按钮
        UIButton *backbt = [[UIButton alloc] initWithFrame:CGRectMake(15 + exitbt.frame.size.width, exitbt.frame.origin.y, (w-20)/2, 30)];
        [backbt setTitle:@"恢复默认" forState:UIControlStateNormal];
        backbt.backgroundColor = UIColorFromRGB(0x666666);
        [backbt addTarget:self action:@selector(clickBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerView addSubview:backbt];
        backbt = nil;
        exitbt = nil;
        bt = nil;
        picker = nil;
        // 默认选择指标
        [_picker selectRow:(_page-1) inComponent:0 animated:NO];
    }
}
#pragma mark 移除选项框
-(void)removePickerView{
    [_pickerView removeFromSuperview];
    [_pickerView removeAllSubviews];
    _pickerView = nil;
}
#pragma mark 点击指标选项框确定按钮
-(void)clickSureButtonAction:(UIButton*)button{
    // 移除视图
    [self removePickerView];
    // 当前选择的行
    NSInteger row =[_picker selectedRowInComponent:0];
    // 得到选择的值
    NSString *selected = [_pickerArray objectAtIndex:row];
    // 设置指标名称
    [indexButton setTitle:selected forState:UIControlStateNormal];
    // 当前页码
    _page = row+1;
    // 指标视图滚动
    [_indexViews setContentOffset:CGPointMake(row*_indexViews.frame.size.width, 0) animated:YES];
}

#pragma mark 点击指标选项框取消按钮
-(void)clickExitButtonAction:(UIButton*)button{
    // 移除视图
    [self removePickerView];
}

#pragma mark 点击指标选项框恢复默认按钮
-(void)clickBackButtonAction:(UIButton*)button{
    // 默认选择第一项
    [_picker selectRow:0 inComponent:0 animated:YES];
}


#pragma mark -------------------------------视图排版-------------------------------
#pragma mark 画框框和平均线
-(void)drawBox{
    
    // 画个k线图的框框
    if (mainboxView==nil) {
        mainboxView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-self.xWidth, 10, self.xWidth, self.yHeight)];
        mainboxView.backgroundColor = ClearColor;
        mainboxView.layer.borderColor = [UIColor colorWithHexString:@"#808080" withAlpha:1].CGColor;
        mainboxView.layer.borderWidth = 0.5;
        mainboxView.userInteractionEnabled = YES;
        [self addSubview:mainboxView];
        // 添加手指捏合手势，放大或缩小k线图
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(touchBoxAction:)];
        [mainboxView addGestureRecognizer:pinchGesture];
        // 长按手势
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        [longPressGestureRecognizer setMinimumPressDuration:0.3f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        [mainboxView addGestureRecognizer:longPressGestureRecognizer];
        
    }
    if (!_indexViews) {
        _indexViews = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width-self.xWidth,mainboxView.frame.origin.y+mainboxView.frame.size.height+20, self.xWidth, self.bottomBoxHeight)];
        _indexViews.backgroundColor = ClearColor;
        _indexViews.layer.borderColor = [UIColor colorWithHexString:@"#808080" withAlpha:1].CGColor;
        _indexViews.layer.borderWidth = 0.5;
        _indexViews.contentSize = CGSizeMake(self.xWidth*_pageCount, self.bottomBoxHeight);
        _indexViews.showsHorizontalScrollIndicator = NO;
        _indexViews.showsVerticalScrollIndicator = NO;
        _indexViews.pagingEnabled = YES;
        _indexViews.scrollEnabled = YES;
        _indexViews.bounces = NO;// 不反弹
        _indexViews.delegate = self;
        [self addSubview:_indexViews];
        // 更新主视图的高度
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _indexViews.frame.size.height+_indexViews.frame.origin.y+20);
    }
    // 画个成交量的框框
    if (bottomBoxView==nil) {
        bottomBoxView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.xWidth, self.bottomBoxHeight)];
        bottomBoxView.backgroundColor = ClearColor;
        [_indexViews addSubview:bottomBoxView];
    }
    // 画个MACD
    if (_MACDViews==nil) {
        _MACDViews = [[UIView alloc] initWithFrame:CGRectMake(self.xWidth,0, self.xWidth, self.bottomBoxHeight)];
        _MACDViews.backgroundColor = ClearColor;
        [_indexViews addSubview:_MACDViews];
    }
    // 画个KDJ
    if (_KDJViews==nil) {
        _KDJViews = [[UIView alloc] initWithFrame:CGRectMake(self.xWidth*2,0, self.xWidth, self.bottomBoxHeight)];
        _KDJViews.backgroundColor = ClearColor;
        [_indexViews addSubview:_KDJViews];
    }
    // 把显示开始结束日期放在成交量的底部左右两侧
    // 显示开始日期控件
    if (startDateLab==nil) {
        startDateLab = [[UILabel alloc] initWithFrame:CGRectMake(_indexViews.frame.origin.x
                                                                 , _indexViews.frame.origin.y+_indexViews.frame.size.height
                                                                 , 70, 15)];
        startDateLab.font = self.font;
        startDateLab.text = @"--";
        startDateLab.textColor = UIColorFromRGB(0x808080);
        startDateLab.backgroundColor = [UIColor clearColor];
        [self addSubview:startDateLab];
    }
    // 显示结束日期控件
    if (endDateLab==nil) {
        endDateLab = [[UILabel alloc] initWithFrame:CGRectMake(mainboxView.frame.size.width-33
                                                               , startDateLab.frame.origin.y
                                                               , 70, 15)];
        endDateLab.font = self.font;
        endDateLab.text = @"--";
        endDateLab.textColor = UIColorFromRGB(0x808080);
        endDateLab.backgroundColor = [UIColor clearColor];
        endDateLab.textAlignment = NSTextAlignmentRight;
        [self addSubview:endDateLab];
    }
    // 显示成交量最大值
    if (volMaxValueLab==nil) {
        volMaxValueLab = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   mainboxView.frame.size.height+mainboxView.frame.origin.x-10
                                                                   , self.frame.size.width-mainboxView.frame.size.width-2,
                                                                   self.font.lineHeight)];
        volMaxValueLab.font = self.font;
        volMaxValueLab.text = @"--";
        volMaxValueLab.textColor = UIColorFromRGB(0x808080);
        volMaxValueLab.backgroundColor = [UIColor clearColor];
        volMaxValueLab.textAlignment = NSTextAlignmentRight;
        [self addSubview:volMaxValueLab];
    }
    // 添加平均线值显示
    CGRect mainFrame = mainboxView.frame;
    CGFloat MY = -3;
    // MA5 均线价格显示控件
    if (MA5==nil) {
        MA5 = [[UILabel alloc] initWithFrame:CGRectMake(mainFrame.origin.x, MY, 30, 15)];
        MA5.backgroundColor = [UIColor clearColor];
        MA5.font = MAFont;
        MA5.text = @"MA5:--";
        MA5.textColor = MA5Color;
        [MA5 sizeToFit];
        [self addSubview:MA5];
    }
    // MA10 均线价格显示控件
    if (MA10==nil) {
        MA10 = [[UILabel alloc] initWithFrame:CGRectMake(MA5.frame.origin.x +MA5.frame.size.width +10, MY, 30, 15)];
        MA10.backgroundColor = [UIColor clearColor];
        MA10.font = MAFont;
        MA10.text = @"MA10:--";
        MA10.textColor = MA10Color;
        [MA10 sizeToFit];
        [self addSubview:MA10];
    }
    // MA20 均线价格显示控件
    if (MA20==nil) {
        MA20 = [[UILabel alloc] initWithFrame:CGRectMake(MA10.frame.origin.x +MA10.frame.size.width +10, MY, 30, 15)];
        MA20.backgroundColor = [UIColor clearColor];
        MA20.font = MAFont;
        MA20.text = @"MA20:--";
        MA20.textColor = MA20Color;
        [MA20 sizeToFit];
        [self addSubview:MA20];
    }
    CGRect volFrame = _indexViews.frame;
    CGFloat VY = volFrame.origin.y-13;
    CGFloat VX = mainFrame.origin.x+45;
    // 当前成交量显示控件
    if (volLb==nil) {
        volLb = [[UILabel alloc] initWithFrame:CGRectMake(VX, VY, 30, 15)];
        volLb.backgroundColor = [UIColor clearColor];
        volLb.font = MAFont;
        volLb.text = @"--";
        volLb.textColor = MA5Color;
        [volLb sizeToFit];
        [self addSubview:volLb];
    }
    // 成交量 MA5 均线价格显示控件
    if (volMA5==nil) {
        volMA5 = [[UILabel alloc] initWithFrame:CGRectMake(volLb.frame.origin.x +volLb.frame.size.width +10, VY, 30, 15)];
        volMA5.backgroundColor = [UIColor clearColor];
        volMA5.font = MAFont;
        volMA5.text = @"MA5:--";
        volMA5.textColor = MA10Color;
        [volMA5 sizeToFit];
        [self addSubview:volMA5];
    }
    // 成交量 MA10 均线价格显示控件
    if (volMA10==nil) {
        volMA10 = [[UILabel alloc] initWithFrame:CGRectMake(volMA5.frame.origin.x +volMA5.frame.size.width +10, VY, 30, 15)];
        volMA10.backgroundColor = [UIColor clearColor];
        volMA10.font = MAFont;
        volMA10.text = @"MA10:--";
        volMA10.textColor = MA20Color;
        [volMA10 sizeToFit];
        [self addSubview:volMA10];
    }
    
    // 添加指标选择按钮
    if (!indexButton) {
        indexButton = [[UIButton alloc] initWithFrame:CGRectMake(mainFrame.origin.x, VY-4, 40, 15)];
        [indexButton setTitle:@"VOL" forState:UIControlStateNormal];
        indexButton.layer.cornerRadius = 3;
        indexButton.titleLabel.font = MAFont;
        indexButton.backgroundColor = kBrownColor;
        [indexButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [indexButton addTarget:self action:@selector(clickIndexButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:indexButton];
    }
    
    if (!isUpdate) {
        // 分割线
        CGFloat padRealValue = mainboxView.frame.size.height / 6;
        for (int i = 0; i<7; i++) {
            CGFloat y = mainboxView.frame.size.height-padRealValue * i;
            kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
            line.color = UIColorFromRGB(0x808080);
            //line.lineWidth = 0.5;
            line.isDash = YES;
            line.startPoint = CGPointMake(0, y);
            line.endPoint = CGPointMake(mainboxView.frame.size.width, y);
            [mainboxView addSubview:line];
        }
    }
}

#pragma mark 更新界面等信息
-(void)updateNib{
    NSLog(@"block");
    if (movelineone==Nil) {
        movelineone = [[UIView alloc] initWithFrame:CGRectMake(0,mainboxView.frame.origin.y, 0.5,
                                                               _indexViews.frame.size.height+_indexViews.frame.origin.y)];
        movelineone.backgroundColor = UIColorFromRGB(0x808080);
        [self addSubview:movelineone];
        movelineone.hidden = YES;
    }
    if (movelinetwo==Nil) {
        movelinetwo = [[UIView alloc] initWithFrame:CGRectMake(mainboxView.frame.origin.x,mainboxView.frame.origin.y, mainboxView.frame.size.width,0.5)];
        movelinetwo.backgroundColor = UIColorFromRGB(0x808080);
        movelinetwo.hidden = YES;
        [self addSubview:movelinetwo];
    }
    if (movelineoneLable==Nil) {
        CGRect oneFrame = movelineone.frame;
        oneFrame.size = CGSizeMake(60, 16);
        movelineoneLable = [[UILabel alloc] initWithFrame:oneFrame];
        movelineoneLable.font = self.font;
        movelineoneLable.layer.cornerRadius = 6;
        movelineoneLable.layer.backgroundColor = UIColorFromRGB(0x808080).CGColor;
        movelineoneLable.textColor = [UIColor blackColor];
        movelineoneLable.textAlignment = NSTextAlignmentCenter;
        //movelineoneLable.alpha = 0.8;
        movelineoneLable.hidden = YES;
        [self addSubview:movelineoneLable];
    }
    if (movelinetwoLable==Nil) {
        CGRect oneFrame = movelinetwo.frame;
        oneFrame.size = CGSizeMake(40, 12);
        oneFrame.origin = CGPointMake(movelinetwo.frame.origin.x-oneFrame.size.width, movelinetwo.frame.origin.y);
        movelinetwoLable = [[UILabel alloc] initWithFrame:oneFrame];
        movelinetwoLable.font = self.font;
        movelinetwoLable.layer.cornerRadius = 6;
        movelinetwoLable.layer.backgroundColor = UIColorFromRGB(0x808080).CGColor;
        movelinetwoLable.textColor = [UIColor blackColor];
        movelinetwoLable.textAlignment = NSTextAlignmentCenter;
        //movelinetwoLable.alpha = 0.8;
        movelinetwoLable.hidden = YES;
        [self addSubview:movelinetwoLable];
    }
    movelineone.frame = CGRectMake(touchViewPoint.x,movelineone.frame.origin.y, 0.5,movelineone.frame.size.height);
    movelinetwo.frame = CGRectMake(movelinetwo.frame.origin.x,touchViewPoint.y, mainboxView.frame.size.width,0.5);
    CGRect oneFrame = movelineone.frame;
    oneFrame.size = CGSizeMake(65, 14);
    movelineoneLable.frame = oneFrame;
    CGRect towFrame = movelinetwo.frame;
    towFrame.size = CGSizeMake(45, 14);
    towFrame.origin = CGPointMake(movelinetwo.frame.origin.x-towFrame.size.width, movelinetwo.frame.origin.y);
    movelinetwoLable.frame = towFrame;
    
    movelineone.hidden = NO;
    movelinetwo.hidden = NO;
    movelineoneLable.hidden = NO;
    movelinetwoLable.hidden = NO;
    [self isKPointWithPoint:touchViewPoint];
}

#pragma mark ---------------------UIScrollView代理实现------------------------
#pragma mark 滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 得到每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页
    int x = (int)scrollView.contentOffset.x;
    int w = (int)pageWidth;
    if (x % w == 0) {
        int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSLog(@"---DFM---正在滚动%d x=%f",currentPage,scrollView.contentOffset.x);
        _page = currentPage+1;
        kLineModel *item = [self.data lastObject];
        [self updateMALableValue:item];
        item = nil;
    }
}
#pragma mark 停止滚动
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"---DFM---停止滚动");
}

#pragma mark ------------------------UIPickerView的代理实现----------------------------
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_pickerArray count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_pickerArray objectAtIndex:row];
}

@end
