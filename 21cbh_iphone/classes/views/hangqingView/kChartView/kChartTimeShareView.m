//
//  kChartTimeShareView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kChartTimeShareView.h"
#import "kLine.h"
#import "timeShareChartModel.h"
#import "UIColor+helper.h"

@implementation kChartTimeParamModel

@end

@interface kChartTimeShareView(){
    UIView *mainboxView; // k线主视图
    UIView *movelineone; // 手指按下后显示的两根白色十字线
    UIView *movelinetwo;
    UIView *dotView;// 十字线的圆点
    UILabel *movelineoneLable;
    UILabel *movelinetwoLable;
    NSMutableArray *pointArray; // k线所有坐标数组
    UILabel *startDateLab;
    UILabel *endDateLab;
    
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

    UIColor *TimeColor;// 分时颜色
    UIColor *MAColor;// MAn颜色
    UIColor *titleColor; // 文字颜色
    CGFloat bili;// 按比例分割的Y轴每格的比例高度
    NSArray *_times;// 时间段数组
    UIView *_timeViews;// 时间段显示视图
    
    NSOperationQueue *_queue;// 线程
    
    BOOL isDrawed;// 是否画过了
    BOOL isUpdate;
    BOOL isUpdateFinish;
    BOOL isPinch;
    BOOL isC ;
    int leftPadding;// 画图时左边开始的间隔 用来修正画图缺陷
}


@end

@implementation kChartTimeShareView

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
    [_queue cancelAllOperations];
    _queue = nil;
    if (lineArray) {
        [lineArray removeAllObjects];
    }
    if (lineOldArray) {
        [(NSMutableArray*)lineOldArray removeAllObjects];
    }
    if (pointArray) {
        [pointArray removeAllObjects];
    }
    [self removeOldKLine];
    [self removeAllSubviews];
    [mainboxView removeGestureRecognizer:pinchGesture];
    [mainboxView removeGestureRecognizer:longPressGestureRecognizer];
    [mainboxView removeGestureRecognizer:chartTapGesture];
    pinchGesture = nil;
    longPressGestureRecognizer = nil;
    chartTapGesture = nil;
    if (self.data) {
        [self.data removeAllObjects];
    }
    self.data = nil;
    _pankou = nil;
    _times = nil;
    _timeViews = nil;
    _finishUpdateBlock = nil;
    _pressDownBlock = nil;
    _pressUpBlock = nil;
    _finishBlock = nil;
    _chartTapBlocks = nil;
    
    mainboxView = nil;
    movelineone = nil;
    movelinetwo = nil;
    movelinetwoLable = nil;
    movelineoneLable = nil;
    pointArray = nil;
    lineArray = nil;
    lineOldArray = nil;
}

-(void)didReceiveMemoryWarning{

}

#pragma mark ---------------------------自定义方法------------------------------
#pragma mark 初始化参数
-(void)initParam{
//    if (self.data.count>0) {
//        [self.data removeAllObjects];
//    }
//    self.data = nil;
    self.xWidth = 280; // k线图宽度
    self.yHeight = 150; // k线图高度
    self.bottomBoxHeight = 50; // 底部成交量图的高度
    self.kLineWidth = 1;// k线实体的宽度
    self.kLinePadding = 0; // k实体的间隔
    self.font = [UIFont fontWithName:kFontName size:10];
    self.pankou = [[NSMutableArray alloc] init];
    self.dishs = [[NSMutableArray alloc] init];
    leftPadding = 0;
    isUpdate = NO;
    isUpdateFinish = YES;
    isPinch = NO;
    lineArray = [[NSMutableArray alloc] init];
    lineOldArray = [[NSMutableArray alloc] init];
    pointArray = [[NSMutableArray alloc] init];
    
    maxValue = 0;
    minValue = CGFLOAT_MAX;
    volMaxValue = 0;
    volMinValue = CGFLOAT_MAX;
    TimeColor = UIColorFromRGB(0x0033CC) ;
    MAColor = UIColorFromRGB(0xffff00) ;
    titleColor = UIColorFromRGB(0x808080);
    
    _queue = [[NSOperationQueue alloc] init];
    // 定义块
    self.finishUpdateBlock = ^(id self){
        [self updateNib];
    };
}

