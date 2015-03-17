//
//  hangqingHttpResponse.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hangqingHttpResponse.h"
#import "FileOperation.h"
#import "CommonOperation.h"
#import "MarketViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "marketIndexModel.h"
#import "popularProfessionModel.h"
#import "changeListModel.h"
#import "kLineModel.h"
#import "baseMarketListViewController.h"
#import "dapanListModel.h"
#import "dapanViewController.h"
#import "quanquiViewController.h"
#import "globalMarketList.h"
#import "baseMarketListViewController.h"
#import "professionMarketListModel.h"
#import "kPanKouViewController.h"
#import "volDetailListModel.h"
#import "stocksDetailsListModel.h"
#import "timeShareChartModel.h"
#import "stockBetsModel.h"
#import "kChartNewsListModel.h"
#import "kNewsViewController.h"
#import "kFenXiShiViewController.h"
#import "analystListModel.h"
#import "selfMarketModel.h"
#import "ziXuanIndexViewController.h"
#import "FiveSpeedViewController.h"
#import "TimeShareDetailViewController.h"
#import "fiveAndDetailModel.h"
#import "zRemindViewController.h"
#import "huShenViewController.h"

@interface hangqingHttpResponse ()

@property (nonatomic,strong) FileOperation *fo;
@property (nonatomic,strong) CommonOperation *co;

@end

@implementation hangqingHttpResponse

-(id)init{
    self = [super init];
    if (self){
        // 对象初始化
        self.fo = [[FileOperation alloc] init];
        self.co = [[CommonOperation alloc] init];
    }
    return self;
}

-(void)dealloc{
    // 释放对象
    self.fo = nil;
    self.co = nil;
    self.zh = nil;
    self.market = nil;
    self.kCharView = nil;
    self.errorResponse = nil;
}

-(void)errorDataCallBlock{
    // 请求失败处理
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"---DFM---请求失败");
        if (self.errorResponse) {
            self.errorResponse(self);
        }
    });
}


