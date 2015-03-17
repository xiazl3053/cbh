//
//  kChartViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kBaseViewController.h"
#import "KLineViewController.h"
@class stockBetsModel;
@interface kChartViewController : kBaseViewController

#pragma mark 请求数据
-(void)getkLineIndex:(BOOL)isAsyn;
#pragma mark 初始化控制器
-(id)initWithParentController:(KLineViewController*)kLineView;
#pragma mark 接口数据返回处理
-(void)getkLineIndexBundle:(NSMutableArray*)data;
#pragma mark 分时图接口返回
-(void)getTimeShareChartBundle:(NSMutableArray*)data heightPrice:(CGFloat)heightPrice closePrice:(CGFloat)closePrice isStop:(BOOL)stop seconds:(double)seconds timeFrame:(NSString*)timeFrame;
#pragma mark 盘口数据返回处理
-(void)getkStockBetsBundle:(stockBetsModel*)data;
#pragma mark 主界面准备就绪，开始运行K线图
-(void)startRun;
@end