#pragma mark 启动
-(void)startWith:(kChartTimeParamModel *)model{

    if (model) {
        if (self.data) {
            if ([[self.data class] isSubclassOfClass:[NSMutableArray class]]) {
                [self.data removeAllObjects];
            }
            
        }
        self.xWidth = model.width;
        self.yHeight = model.height;
        self.kLinePadding = model.padding;
        self.kLineWidth = model.kLineWidth;
        self.kCount = model.count;
        self.days = model.days;
    }
    
    self.backgroundColor = ClearColor;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.yHeight);
    [self drawBox];
    [_queue addOperationWithBlock:^{
        [self drawLine];
    }];
    
}
#pragma mark 更新
-(void)updateWith:(kChartTimeParamModel *)model{

    if (model) {
        if (self.data) {
            if ([[self.data class] isSubclassOfClass:[NSMutableArray class]]) {
                [self.data removeAllObjects];
            }
            
        }
        self.days = model.days;
        self.data = [NSMutableArray arrayWithArray:model.data.copy];
        self.heightPrice = model.heightPrice;
        self.closePrice = model.closePrice;
        self.timeFrame = model.timeFrame;
        if (model.data) {
            if ([[model.data class] isSubclassOfClass:[NSMutableArray class]]) {
                [model.data removeAllObjects];
            }
        }
    }
    model = nil;
    if (self.timeFrame.length>0) {
        _times = [self.timeFrame componentsSeparatedByString:@","];
    }
    isUpdate = YES;
    
    
    
    [_queue addOperationWithBlock:^{
        [self drawLine];
    }];
    
}
#pragma mark 私有更新
-(void)updateSelf{
    if (isUpdateFinish) {
        isUpdateFinish = NO;
        isUpdate = YES;
        self.data = nil;
        pointArray = nil;
        [_queue addOperationWithBlock:^{
            [self drawLine];
        }];
    }
}

#pragma mark 画k线
-(void)drawLine{
    self.chartState = chartTimeStateBegin;// 开始
    if (self.data.count>0 && !isDrawed) {
        isDrawed = YES;
        self.chartState = chartTimeStateRuning; // 正在
        
        NSLog(@"[NSThread currentThread]===%@",[NSThread currentThread]);
        
            // 换算一下数据
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dataBundle];
            // 给盘口数据
            [self pushPankou];
        });