#pragma mark ----------------------------行情接口数据返回处理-------------------------------
#pragma mark 大盘指数接口返回数据处理
-(void)marketIndexListBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (self.zh) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"marketIndex" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装
                NSDictionary *subDic = [dic objectForKey:@"marketIndexList"];
                for (NSDictionary *item in subDic) {
                    marketIndexModel *marketModel = [[marketIndexModel alloc] initWithDic:item];
                    [dataArray addObject:marketModel];
                    marketModel = nil;
                }
                subDic = nil;
            }
            
            // 更新行情首页大盘指数数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.zh getMarketIndexBundle:dataArray isUpdate:NO];
                
            });
            dataArray = nil;
            data = nil;
            dic = nil;
            datastr = nil;
        }
        
    }else{
       // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 热门行业接口返回数据处理
-(void)popularProfessionListBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (self.zh) {
            // 得到数据
            //NSString *datastr = [request responseString];
            // 模拟数据
            NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kPopularProfessionList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装
                NSDictionary *subDic = [dic objectForKey:kPopularProfessionList];
                for (NSDictionary *item in subDic) {
                    popularProfessionModel *pModel = [[popularProfessionModel alloc] initWithDic:item];
                    [dataArray addObject:pModel];
                    pModel = nil;
                }
                subDic = nil;
            }
            // 更新行情首页热门行业数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.zh getPopularProfessionListBundle:dataArray isUpdate:NO];
            });
            dataArray = nil;
            data = nil;
            dic = nil;
            datastr = nil;
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 涨跌榜返回数据处理
-(void)changeListBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (self.zh) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kChangeList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"];
            NSMutableArray *goupDataArray = [[NSMutableArray alloc] init];
            NSMutableArray *downDataArray = [[NSMutableArray alloc] init];
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装涨幅榜
                for (NSDictionary *item in [dic objectForKey:@"goupList"]) {
                    changeListModel *cModel = [[changeListModel alloc] initWithDic:item];
                    [goupDataArray addObject:cModel];
                    cModel = nil;
                }
                // 封装跌幅榜
                for (NSDictionary *item in [dic objectForKey:@"downList"]) {
                    changeListModel *cModel = [[changeListModel alloc] initWithDic:item];
                    [downDataArray addObject:cModel];
                    cModel = nil;
                }
            }
            // 更新行情首页热门行业数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.zh getChangeListBundle:goupDataArray isDown:NO isUpdate:NO];
                [self.zh getChangeListBundle:downDataArray isDown:YES isUpdate:NO];
            });
            
            goupDataArray = nil;
            downDataArray = nil;
            data = nil;
            dic = nil;
            datastr = nil;
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 综合页五分钟涨跌榜数据将返回
-(void)fiveMinuteChangeIndexBundle:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (self.zh) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kChangeList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"];
            NSMutableArray *goupDataArray = [[NSMutableArray alloc] init];
            NSMutableArray *downDataArray = [[NSMutableArray alloc] init];
            int dicCount = 0;
            BOOL isRefresh = NO;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装涨幅榜
                for (NSDictionary *item in [dic objectForKey:@"goupList"]) {
                    changeListModel *cModel = [[changeListModel alloc] initWithDic:item];
                    [goupDataArray addObject:cModel];
                    cModel = nil;
                }
                // 封装跌幅榜
                for (NSDictionary *item in [dic objectForKey:@"downList"]) {
                    changeListModel *cModel = [[changeListModel alloc] initWithDic:item];
                    [downDataArray addObject:cModel];
                    cModel = nil;
                }
                // 是否刷新
                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
            }
            // 更新行情首页热门行业数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.zh getFiveMinuteIndexBundle:goupDataArray isDown:NO isUpdate:isRefresh];
                [self.zh getFiveMinuteIndexBundle:downDataArray isDown:YES isUpdate:isRefresh];
            });
            goupDataArray = nil;
            downDataArray = nil;
            data = nil;
            dic = nil;
            datastr = nil;
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 大盘列表返回数据处理
-(void)dapanListBundle:(dapanViewController*)dapanController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (dapanController) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDapanList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            BOOL isRefresh = NO;
            int pageCount = 0;
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装大盘列表数据
                for (NSDictionary *item in [dic objectForKey:@"list"]) {
                    dapanListModel *dModel = [[dapanListModel alloc] initWithDic:item];
                    [dataArray addObject:dModel];
                    dModel = nil;
                }
                pageCount = [[dic objectForKey:@"pageCount"] intValue];
                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
            }
            // 更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [dapanController getDapanListBundle:dataArray isRefresh:isRefresh pageCount:pageCount];
            });

            dataArray = nil;
            data = nil;
            dic = nil;
            datastr = nil;
        }
        
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 港股列表返回数据处理
-(void)gangguListBundle:(gangguViewController *)gangguController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (gangguController) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kGangguList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            BOOL isRefresh = NO;
            int pageCount = 0;
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装大盘列表数据
                for (NSDictionary *item in [dic objectForKey:@"list"]) {
                    dapanListModel *dModel = [[dapanListModel alloc] initWithDic:item];
                    [dataArray addObject:dModel];
                    dModel = nil;
                }
                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
                pageCount = [[dic objectForKey:@"pageCount"] intValue];
            }
            
            // 传递数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [gangguController getGangguListBundle:dataArray isRefresh:isRefresh pageCount:pageCount];
            });
        }
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 全球股市列表返回数据处理
-(void)globalMarketListBundle:(quanquiViewController *)quanqiuController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (quanqiuController) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kGlobalMarketList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            BOOL isRefresh = NO;
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            // 封装数据
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                for (NSDictionary *item in [dic objectForKey:@"list"]) {
                    globalMarketList *dModel = [[globalMarketList alloc] initWithDic:item];
                    [dataArray addObject:dModel];
                    dModel = nil;
                }
                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
            }
            // 传递数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [quanqiuController getGlobalMarketListBundle:dataArray isRefresh:isRefresh];
            });
        }
        
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}


