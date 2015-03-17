//
//  hangqingHttpRequest.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "hangqingHttpResponse.h"
#import "CommonOperation.h"

@class hangqingHttpRequest;
@class quanquiViewController;
@class kPanKouViewController;
@class ziXuanIndexViewController;
@class zRemindViewController;
@class huShenViewController;

typedef void(^errorRequestBlock)(hangqingHttpRequest*);

@interface hangqingHttpRequest : NSObject

@property (nonatomic,strong) hangqingHttpResponse *hqResponse;
@property (nonatomic,copy) errorRequestBlock errorRequest;

#pragma mark 清除掉连接
-(void)clearRequest;

#pragma mark ---------------------行情接口集合----------------------
#pragma mark 请求大盘指数接口
-(void)requestMarketIndexList:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn;
#pragma mark 请求热门行业接口
-(void)requestPopularProfessionList:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn;
#pragma mark 请求涨跌榜接口
-(void)requestChangeList:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn;
#pragma mark 请求综合页五分钟涨跌榜接口
-(void)requestFiveMinuteChangeIndex:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn;
#pragma mark 请求大盘列表接口
-(void)requestDapanList:(dapanViewController*)dapanController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page andType:(int)type isAsyn:(BOOL)asyn;
#pragma mark 请求港股列表接口
-(void)requestGangguList:(gangguViewController*)gangguController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page isAsyn:(BOOL)asyn;
#pragma mark 请求全球股市列表接口
-(void)requestGlobalMarketList:(quanquiViewController*)quanqiuController Element:(NSString*)element OrderBy:(NSString*)orderBy isAsyn:(BOOL)asyn;
#pragma mark 请求行业板块行情接口
-(void)requestProfessionMarketList:(baseMarketListViewController*)baseMarketController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page isAsyn:(BOOL)asyn;
#pragma mark 成交量明细接口请求
-(void)requestVolDetailList:(kPanKouViewController*)pankouController kId:(NSString*)kId isAsyn:(BOOL)asyn;
#pragma mark 个股列表接口请求
-(void)requestStocksDetailsList:(id)basemarketController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page andType:(int)type isAsyn:(BOOL)asyn;
#pragma mark 请求刷新个股列表数据
-(void)requestStockListRefresh:(id)basemarketController  Element:(NSString*)element OrderBy:(NSString*)orderBy List:(NSString*)list isAsyn:(BOOL)asyn;
#pragma mark 列表页五分钟涨跌幅接口请求
-(void)requestFiveMinuteChangeList:(id)basemarketController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page isAsyn:(BOOL)asyn;
#pragma mark 请求沪深指
-(void)requestHushenStocksIndex:(huShenViewController*)hushen isAsyn:(BOOL)asyn;

#pragma mark ---------------------k线图接口集合----------------------
#pragma mark 请求k线图接口
-(void)requestKLineIndex:(kChartViewController*)kChartView kLineType:(NSString*)klineType andCount:(int)count andIsRestoration:(BOOL)isRestoration andkId:(NSString*)kId type:(NSString*)type isAsyn:(BOOL)asyn;
#pragma mark 分时图接口请求
-(void)requestTimeShareChart:(kChartViewController*)kChartView Type:(int)type andkId:(NSString*)kId andDays:(int)days isAsyn:(BOOL)asyn;
#pragma mark 盘口接口请求
-(void)requestStocksBets:(kChartViewController*)kChartView Type:(int)type andkId:(NSString*)kId isAsyn:(BOOL)asyn;
#pragma mark K线图资讯接口请求
-(void)requestKChartNewsList:(kNewsViewController*)kNewsView Type:(int)type andkId:(NSString*)kId ColumnID:(int)columnId andPage:(int)page isAsyn:(BOOL)asyn;
#pragma mark 分析师接口请求
-(void)requestAnalystList:(kFenXiShiViewController*)kFenXiShiView Type:(int)type andkId:(NSString*)kId andPage:(int)page isAsyn:(BOOL)asyn;
#pragma mark 五档明细接口请求
-(void)requestFiveAndDetail:(id)controller Class:(NSString*)class andkId:(NSString*)kId  andType:(NSString*)type  isAsyn:(BOOL)asyn;

#pragma mark ------------------------------自选股接口集---------------------------
#pragma mark 请求自选股接口
-(void)requestSelfMarketIndexList:(ziXuanIndexViewController*)zixuanView Element:(NSString*)element OrderBy:(int)orderBy Page:(int)page List:(NSArray*)list isAsyn:(BOOL)asyn;
#pragma mark 请求自选股批量管理接口
-(void)requestSelfStockBatchManage:(ziXuanIndexViewController*)zixuanView List:(NSArray*)list isAsyn:(BOOL)asyn;
#pragma mark 请求自选股单个管理接口
-(void)requestSelfStockManage:(zRemindViewController*)zRemind Handle:(NSString*)handle MarketId:(NSString*)marketId MarketType:(NSString*)marketType Timestamp:(NSString*)timestamp isAsyn:(BOOL)asyn;
#pragma mark 请求自选股提醒接口
-(void)requestSelfMarketRemind:(id)zRemind List:(NSArray*)list isAsyn:(BOOL)asyn;

#pragma mark 推送消息中心接口
-(ASIHTTPRequest*)requestSelfMarketMessage:(NSString*)pageNum isUp:(BOOL)isUp block:(void (^)(ASIFormDataRequest* request,BOOL isSuccess,BOOL isUp))block;
@end