//            [self dataBundle];
//            // 给盘口数据
//            [self pushPankou];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新界面
                // 开始画K线图
                [self drawBoxWithKline];
                // 清除旧的k线
                [self removeOldKLine];
                lineOldArray = [NSMutableArray arrayWithArray:lineArray.copy];
                if (_finishUpdateBlock && isPinch) {
                    _finishUpdateBlock(self);
                }
                isUpdateFinish = YES;
                isDrawed = NO;
                // 处理完成
                if (self.finishBlock) {
                    // 点击手势
                    if (!chartTapGesture) {
                        chartTapGesture = [[UITapGestureRecognizer alloc] init];
                        chartTapGesture.numberOfTapsRequired = 1;
                        chartTapGesture.numberOfTouchesRequired = 1;
                        [chartTapGesture addTarget:self action:@selector(chartTapGestureAction:)];
                        [mainboxView addGestureRecognizer:chartTapGesture];
                    }
                    self.finishBlock(self);
                    
                }
                self.chartState = chartTimeStateEnd;// 结束
               
            });
    }else{
        self.chartState = chartTimeStateEnd; // 结束
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
        if (lineArray) {
            [lineArray removeAllObjects];
        }
        NSMutableArray *newData = [[NSMutableArray alloc] init];
        CGFloat MACount = 0; // 用于计算大盘的即时成交价的均线值  分时图中的均价线＝已经开盘的所有价格的和  /    已开盘分钟数
        
        for (int i=self.data.count-1;i>=0;i--) {
            if (i>self.data.count) {
                return;
            }
            [newData addObject:[self.data objectAtIndex:i]];
            timeShareChartModel *item = (timeShareChartModel*)[self.data objectAtIndex:i];
            // 9点半的时候清0
            if (i==self.data.count-1) {
                item.volume = @"0";
            }
           // NSLog(@"item.transationPrice==%f",[item.transationPrice floatValue]);
            
            // 当前值
            
            CGFloat currentValue =[item.transationPrice floatValue];
            if (![item isKindOfClass:[timeShareChartModel class]]) {
                return;
            }
            
            if (currentValue<=0) {
                currentValue = self.closePrice;
            }
            MACount += currentValue; // 已经开票的价格的和
            CGFloat MAn = MACount / ([newData indexOfObject:item]+1); // 均线值
            //item.MAn = [NSString stringWithFormat:@"%f",MAn];
            [item setMAn:[NSString stringWithFormat:@"%f",MAn]];

            
            // y轴最大值
            CGFloat curentMaxValue = [item.transationPrice floatValue];
            if (curentMaxValue>maxValue) {
                maxValue = curentMaxValue;
            }
            // y轴最小值
            CGFloat curentMinValue = [item.transationPrice floatValue];
            if (curentMinValue<minValue && curentMinValue>0) {
                minValue = curentMinValue;
            }
            // 成交量最大值
            CGFloat curentValue = [item.volume floatValue];
            if (curentValue>volMaxValue) {
                volMaxValue = curentValue;
            }
            // 成交量最小值
            if (curentValue<volMinValue && curentMinValue>0) {
                volMinValue = curentValue;
            }
        }
        self.data = newData;
    }
}
#pragma mark 给盘口提供数据参考
-(void)pushPankou{
    if (self.data) {
        // 资金流入   资金流出_
        int hugeOrder = 0;
        int hugeOrder_ = 0;
        int bigOrder = 0;
        int bigOrder_ = 0;
        int midOrder = 0;
        int midOrder_ = 0;
        int smallOrder = 0;
        int smallOrder_ = 0;
        CGFloat preValue = self.closePrice;
        CGFloat preVolumePrice = 0;
        CGFloat innerDish = 0;// 内盘
        CGFloat outerDish = 0;// 外盘
        for (int i=0; i<self.data.count; i++) {
            // 处理每个交易
            timeShareChartModel *item = (timeShareChartModel*)[self.data objectAtIndex:i];
            CGFloat volPrice = [item.volumePrice floatValue];
            volPrice = volPrice - preVolumePrice;
            // 上一个成交总价
            preVolumePrice = [item.volumePrice floatValue];
            
            CGFloat volume = [item.volume floatValue];
            //NSLog(@"---DFM---%f========成交量%f",volPrice,volume);
            // 计算流入
            if ([item.transationPrice floatValue]>=preValue) {
                innerDish += volume;
                // 超大单
                if (volume>=100000) {
                    hugeOrder += volPrice;
                }
                // 大单
                if (volume>=50000 && volume<100000) {
                    bigOrder += volPrice;
                }
                // 中单
                if (volume>=5000 && volume<50000) {
                    midOrder += volPrice;
                }
                // 小单
                if (volume>=1 && volume<5000) {
                    smallOrder += volPrice;
                }
            }else{
                outerDish += volume;
                // 超大单
                if (volume>=100000) {
                    hugeOrder_ += volPrice;
                }
                // 大单
                if (volume>=50000 && volume<100000) {
                    bigOrder_ += volPrice;
                }
                // 中单
                if (volume>=5000 && volume<50000) {
                    midOrder_ += volPrice;
                }
                // 小单
                if (volume>=1 && volume<5000) {
                    smallOrder_ += volPrice;
                }
            }
            
            preValue = [item.transationPrice floatValue];
            
        }
        // 买盘 - 卖盘 = 正值为 净流入  负值为净流出
        [self.pankou addObject:[NSNumber numberWithInt:(int)(hugeOrder-hugeOrder_)]];
        [self.pankou addObject:[NSNumber numberWithInt:(int)(bigOrder-bigOrder_)]];
        [self.pankou addObject:[NSNumber numberWithInt:(int)(midOrder-midOrder_)]];
        [self.pankou addObject:[NSNumber numberWithInt:(int)(smallOrder-smallOrder_)]];
        // 内外盘
        [self.dishs removeAllObjects];
        [self.dishs addObject:[NSNumber numberWithFloat:innerDish]];
        [self.dishs addObject:[NSNumber numberWithFloat:outerDish]];
    }
}

#pragma mark 显示时间段信息
-(void)showTimeFrame{
    // 显示时间段信息
    if (_timeViews && _times) {
        [_timeViews removeAllSubviews];
        if (self.days==5) {
            // 显示五天的值
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat w = mainboxView.frame.size.width/5;
            CGFloat h = 20;
            for (int i=0; i<5; i++) {
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
                int index = _times.count-1-i;
                if (index <_times.count) {
                    l.text = [_times objectAtIndex:index];
                }
                l.textAlignment = NSTextAlignmentCenter;
                l.font = self.font;
                l.backgroundColor = ClearColor;
                l.textColor = UIColorFromRGB(0x808080);
                [_timeViews addSubview:l];
                l = nil;
                x +=w;
            }
        }else{
            // 显示当天分时图的时间段
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat w = mainboxView.frame.size.width/4;
            CGFloat h = 20;
            for (int i=0; i<4; i++) {
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
                l.text = [_times objectAtIndex:i];
                l.textAlignment = NSTextAlignmentLeft;
                if (i==1 || i==3) {
                    l.textAlignment = NSTextAlignmentRight;
                }
                l.font = self.font;
                l.backgroundColor = ClearColor;
                l.textColor = UIColorFromRGB(0x808080);
                if (i==1) {
                    l.text = [[NSString alloc] initWithFormat:@"%@/",l.text];
                }
                [_timeViews addSubview:l];
                l = nil;
                x +=w;
            }
        }
    }
}