//#pragma mark 行业板块行情列表返回数据处理
//-(void)professionMarketListBundle:(baseMarketListViewController *)baseMarketController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
//    if (success) {
//        if (baseMarketController) {
//            // 得到数据
//            //NSString *datastr = [request responseString];
//            // 模拟数据
//            NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kProfessionMarketList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
//            //NSLog(@"---DFM---得到数据%@",datastr);
//            // 解析
//            NSDictionary *data = [datastr JSONValue];
//            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//            BOOL isRefresh = NO;
//            int pageCount = 0;
//            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
//            // 封装数据
//            int dicCount = 0;
//            // 数据异常处理
//            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
//                dicCount = dic.count;
//            }
//            if (dicCount) {
//                for (NSDictionary *item in [dic objectForKey:@"list"]) {
//                    professionMarketListModel *dModel = [[professionMarketListModel alloc] initWithDic:item];
//                    [dataArray addObject:dModel];
//                    dModel = nil;
//                }
//                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
//                pageCount = [[dic objectForKey:@"pageCount"] boolValue];
//            }
//            // 传递数据
//            dispatch_async(dispatch_get_main_queue(), ^{
//                baseMarketController.listType = 1; // 行业板块行情列表接口
//                [baseMarketController getInterFaceBundle:dataArray isRefresh:isRefresh pageCount:pageCount];
//            });
//        }
//        
//    }else{
//        // 请求失败处理
//        NSLog(@"---DFM---请求失败");
//        if (self.errorResponse) {
//            self.errorResponse(self);
//        }
//    }
//}

//#pragma mark 成交量列表返回数据处理
//-(void)volDetailListBundle:(kPanKouViewController *)pankouController andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
//    if (success) {
//        if (pankouController) {
//            // 得到数据
//            //NSString *datastr = [request responseString];
//            // 模拟数据
//            NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kVolDetailList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
//            //NSLog(@"---DFM---得到数据%@",datastr);
//            // 解析
//            NSDictionary *data = [datastr JSONValue];
//            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
//            // 封装数据
//            if (dic.count>0) {
//                // 封装成交量列表数据
//                for (NSDictionary *item in [data objectForKey:kVolDetailList]) {
//                    volDetailListModel *dModel = [[volDetailListModel alloc] initWithDic:item];
//                    [dataArray addObject:dModel];
//                    dModel = nil;
//                }
//            }
//            // 传递数据
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //[pankouController getVolDetailListBundle:dataArray];
//            });
//        }
//        
//    }else{
//        // 请求失败处理
//        NSLog(@"---DFM---请求失败");
//        if (self.errorResponse) {
//            self.errorResponse(self);
//        }
//    }
//}

#pragma mark 个股列表返回数据处理
-(void)stocksDetailsListBundle:(id)basemarketController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (basemarketController) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kStocksDetailsList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            BOOL isRefresh = NO;
            int pageCount = 0;
            // 封装数据
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装大盘列表数据
                for (NSDictionary *item in [[data objectForKey:@"data"] objectForKey:@"list"]) {
                    stocksDetailsListModel *dModel = [[stocksDetailsListModel alloc] initWithDic:item];
                    [dataArray addObject:dModel];
                    dModel = nil;
                }
                pageCount = [[dic objectForKey:@"pageCount"] intValue];
                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
            }
            // 更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [basemarketController getStocksDetailsListBundle:dataArray isRefresh:isRefresh pageCount:pageCount];
            });
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}
#pragma mark 列表页五分钟涨跌榜数据返回
-(void)fiveMinuteChangeListBundle:(id)basemarketController andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (basemarketController) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kStocksDetailsList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            BOOL isRefresh = NO;
            int pageCount = 0;
            // 封装数据
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount) {
                // 封装大盘列表数据
                for (NSDictionary *item in [[data objectForKey:@"data"] objectForKey:@"list"]) {
                    changeListModel *dModel = [[changeListModel alloc] initWithDic:item];
                    [dataArray addObject:dModel];
                    dModel = nil;
                }
                pageCount = [[dic objectForKey:@"pageCount"] intValue];
                isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
            }
            // 更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [basemarketController getStocksDetailsListBundle:dataArray isRefresh:isRefresh pageCount:pageCount];
            });
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 沪深股指数返回
-(void)hushenStocksIndexBundle:(huShenViewController *)hushen andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (hushen) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kStocksDetailsList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            // 封装数据
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            NSDictionary *hu;
            NSDictionary *shen;
            if (dicCount) {
                // 封装数据
                hu = [dic objectForKey:@"hu"];
                shen = [dic objectForKey:@"shen"];
            }
            // 更新
            dispatch_async(dispatch_get_main_queue(), ^{
                [hushen getHushenStocksIndexBundle:hu andShen:shen];
                
            });
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark ----------------------------k线图接口返回集合-----------------------------

