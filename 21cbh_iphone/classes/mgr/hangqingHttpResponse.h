//
//  hangqingHttpResponse.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "MarketViewController.h"
#import "zhongheViewController.h"
#import "kChartViewController.h"
#import "baseMarketListViewController.h"
#import "dapanViewController.h"
#import "gangguViewController.h"
#import "quanquiViewController.h"
#import "kPanKouViewController.h"
#import "kNewsViewController.h"
#import "kFenXiShiViewController.h"
@class hangqingHttpResponse;
@class ziXuanIndexViewController;
@class FiveSpeedViewController;
@class TimeShareDetailViewController;
@class zRemindViewController;
@class huShenViewController;

typedef void(^errorResponseBlock)(hangqingHttpResponse*);

@interface hangqingHttpResponse : NSObject
@property (nonatomic,weak) MarketViewController *market;
@property (nonatomic,weak) zhongheViewController *zh;
@property (nonatomic,weak) kChartViewController *kCharView;
@property (nonatomic,copy) errorResponseBlock errorResponse;
#pragma mark ---------------------行情接口返回集合----------------------
#pragma mark 大盘接口返回
-(void)marketIndexListBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 热门数据返回
-(void)popularProfessionListBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 涨跌幅数据返回
-(void)changeListBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 综合页涨跌幅数据返回
-(void)fiveMinuteChangeIndexBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 大盘列表返回数据处理
-(void)dapanListBundle:(dapanViewController*)dapanController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 港股列表返回数据处理
-(void)gangguListBundle:(gangguViewController*)gangguController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 全球股市列表数据返回
-(void)globalMarketListBundle:(quanquiViewController *)quanqiuController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 行业板块行情数据返回
-(void)professionMarketListBundle:(baseMarketListViewController *)baseMarketController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 成交量数据返回
-(void)volDetailListBundle:(kPanKouViewController *)pankouController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
#pragma mark 个股列表返回数据处理
-(void)stocksDetailsListBundle:(id)basemarketController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 列表页五分钟涨跌榜返回数据处理
-(void)fiveMinuteChangeListBundle:(id)basemarketController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 沪深股返回数据处理
-(void)hushenStocksIndexBundle:(huShenViewController*)hushen andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success;

#pragma mark ---------------------k线图接口返回集合----------------------
#pragma mark k线图返回数据处理
-(void)kLineBundle:(kChartViewController*)kChartView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 分时图返回数据处理
-(void)timeShareChartBundle:(kChartViewController*)kChartView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 盘口返回数据处理
-(void)stockBetsBundle:(kChartViewController*)kChartView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark k线图资讯返回数据处理
-(void)kChartNewsListBundle:(kNewsViewController*)kNewsView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 分析师接口返回数据处理
-(void)analystListBundle:(kFenXiShiViewController*)kFenXiShiView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 五档明细接口返回数据处理
-(void)fiveAndDetailBundle:(id)controller Class:(NSString*)class andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;

#pragma mark --------------------------自选股数据返回处理-----------------------------
#pragma mark 自选股行情接口数据返回
-(void)selfMarketListBundle:(ziXuanIndexViewController*)zixuanView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 自选股批量更新接口数据返回
-(void)selfStockBatchManageBundle:(ziXuanIndexViewController*)zixuanView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 自选股单个管理接口数据返回
-(void)selfStockManageBundle:(zRemindViewController*)remindView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
#pragma mark 自选股提醒接口数据返回
-(void)selfMarketRemindBundle:(id)remindView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success;
@end