#pragma mark 在框框里画k线
-(void)drawBoxWithKline{
    // 分割线线
    // 最高坐标处理
    if (self.heightPrice>maxValue) {
        maxValue = self.heightPrice;
    }
    // 最低坐标处理
    // 默认最低坐标为最高坐标的反方向值
    bili = (maxValue - self.closePrice) / 2; // 最高值跟昨日收盘价的比例，得到y轴每份的比例
    if (maxValue==0) {
        bili = 0.01;
    }
    // 计算最低值
    CGFloat lowPrice = self.closePrice - 2*bili; // 得到最低值
    // 如果及时成交价中的最低值比计算出的最低值还要低，则要反过来处理最高值
    if (minValue<lowPrice) {
        lowPrice = minValue;
        bili = (self.closePrice - minValue) / 2; // 得到新的比例
    }
    self.heightPrice = self.closePrice + 2*bili ;// 重新计算最高值
    maxValue = self.heightPrice; // 总结最高值
    minValue = lowPrice; // 总结最低值
    
//    if (maxValue==0) {
//        maxValue = self.closePrice + 2*bili;
//        minValue = self.closePrice - 2*bili;
//    }
    
    CGFloat padValue = bili;
    CGFloat padRealValue = mainboxView.frame.size.height / 6;
    for (int i = 0; i<5; i++) {
        // 颜色
        UIColor *color = kGreenColor;
        if (i>2) {
            color = kRedColor;
        }
        CGFloat y = mainboxView.frame.size.height-padRealValue * (i+2);
        // lable
        CGFloat nY = y - 30/2;
        if (i==0) {
            nY = y - 30/1.5;
        }
        if (i==4) {
            nY = y - 30/3;
        }
        NSString *t = [[NSString alloc] initWithFormat:@"%.2f",padValue*i+minValue];
        NSString *b = [[NSString alloc] initWithFormat:@"%.2f%%",fabsf(padValue*i+minValue-self.closePrice)/self.closePrice*100];
        // 中间为收盘价
        if (i==2) {
            t = [[NSString alloc] initWithFormat:@"%.2f",self.closePrice];
            b = [[NSString alloc] initWithFormat:@"0.00%%"];
            color = titleColor;
        }
        // 比值
        UILabel *leftTag = [[UILabel alloc] initWithFrame:CGRectMake(3, nY, 100, 30)];
        leftTag.text = t;
        leftTag.textColor = color;
        leftTag.font = self.font;
        leftTag.textAlignment = NSTextAlignmentLeft;
        leftTag.backgroundColor = ClearColor;
        [mainboxView addSubview:leftTag];
        [lineArray addObject:leftTag];
        leftTag = nil;
        
        // // 比率
        UILabel *rightTag = [[UILabel alloc] initWithFrame:CGRectMake(mainboxView.frame.size.width-103, nY, 100, 30)];
        rightTag.text = b;
        rightTag.textColor = color;
        rightTag.font = self.font;
        rightTag.textAlignment = NSTextAlignmentRight;
        rightTag.backgroundColor = ClearColor;
        [mainboxView addSubview:rightTag];
        [lineArray addObject:rightTag];
        rightTag = nil;
        
    }
    // 显示时间段
    [self showTimeFrame];
    //NSLog(@"---DFM---self.kLineWidth:%f,self.kLinePadding:%f,count=%d",self.kLineWidth,self.kLinePadding,self.data.count);
    // 开始画分时线 0=成交价 1=成交均价
    [self drawMAWithIndex:0 andColor:TimeColor];
    if (self.days!=5) {
        [self drawMAWithIndex:1 andColor:MAColor];
    }
    if (self.heightPrice>0 && volMaxValue>0){
        // 开始画连成交量
        NSArray *voltempArray = [self changeVolumePointWithData:self.data]; // 换算成实际成交量坐标数组
        kLine *volline = [[kLine alloc] initWithFrame:CGRectMake(0, mainboxView.frame.origin.y+padRealValue*4, mainboxView.frame.size.width, padRealValue*2)];
        volline.points = voltempArray;
        volline.lineWidth = self.kLineWidth<0.5?0.5:self.kLineWidth;
        volline.isTimeShare = YES;
        volline.isVol = YES;
        [mainboxView addSubview:volline];
        [lineArray addObject:volline];
    }
}