#pragma mark k线图返回数据处理
-(void)kLineBundle:(kChartViewController*)kChartView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (kChartView) {
            // 得到数据
            NSString *datastr = [request responseString];
            // 模拟数据
            //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kKlineIndex ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
            //NSLog(@"---DFM---得到数据%@",datastr);
            // 解析
            NSDictionary *data = [datastr JSONValue];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
            int dicCount = 0;
            // 数据异常处理
            if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                dicCount = dic.count;
            }
            if (dicCount>0) {
                NSDictionary *list = [dic objectForKey:@"list"];
                if (list) {
                    // 封装涨幅榜
                    for (NSDictionary *item in list) {
                        if (item.count>0) {
                            kLineModel *kModel = [[kLineModel alloc] initWithDic:item];
                            [dataArray addObject:kModel];
                            kModel = nil;
                        }
                    }
                }
            }
            // 更新k线图
            dispatch_async(dispatch_get_main_queue(), ^{
                [kChartView getkLineIndexBundle:dataArray];
            });
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 分时图返回数据处理
-(void)timeShareChartBundle:(kChartViewController*)kChartView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (kChartView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kKlineIndex ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                NSDictionary *dic = [data objectForKey:@"data"] ;
                BOOL isStop = NO; // 是否停盘
                CGFloat heightPrice = 0; // 及时最高成交价
                CGFloat closePrice = 0; // 昨日收盘价
                double seconds = 0; // 下次开盘的毫秒差
                int dicCount = 0;
                NSString *timeFrame;// 分时时间段
                // 数据异常处理
                if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                    dicCount = dic.count;
                }
                // 数据异常处理
                if (dicCount>0) {
                    NSDictionary *list = [dic objectForKey:@"list"];
                    if (list) {
                        // 封装涨幅榜
                        for (NSDictionary *item in list) {
                            if (item.count>0) {
                                timeShareChartModel *kModel = [[timeShareChartModel alloc] initWithDic:item];
                                [dataArray addObject:kModel];
                                kModel = nil;
                            }
                        }
                        heightPrice = [[dic objectForKey:@"heightPrice"] floatValue];
                        closePrice = [[dic objectForKey:@"closePrice"] floatValue];
                        seconds = [[dic objectForKey:@"seconds"] doubleValue];
                        isStop = [[dic objectForKey:@"isStop"] boolValue];
                        timeFrame = [dic objectForKey:@"timeFrame"];
                    }
                }
                // 更新分时图
                dispatch_async(dispatch_get_main_queue(), ^{
                    [kChartView getTimeShareChartBundle:dataArray heightPrice:heightPrice closePrice:closePrice isStop:isStop seconds:seconds timeFrame:timeFrame];
                });
                
                dataArray = nil;
                datastr = nil;
                data = nil;
                dic = nil;
                
            }
            @catch (NSException *exception) {
                [self errorDataCallBlock];
            }
            
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 盘口返回数据处理
-(void)stockBetsBundle:(kChartViewController*)kChartView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (kChartView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kStockBets ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
                stockBetsModel *kModel;
                // 数据异常处理
                if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                    kModel = [[stockBetsModel alloc] initWithDic:dic];
                }
                // 更新盘口数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [kChartView getkStockBetsBundle:kModel];
                });

            }
            @catch (NSException *exception) {
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark k线图资讯返回数据处理
-(void)kChartNewsListBundle:(kNewsViewController*)kNewsView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (kNewsView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kKChartNewsList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                int dicCount = 0;
                // 数据异常处理
                if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                    dicCount = dic.count;
                }
                // 数据异常处理
                if (dicCount>0) {
                    NSDictionary *list = [dic objectForKey:@"list"];
                    if ([[list class] isSubclassOfClass:[NSArray class]]) {
                        if (list.count>0) {
                            // 封装数据
                            for (NSDictionary *item in list) {
                                if (item.count>0) {
                                    kChartNewsListModel *kModel = [[kChartNewsListModel alloc] initWithDic:item];
                                    [dataArray addObject:kModel];
                                    kModel = nil;
                                }
                            }
                        }
                    }
                    
                }
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [kNewsView getKChartNewsListBundle:dataArray];
                });
                
            }
            @catch (NSException *exception) {
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 分析师接口返回数据处理
-(void)analystListBundle:(kFenXiShiViewController*)kFenXiShiView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (kFenXiShiView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAnalystList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                int dicCount = 0;
                // 数据异常处理
                if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                    dicCount = dic.count;
                }
                // 数据异常处理
                if (dicCount>0) {
                    NSDictionary *list = [dic objectForKey:@"list"];
                    if (list) {
                        // 封装涨幅榜
                        for (NSDictionary *item in list) {
                            if (item.count>0) {
                                analystListModel *kModel = [[analystListModel alloc] initWithDic:item];
                                [dataArray addObject:kModel];
                                kModel = nil;
                            }
                        }
                    }
                }
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [kFenXiShiView getAnalystListBundle:dataArray];
                });
                
            }
            @catch (NSException *exception) {
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 五档明细接口返回数据处理
-(void)fiveAndDetailBundle:(id)controller Class:(NSString*)class andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (controller) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAnalystList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                int dicCount = 0;
                // 数据异常处理
                if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                    dicCount = dic.count;
                }
                // 数据异常处理
                if (dicCount>0) {
                    NSDictionary *list = [dic objectForKey:@"list"];
                    if (list) {
                        // 封装
                        for (NSDictionary *item in list) {
                            if (item.count>0) {
                                fiveAndDetailModel *kModel = [[fiveAndDetailModel alloc] initWithDic:item];
                                [dataArray addObject:kModel];
                                kModel = nil;
                            }
                        }
                    }
                }
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 五档
                    if ([class intValue]==0) {
                        FiveSpeedViewController *five = (FiveSpeedViewController*)controller;
                        [five getFiveAndDetailBundle:dataArray];
                        five = nil;
                    }
                    // 明细
                    if ([class intValue]==1) {
                        TimeShareDetailViewController *detail = (TimeShareDetailViewController*)controller;
                        [detail getFiveAndDetailBundle:dataArray];
                        detail = nil;
                    }
                    // 盘口明细
                    if ([class intValue]==2) {
                        kPanKouViewController *detail = (kPanKouViewController*)controller;
                        [detail getFiveAndDetailBundle:dataArray];
                        detail = nil;
                    }
                });
                
            }
            @catch (NSException *exception) {
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        [self errorDataCallBlock];
    }
    request = nil;
}