#pragma mark 画分时线和均线
-(void)drawMAWithIndex:(int)index andColor:(UIColor*)color{
    NSArray *tempArray = [self changePointWithData:self.data andType:index]; // 换算成实际坐标数组
    kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
    line.color = color;
    line.points = tempArray;
    line.lineWidth = 1;
    line.isTimeShare = YES;
    [mainboxView addSubview:line];
    [lineArray addObject:line];
}


#pragma mark -----------------------------数据换算-----------------------------------

#pragma mark 把分时数据换算成实际的点坐标数组
-(NSArray*)changePointWithData:(NSArray*)data andType:(int)type{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2; // 起始点坐标
    CGFloat padRealValue = (mainboxView.frame.size.height) / 6;
    for (timeShareChartModel *item in data) {
       
        CGFloat currentValue = [item.transationPrice floatValue];// 得到及时成交价
        if (type==1) {
            currentValue = [item.MAn floatValue]; // 均值
        }

        // 如果最高价为0并且 最大成交量为0 则股票为停牌状态
        if (volMaxValue==0) {
            currentValue = self.closePrice;
        }
        
        
        // 换算成实际的坐标
        CGFloat currentPointY = padRealValue*4 - ((currentValue - minValue) / (maxValue - minValue) * padRealValue*4)+0.5;
        
        
        //NSLog(@"---DFM---currentPointY=%f",currentPointY);
        CGPoint currentPoint =  CGPointMake(PointStartX, currentPointY); // 换算到当前的坐标值
        // 只添加一次
        if (type==0) {
            CGPoint lowPoint =  CGPointMake(PointStartX, 0); // 开盘价换算为实际坐标值
            CGPoint openPoint =  CGPointMake(PointStartX, 0); // 开盘价换算为实际坐标值
            CGPoint closePoint =  CGPointMake(PointStartX, currentPointY); // 收盘价换算为实际坐标值
            NSString *time = item.time==nil?@"":item.time;
//            if ([data indexOfObject:item]<self.category.count) {
//                [self.category objectAtIndex:[data indexOfObject:item]];
//            }
            //NSLog(@"---DFM---总数：%d,%d",self.category.count,data.count);
            NSArray *currentArray = [[NSArray alloc] initWithObjects:
                                     NSStringFromCGPoint(currentPoint),
                                     NSStringFromCGPoint(lowPoint),
                                     NSStringFromCGPoint(openPoint),
                                     NSStringFromCGPoint(closePoint),
                                     time, // 保存日期时间
                                     item.transationPrice, // 收盘价
                                     item.changeValue, // 涨跌额
                                     item.changeRate, // 涨跌幅
                                     item.volume, // 成交量
                                     item, // 保存整个模型
                                     nil];
            [pointArray addObject:currentArray];
            currentArray = nil;
        }
        [tempArray addObject:NSStringFromCGPoint(currentPoint)]; // 把坐标添加进新数组
        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
    }
    return tempArray;
}

//#pragma mark 把分时图成交量数据换算成实际的点坐标数组
//-(NSArray*)changeKPointWithData:(NSArray*)data{
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//    pointArray = [[NSMutableArray alloc] init];
//    CGFloat PointStartX = 0; // 起始点坐标
//    CGFloat padRealValue = mainboxView.frame.size.height / 6;
//    for (timeShareChartModel *item in data) {
//        CGFloat volValue = [item.volume floatValue];// 得到成交量
//        CGFloat yHeight = minValue - 0 ; // y的价格高度
//        CGFloat yViewHeight = padRealValue*2 ;// y的实际像素高度
//        // 换算成实际的坐标
//        CGFloat volPointY = yViewHeight * (1 - (volValue) / yHeight);
//        CGPoint volPoint =  CGPointMake(PointStartX, heightPointY); // 最高价换算为实际坐标值
//        // 实际坐标组装为数组
//        NSArray *currentArray = [[NSArray alloc] initWithObjects:
//                                 NSStringFromCGPoint(heightPoint),
//                                 NSStringFromCGPoint(lowPoint),
//                                 NSStringFromCGPoint(openPoint),
//                                 NSStringFromCGPoint(closePoint),
//                                 [self.category objectAtIndex:[data indexOfObject:item]], // 保存日期时间
//                                 item.closePrice, // 收盘价
//                                 item.MA5, // MA5
//                                 item.MA10, // MA10
//                                 item.MA20, // MA20
//                                 nil];
//        [tempArray addObject:currentArray]; // 把坐标添加进新数组
//        //[pointArray addObject:[NSNumber numberWithFloat:PointStartX]];
//        currentArray = Nil;
//        PointStartX += self.kLineWidth+self.kLinePadding; // 生成下一个点的x轴
//        
//        // 在成交量视图左右下方显示开始和结束日期
//        if ([data indexOfObject:item]==0) {
//            startDateLab.text = [self.category objectAtIndex:[data indexOfObject:item]];
//        }
//        if ([data indexOfObject:item]==data.count-1) {
//            endDateLab.text = [self.category objectAtIndex:[data indexOfObject:item]];
//        }
//    }
//    pointArray = tempArray;
//    return tempArray;
//}