#pragma mark --------------------------自选股数据返回处理-----------------------------
#pragma mark 自选股行情接口数据返回
-(void)selfMarketListBundle:(ziXuanIndexViewController*)zixuanView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (zixuanView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kSelfMarketIndexList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                 NSLog(@"data========================%@",datastr);
                NSDictionary *data = [datastr JSONValue];
                NSDictionary *dic = (NSDictionary*)[data objectForKey:@"data"] ;
                NSString *err = [data objectForKey:@"errno"] ;// 错误等级 3=您的账号已在其他设备登录，请重新登录
                // 错误登记判断
                
                NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                int dicCount = 0;
                BOOL isRefresh = NO;
                int pageCount = 0;
                // 数据异常处理
                if (![dic isEqual:[NSNull null]] && dic && dic!=NULL && [[dic class] isSubclassOfClass:[NSDictionary class]]) {
                    dicCount = dic.count;
                }
                // 数据异常处理
                if (dicCount>0) {
                    NSDictionary *list = [dic objectForKey:@"list"];
                    if (list) {
                        // 封装涨幅榜
                        for (NSDictionary *item in list) {
                            if (item.count>0) {
                                dapanListModel *kModel = [[dapanListModel alloc] initWithDic:item];
                                [dataArray addObject:kModel];
                                kModel = nil;
                            }
                        }
                    }
                    isRefresh = [[dic objectForKey:@"isRefresh"] boolValue];
                    pageCount = [[dic objectForKey:@"pageCount"] intValue];
                }
                // 用户在其他设备登录
                if ([err intValue]==3) {
                    [dataArray addObject:[NSNumber numberWithInt:3]];
                }
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [zixuanView getSelfMarketListBundle:dataArray isRefresh:isRefresh pageCount:pageCount];
                });
                
            }
            @catch (NSException *exception) {
                NSLog(@"---DFM---数据出错");
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}
#pragma mark 自选股提醒接口返回
-(void)selfMarketRemindBundle:(id)remindView andRequest:(ASIFormDataRequest *)request isSuccess:(BOOL)success{
    if (success) {
        if (remindView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kSelfMarketIndexList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSString *dic = (NSString*)[data objectForKey:@"errno"] ;
                BOOL isSuccess = NO;
                if ([dic isEqualToString:@"0"]) {
                    isSuccess = YES;
                }
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![dic isEqualToString:@"0"]) {
                        NSString *message = (NSString*)[data objectForKey:@"msg"] ;
                        [remindView limitMoreTenRemind:message];
                    }else{
                        [remindView getSelfMarketRemindBundle:isSuccess];
                    }
                });
                
            }
            @catch (NSException *exception) {
                NSLog(@"---DFM---数据出错");
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 自选股批量更新接口数据返回
-(void)selfStockBatchManageBundle:(ziXuanIndexViewController*)zixuanView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (zixuanView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kSelfMarketIndexList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSString *dic = (NSString*)[data objectForKey:@"errno"] ;
                int isSuccess = [dic intValue];
                
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [zixuanView getSelfStockBatchManageBundle:isSuccess];
                });
                
            }
            @catch (NSException *exception) {
                NSLog(@"---DFM---数据出错");
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}

#pragma mark 自选股单个管理接口数据返回
-(void)selfStockManageBundle:(zRemindViewController*)remindView andRequest:(ASIFormDataRequest *)request  isSuccess:(BOOL)success{
    if (success) {
        if (remindView) {
            @try {
                // 得到数据
                NSString *datastr = [request responseString];
                // 模拟数据
                //NSString *datastr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kSelfMarketIndexList ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
                //NSLog(@"---DFM---得到数据%@",datastr);
                // 解析
                NSDictionary *data = [datastr JSONValue];
                NSString *dic = (NSString*)[data objectForKey:@"errno"] ;
                int isSuccess = [dic intValue];
                
                // 更新数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [remindView getSelfStockManageBundle:isSuccess];
                });
                
            }
            @catch (NSException *exception) {
                NSLog(@"---DFM---数据出错");
                [self errorDataCallBlock];
            }
        }
        
    }else{
        // 请求失败处理
        NSLog(@"---DFM---请求失败");
        [self errorDataCallBlock];
    }
    request = nil;
}
@end