#pragma mark 把股市数据换算成成交量的实际坐标数组
-(NSArray*)changeVolumePointWithData:(NSArray*)data{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = self.kLineWidth/2; // 起始点坐标
    CGFloat padRealValue = (mainboxView.frame.size.height) / 6;
    //NSLog(@"---DFM---最高值%f：最低值：%f",volMaxValue,volMinValue);
    
    for (timeShareChartModel *item in data) {
        CGFloat volumevalue = [item.volume floatValue];// 得到没份成交量
        CGFloat yHeight = volMaxValue - volMinValue ; // y的价格高度
        CGFloat yViewHeight = 2*padRealValue ;// y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY = yViewHeight * (1 - (volumevalue - volMinValue) / yHeight);
        CGPoint volumePoint =  CGPointMake(PointStartX, volumePointY); // 成交量换算为实际坐标值
        CGPoint volumePointStart = CGPointMake(PointStartX, yViewHeight);
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = 1;// 得到开盘价
        CGFloat closevalue = 2;// 得到收盘价
        NSString *changeValue = item.priceType;
        @try {
            if ([changeValue intValue]==-1) {
                closevalue = 0;
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }

        CGPoint openPoint =  CGPointMake(PointStartX, closevalue); // 开盘价换算为实际坐标值
        CGPoint closePoint =  CGPointMake(PointStartX, openvalue); // 收盘价换算为实际坐标值
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
    if (self.chartTapBlocks) {
        self.chartTapBlocks(self);
    }
}
#pragma mark 手指捏合动作
-(void)touchBoxAction:(UIPinchGestureRecognizer*)pGesture{
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
//        isUpdateFinish = YES;
//        //[self update];
//    }
}
#pragma mark 长按就开始生成十字线
-(void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)longResture{
    isPinch = YES;
    //NSLog(@"gestureRecognizerHandle%i",longResture.state);
    touchViewPoint = [longResture locationInView:mainboxView];
    // 手指长按开始时更新一遍
    if(longResture.state == UIGestureRecognizerStateBegan){
        [self updateNib];
    }
    // 手指移动时候开始显示十字线
    if (longResture.state == UIGestureRecognizerStateChanged) {
        [self isKPointWithPoint:touchViewPoint];
    }
    
    // 手指离开的时候移除十字线
    if (longResture.state == UIGestureRecognizerStateEnded) {
        if (self.pressUpBlock) {
            self.pressUpBlock(nil);
        }
        [self removeTipLine];
        isPinch = NO;
    }
}

#pragma mark 判断并在十字线上显示提示信息
-(void)isKPointWithPoint:(CGPoint)point{
    CGFloat itemPointX = 0;
    CGPoint itemPoint;
    NSArray *items;
    if (pointArray.count<=0) {
        [self removeTipLine];
        isPinch = NO;
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
    movelineone.frame = CGRectMake(itemPointX,movelineone.frame.origin.y, movelineone.frame.size.width, movelineone.frame.size.height);
    movelinetwo.frame = CGRectMake(movelinetwo.frame.origin.x,itemPoint.y, movelinetwo.frame.size.width, movelinetwo.frame.size.height);
    dotView.frame = CGRectMake(-1.8, itemPoint.y-1.8, 4, 4);
    // 垂直提示日期控件
    movelineoneLable.text = [items objectAtIndex:4]; // 日期
    CGFloat oneLableY = mainboxView.frame.size.height + mainboxView.frame.origin.y;
    CGFloat oneLableX = 0;
    if (itemPointX<movelineoneLable.frame.size.width/2) {
        oneLableX = movelineoneLable.frame.size.width/2 - itemPointX;
    }
    if ((mainboxView.frame.size.width - itemPointX)<movelineoneLable.frame.size.width/2) {
        oneLableX = -(movelineoneLable.frame.size.width/2 - (mainboxView.frame.size.width - itemPointX));
    }
    movelineoneLable.frame = CGRectMake(itemPointX - movelineoneLable.frame.size.width/2 + oneLableX, oneLableY,
                                        movelineoneLable.frame.size.width, movelineoneLable.frame.size.height);
    // 横向提示价格控件
    movelinetwoLable.text = [[NSString alloc] initWithFormat:@"%0.2f",[[items objectAtIndex:5] floatValue]]; // 收盘价
    CGFloat twoLableX = movelinetwoLable.frame.origin.x;
    // 如果滑动到了左半边则提示向右跳转
    if ((mainboxView.frame.size.width - itemPointX) > mainboxView.frame.size.width/2) {
        twoLableX = mainboxView.frame.size.width - movelinetwoLable.frame.size.width;
    }else{
        twoLableX = 0;
    }
    movelinetwoLable.frame = CGRectMake(twoLableX,itemPoint.y - movelinetwoLable.frame.size.height/2 ,
                                        movelinetwoLable.frame.size.width, movelinetwoLable.frame.size.height);
    [mainboxView bringSubviewToFront:movelinetwoLable];
    // 回调block
    if (self.pressDownBlock) {
        self.pressDownBlock([items lastObject]);
    }
}

#pragma mark -------------------------------视图排版-------------------------------
#pragma mark 画框框和平均线
-(void)drawBox{
    // 画个k线图的框框
    if (mainboxView==nil) {
        mainboxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.xWidth, self.yHeight)];
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
        [longPressGestureRecognizer setMinimumPressDuration:0.1f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        [mainboxView addGestureRecognizer:longPressGestureRecognizer];
        
        
    }
    
    // 把显示开始结束日期放在成交量的底部左右两侧
//    // 显示开始日期控件
//    if (startDateLab==nil) {
//        startDateLab = [[UILabel alloc] initWithFrame:CGRectMake(mainboxView.frame.origin.x ,
//                                                                 mainboxView.frame.size.height + mainboxView.frame.origin.y,
//                                                                 50, 15)];
//        startDateLab.font = self.font;
//        startDateLab.text = self.startDate;
//        startDateLab.textColor = [UIColor colorWithHexString:titleColor withAlpha:1];
//        startDateLab.backgroundColor = [UIColor clearColor];
//        [mainboxView addSubview:startDateLab];
//        
//    }
//    // 显示结束日期控件
//    if (endDateLab==nil) {
//        endDateLab = [[UILabel alloc] initWithFrame:CGRectMake(mainboxView.frame.size.width-50
//                                                               , startDateLab.frame.origin.y
//                                                               , 50, 15)];
//        endDateLab.font = self.font;
//        endDateLab.text = self.endDate;
//        endDateLab.textColor = [UIColor colorWithHexString:titleColor withAlpha:1];
//        endDateLab.backgroundColor = [UIColor clearColor];
//        endDateLab.textAlignment = NSTextAlignmentRight;
//        [mainboxView addSubview:endDateLab];
//    }
    // 时间段显示视图
    if (!_timeViews) {
        _timeViews = [[UIView alloc] initWithFrame:CGRectMake(mainboxView.frame.origin.x, mainboxView.frame.size.height, mainboxView.frame.size.width, 20)];
        _timeViews.backgroundColor = ClearColor;
        [mainboxView addSubview:_timeViews];
    }
    
    if (!isUpdate) {
        // 竖分割线 6条
        CGFloat padRealValue = mainboxView.frame.size.height / 6;
        for (int i = 0; i<7; i++) {
            CGFloat y = mainboxView.frame.size.height-padRealValue * i;
            kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
            line.color = UIColorFromRGB(0x808080);
            line.isDash = YES;
            line.startPoint = CGPointMake(0, y);
            line.endPoint = CGPointMake(mainboxView.frame.size.width, y);
            [mainboxView addSubview:line];
            line = nil;
        }
        // 横分割线 3条
        int lines = 5;
        if (self.days==5) {
            lines = 6;
        }
        padRealValue = mainboxView.frame.size.width / (lines-1);
        for (int i = 0; i<lines; i++) {
            CGFloat x = padRealValue * i;
            kLine *line = [[kLine alloc] initWithFrame:CGRectMake(0, 0, mainboxView.frame.size.width, mainboxView.frame.size.height)];
            line.color = UIColorFromRGB(0x808080);
            line.isDash = YES;
            line.startPoint = CGPointMake(x, 0);
            line.endPoint = CGPointMake(x, mainboxView.frame.size.height);
            [mainboxView addSubview:line];
            line = nil;
        }
    }
}

#pragma mark 更新界面等信息
-(void)updateNib{
    NSLog(@"block");
    if (movelineone==Nil) {
        movelineone = [[UIView alloc] initWithFrame:CGRectMake(0,0, 0.5,
                                                               mainboxView.frame.size.height)];
        movelineone.backgroundColor = UIColorFromRGB(0x808080);
        [mainboxView addSubview:movelineone];
        movelineone.hidden = YES;
        // 十字线的圆点
        if (dotView==nil) {
            dotView = [[UIView alloc] initWithFrame:CGRectMake(-1.8, 0, 4, 4)];
            dotView.layer.cornerRadius = 2;
            dotView.backgroundColor = UIColorFromRGB(0x808080);
            [movelineone addSubview:dotView];
        }
    }
    if (movelinetwo==Nil) {
        movelinetwo = [[UIView alloc] initWithFrame:CGRectMake(0,0, mainboxView.frame.size.width,0.5)];
        movelinetwo.backgroundColor = UIColorFromRGB(0x808080);
        movelinetwo.hidden = YES;
        [mainboxView addSubview:movelinetwo];
    }
    if (movelineoneLable==Nil) {
        CGRect oneFrame = movelineone.frame;
        oneFrame.size = CGSizeMake(30, 12);
        movelineoneLable = [[UILabel alloc] initWithFrame:oneFrame];
        movelineoneLable.font = self.font;
        movelineoneLable.layer.cornerRadius = 6;
        movelineoneLable.layer.backgroundColor = UIColorFromRGB(0x808080).CGColor;
        movelineoneLable.textColor = [UIColor blackColor];
        movelineoneLable.textAlignment = NSTextAlignmentCenter;
        //movelineoneLable.alpha = 0.8;
        movelineoneLable.hidden = YES;
        [mainboxView addSubview:movelineoneLable];
    }
    if (movelinetwoLable==Nil) {
        CGRect oneFrame = movelinetwo.frame;
        oneFrame.size = CGSizeMake(50, 12);
        movelinetwoLable = [[UILabel alloc] initWithFrame:oneFrame];
        movelinetwoLable.font = self.font;
        movelinetwoLable.layer.cornerRadius = 6;
        movelinetwoLable.layer.backgroundColor = UIColorFromRGB(0x808080).CGColor;
        movelinetwoLable.textColor = [UIColor blackColor];
        movelinetwoLable.textAlignment = NSTextAlignmentCenter;
        //movelinetwoLable.alpha = 0.8;
        movelinetwoLable.hidden = YES;
        [mainboxView addSubview:movelinetwoLable];
    }
    
    movelineone.frame = CGRectMake(touchViewPoint.x,0, 0.5,
                                   mainboxView.frame.size.height);
    movelinetwo.frame = CGRectMake(0,touchViewPoint.y, mainboxView.frame.size.width,0.5);
    CGRect oneFrame = movelineone.frame;
    oneFrame.size = CGSizeMake(35, 14);
    movelineoneLable.frame = oneFrame;
    CGRect towFrame = movelinetwo.frame;
    towFrame.size = CGSizeMake(55, 14);
    movelinetwoLable.frame = towFrame;
    
    movelineone.hidden = NO;
    movelinetwo.hidden = NO;
    movelineoneLable.hidden = NO;
    movelinetwoLable.hidden = NO;
    [self isKPointWithPoint:touchViewPoint];
}
#pragma mark 移除十字线
-(void)removeTipLine{
    [dotView removeFromSuperview];
    [movelineone removeFromSuperview];
    [movelinetwo removeFromSuperview];
    [movelineoneLable removeFromSuperview];
    [movelinetwoLable removeFromSuperview];
    dotView = nil;
    movelineone = nil;
    movelinetwo = nil;
    movelineoneLable = nil;
    movelinetwoLable = nil;
}
@end