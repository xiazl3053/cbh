//
//  hangqingHttpRequest.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hangqingHttpRequest.h"
#import "CommonOperation.h"
#import "kChartViewController.h"
#import "baseMarketListViewController.h"
#import "dapanViewController.h"
#import "gangguViewController.h"
#import "quanquiViewController.h"
#import "baseMarketListViewController.h"
#import "kPanKouViewController.h"
#import "kFenXiShiViewController.h"
#import "ziXuanIndexViewController.h"
#import "FiveSpeedViewController.h"
#import "TimeShareDetailViewController.h"
#import "UserModel.h"
#import "DCommon.h"

@interface hangqingHttpRequest (){
    ASIFormDataRequest *_request;
}
@property (nonatomic,strong) CommonOperation *co;
@end

@implementation hangqingHttpRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.co=[[CommonOperation alloc] init];
        self.hqResponse=[[hangqingHttpResponse alloc] init];
    }
    return self;
}


-(void)dealloc{
    self.co=nil;
    self.hqResponse=nil;
}

#pragma mark 初始化ASIFormDataRequest
//-(ASIFormDataRequest *)getRequest:(NSString *)urlString{
//    if(![self.co getNetStatus]){
//        // 检查网络状态
//        // 网络异常回调块
//        if (self.errorRequest) {
//            self.errorRequest(self);
//        }
//        return nil;
//    }
//    NSURL *url =[NSURL URLWithString:urlString];
//    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
//    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
//    [request setRequestMethod:@"POST"];
//    //设置参数
//    NSString *version=[self.co getVersion];
//    NSString *token=[self.co getToken];
//    [request setPostValue:[NSString stringWithFormat:@"%i",kClientType] forKey:@"clientType"];//客户端类型
//    [request setPostValue:version forKey:@"version"];//版本号
//    
//    if (token) {
//        //[request setPostValue:token forKey:@"_tk"];//tokens
//    }
//    //NSLog(@"---DFM---版本号：%@,客户端类型：%d，%@",version,kClientType,token);
//    _request = request;
//    return request;
//}

#pragma mark 初始化ASIFormDataRequest
-(ASIFormDataRequest *)getRequest:(NSString *)urlString{
    //先注释起来,网络判断不准确
    if(![[CommonOperation getId] getNetStatus]){//检查网络状态
        return nil;
    }
    
    NSURL *url =[NSURL URLWithString:urlString];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
    [request setRequestMethod:@"POST"];
    
    //超时时间
    request.timeOutSeconds = 8;
    
    return request;
}


#pragma mark 初始化参数
-(NSMutableDictionary *)getDic{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    
    //设置参数
    NSString *version=[[CommonOperation getId] getVersion];
    NSString *screenType=[[CommonOperation getId] getScreenType];
    
    [dic setValue:[NSString stringWithFormat:@"%i",kClientType] forKey:@"clientType"];//客户端类型
    [dic setValue:version forKey:@"version"];//版本号
    [dic setValue:screenType forKey:@"screenType"];//图片尺寸类型
    
    
    return dic;
}

#pragma mark 清除掉连接
-(void)clearRequest{
    self.co=nil;
    self.hqResponse=nil;
    ASIHTTPRequest *r = (ASIHTTPRequest*)_request;
    [r clearDelegatesAndCancel];
    [r markAsFinished];
    r = nil;
}

#pragma mark ---------------------------行情接口请求-----------------------------

#pragma mark 大盘指数接口请求
-(void)requestMarketIndexList:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn{
    self.hqResponse.zh = zhonghe;
    self.hqResponse.market = zhonghe.market;
    
    ASIFormDataRequest *request=[self getRequest:kURL(kMarketIndexList)];
    
    NSMutableDictionary *dic=[self getDic];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    //NSLog(@"---DFM---请求大盘接口%@",self.hqResponse.market);
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse marketIndexListBundle:blockRequest isSuccess:YES];
            });
        }];
        
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse marketIndexListBundle:blockRequest isSuccess:NO];
            });
            
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
    });
}

#pragma mark 热门行业接口请求
-(void)requestPopularProfessionList:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn{
    self.hqResponse.zh = zhonghe;
    self.hqResponse.market = zhonghe.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kPopularProfessionList)];
    
    NSMutableDictionary *dic=[self getDic];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    //NSLog(@"---DFM---请求热门行业接口");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse popularProfessionListBundle:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse popularProfessionListBundle:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
    });
}

#pragma mark 涨幅榜接口请求
-(void)requestChangeList:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn{
    self.hqResponse.zh = zhonghe;
    self.hqResponse.market = zhonghe.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kChangeList)];
    
    NSMutableDictionary *dic=[self getDic];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    //NSLog(@"---DFM---请求涨跌榜接口");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse changeListBundle:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse changeListBundle:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
    });
}

#pragma mark 请求综合页五分钟涨跌榜接口
-(void)requestFiveMinuteChangeIndex:(zhongheViewController*)zhonghe isAsyn:(BOOL)asyn{
    self.hqResponse.zh = zhonghe;
    self.hqResponse.market = zhonghe.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kFiveMinuteChangeIndex)];
    
    NSMutableDictionary *dic=[self getDic];
    NSString *data=[[CommonOperation getId]encryptHttp:dic];
    [request setPostValue:data forKey:@"data"];
    
    //NSLog(@"---DFM---请求综合页五分钟涨跌榜接口");
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse fiveMinuteChangeIndexBundle:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse fiveMinuteChangeIndexBundle:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
    });
}


#pragma mark 大盘列表接口请求
-(void)requestDapanList:(dapanViewController*)dapanController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page andType:(int)type isAsyn:(BOOL)asyn{
    self.hqResponse.market = dapanController.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kDapanList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //NSLog(@"---DFM---加载大盘列表接口：%@",kURL(kDapanList));
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:type] forKey:@"type"];
        [dic setValue:element forKey:@"element"];
        [dic setValue:orderBy forKey:@"orderBy"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 大盘接口参数
//        [request setPostValue:[NSNumber numberWithInt:type] forKey:@"type"]; // 0=大盘 1=沪股 2=深股 3=沪深股
//        [request setPostValue:element forKey:@"element"];  // 排序字段
//        [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型 0=降序 1=升序
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"]; // 页码
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse dapanListBundle:dapanController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse dapanListBundle:dapanController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 港股列表接口请求
-(void)requestGangguList:(gangguViewController*)gangguController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page isAsyn:(BOOL)asyn{
    self.hqResponse.market = gangguController.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kGangguList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //NSLog(@"---DFM---加载港股列表接口：%@",kURL(kDapanList));
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:1] forKey:@"type"];
        [dic setValue:element forKey:@"element"];
        [dic setValue:orderBy forKey:@"orderBy"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 港股接口参数
//        [request setPostValue:[NSNumber numberWithInt:1] forKey:@"type"]; // 1=港股
//        [request setPostValue:element forKey:@"element"];  // 排序字段
//        [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型 0=降序 1=升序
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse gangguListBundle:gangguController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse gangguListBundle:gangguController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 全球股票指数列表接口请求
-(void)requestGlobalMarketList:(quanquiViewController*)quanqiuController Element:(NSString*)element OrderBy:(NSString*)orderBy isAsyn:(BOOL)asyn{
    self.hqResponse.market = quanqiuController.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kGlobalMarketList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:element forKey:@"element"];
        [dic setValue:orderBy forKey:@"orderBy"];
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 港股接口参数
//        [request setPostValue:element forKey:@"element"];  // 排序字段
//        [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型 0=降序 1=升序
        //NSLog(@"---DFM---加载全球列表接口：%@&element=%@&orderBy=%@",kURL(kGlobalMarketList),element,orderBy);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse globalMarketListBundle:quanqiuController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse globalMarketListBundle:quanqiuController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}


#pragma mark 行业板块行情列表接口请求
-(void)requestProfessionMarketList:(baseMarketListViewController*)baseMarketController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page isAsyn:(BOOL)asyn{
    self.hqResponse.market = baseMarketController.market;
    ASIFormDataRequest *request=[self getRequest:kURL(kProfessionMarketList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //NSLog(@"---DFM---加载行业板块行情列表接口：%@",kURL(kProfessionMarketList));
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:1] forKey:@"type"];
        [dic setValue:element forKey:@"element"];
        [dic setValue:orderBy forKey:@"orderBy"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 行业板块行情接口参数
//        [request setPostValue:[NSNumber numberWithInt:1] forKey:@"type"]; // 1=港股
//        [request setPostValue:element forKey:@"element"];  // 排序字段
//        [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型 0=降序 1=升序
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"];
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse professionMarketListBundle:baseMarketController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse professionMarketListBundle:baseMarketController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark k线图中成交量明细接口请求
-(void)requestVolDetailList:(kPanKouViewController*)pankouController kId:(NSString*)kId isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kVolDetailList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //NSLog(@"---DFM---加载成交量明细列表接口：%@",kURL(kVolDetailList));
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:kId forKey:@"kId"];
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
//        // 成交量明细接口参数
//        [request setPostValue:kId forKey:@"kId"];  // 个股Id
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse volDetailListBundle:pankouController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse volDetailListBundle:pankouController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}


#pragma mark 个股列表接口请求
// 参数
// element   排序字段
// orderBy   排序类型 0=降序 1=升序
// page      页码
// type      1 = 深股 2=沪股 3=沪深A股
-(void)requestStocksDetailsList:(id)basemarketController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page andType:(int)type isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kStocksDetailsList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        if (![element isEqualToString:@""]) {
            [dic setValue:element forKey:@"element"];
            //[request setPostValue:element forKey:@"element"]; // 排序字段
        }
        [dic setValue:orderBy forKey:@"orderBy"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        [dic setValue:[NSNumber numberWithInt:1] forKey:@"type"];
        
//        [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"]; // 页码
//        // 接口参数
//        [request setPostValue:[NSNumber numberWithInt:type] forKey:@"type"]; // 个股类型
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        //NSLog(@"---DFM---加载个股列表接口：%@&type=%d&element=%@&orderBy=%@&page=%d",kURL(kStocksDetailsList),type,element,orderBy,page);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse stocksDetailsListBundle:basemarketController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse stocksDetailsListBundle:basemarketController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}
#pragma mark 请求个股列表刷新接口
-(void)requestStockListRefresh:(id)basemarketController Element:(NSString *)element OrderBy:(NSString *)orderBy List:(NSString *)list isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kStockListRefresh)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:list forKey:@"list"];
        
        // 接口参数
       // [request setPostValue:list forKey:@"list"]; // 个股类型
        if (![element isEqualToString:@""]) {
//            [request setPostValue:element forKey:@"element"]; // 排序字段
//            [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型
            [dic setValue:element forKey:@"element"];
            [dic setValue:orderBy forKey:@"orderBy"];
        }
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse stocksDetailsListBundle:basemarketController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse stocksDetailsListBundle:basemarketController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}


#pragma mark 列表页五分钟涨跌幅接口请求
// 参数
// element   排序字段
// orderBy   排序类型 0=降序 1=升序
// page      页码
-(void)requestFiveMinuteChangeList:(id)basemarketController Element:(NSString*)element OrderBy:(NSString*)orderBy andPage:(int)page isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kFiveMinuteChangeList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:orderBy forKey:@"orderBy"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
       
        
        // 接口参数
        if (![element isEqualToString:@""]) {
            //[request setPostValue:element forKey:@"element"]; // 排序字段
            [dic setValue:element forKey:@"element"];
        }
//        [request setPostValue:orderBy forKey:@"orderBy"]; // 排序类型
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"]; // 页码
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse fiveMinuteChangeListBundle:basemarketController andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse fiveMinuteChangeListBundle:basemarketController andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 请求沪深股指数
-(void)requestHushenStocksIndex:(huShenViewController *)hushen isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kHushenStocksIndex)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 接口参数
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse hushenStocksIndexBundle:hushen andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse hushenStocksIndexBundle:hushen andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}


#pragma mark ----------------------------------k线图接口集合----------------------------------
#pragma mark k线图接口请求
-(void)requestKLineIndex:(kChartViewController*)kChartView kLineType:(NSString*)klineType andCount:(int)count andIsRestoration:(BOOL)isRestoration andkId:(NSString*)kId type:(NSString*)type isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kKlineIndex)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //kId = @"002240";
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:klineType forKey:@"kLineType"];
        [dic setValue:[NSNumber numberWithInt:count] forKey:@"count"];
        [dic setValue:[NSNumber numberWithBool:isRestoration] forKey:@"isRestoration"];
        [dic setValue:kId forKey:@"kId"];
        [dic setValue:type forKey:@"type"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // k线类型：d：为日K,  w:周k，m为月k
//        [request setPostValue:klineType forKey:@"kLineType"];  // 类型
//        [request setPostValue:[NSNumber numberWithInt:count] forKey:@"count"]; // 数量
//        [request setPostValue:[NSNumber numberWithBool:isRestoration] forKey:@"isRestoration"]; // 是否复权
//        [request setPostValue:kId forKey:@"kId"]; // 股票ID
//        [request setPostValue:type forKey:@"type"]; // 股票类型 0=大盘 1=个股
        //NSLog(@"---DFM---请求k线图接口：%@&version=%@&kLineType=%@&count=%d&isRestoration=%d&kId=%@",kURL(kKlineIndex),[self.co getVersion],klineType,count,isRestoration,kId);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"---DFM---***********************请求K线图结束%@",[DCommon getTimestamp]);
                [self.hqResponse kLineBundle:kChartView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse kLineBundle:kChartView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        NSLog(@"---DFM---***********************请求K线图开始%@",[DCommon getTimestamp]);
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 分时图接口请求
-(void)requestTimeShareChart:(kChartViewController*)kChartView Type:(int)type andkId:(NSString*)kId andDays:(int)days isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kTimeShareChart)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //kId = @"600000";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:type] forKey:@"type"];
        [dic setValue:kId forKey:@"kId"];
        [dic setValue:[NSNumber numberWithInt:days] forKey:@"days"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 类型 0=大盘 1=沪股 2=深股
//        [request setPostValue:[NSNumber numberWithInt:type] forKey:@"type"]; // 类型
//        [request setPostValue:kId forKey:@"kId"]; // 股票ID
//        [request setPostValue:[NSNumber numberWithInt:days] forKey:@"days"]; // 天数
        //NSLog(@"---DFM---请求分时图：%@",kId);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse timeShareChartBundle:kChartView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse timeShareChartBundle:kChartView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}
#pragma mark 盘口接口请求
-(void)requestStocksBets:(kChartViewController*)kChartView Type:(int)type andkId:(NSString*)kId isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kStockBets)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //kId = @"600000";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:type] forKey:@"type"];
        [dic setValue:kId forKey:@"kId"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 类型 0=大盘 1=沪股 2=深股
//        [request setPostValue:[NSNumber numberWithInt:type] forKey:@"type"]; // 类型
//        [request setPostValue:kId forKey:@"kId"]; // 股票ID
        //NSLog(@"---DFM---请求盘口：%@&%@",kURL(kStockBets),kId);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse stockBetsBundle:kChartView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse stockBetsBundle:kChartView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark K线图资讯接口请求
-(void)requestKChartNewsList:(kNewsViewController*)kNewsView Type:(int)type andkId:(NSString*)kId ColumnID:(int)columnId andPage:(int)page isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kKChartNewsList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //kId = @"600000";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:type] forKey:@"type"];
        [dic setValue:kId forKey:@"kId"];
        [dic setValue:[NSNumber numberWithInt:columnId] forKey:@"column"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 类型 0=大盘 1=沪股 2=深股
//        [request setPostValue:[NSNumber numberWithInt:type] forKey:@"type"]; // 类型
//        [request setPostValue:kId forKey:@"kId"]; // 股票ID
//        [request setPostValue:[NSNumber numberWithInt:columnId] forKey:@"column"]; // 栏目ID
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"]; // 页码
        //NSLog(@"---DFM---请求K线图资讯接口：%@&%@",kURL(kKChartNewsList),kId);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse kChartNewsListBundle:kNewsView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse kChartNewsListBundle:kNewsView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 分析师接口请求
-(void)requestAnalystList:(kFenXiShiViewController*)kFenXiShiView Type:(int)type andkId:(NSString*)kId andPage:(int)page isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kAnalystList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    //kId = @"600000";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[NSNumber numberWithInt:type] forKey:@"type"];
        [dic setValue:kId forKey:@"kId"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        
        // 类型 0=大盘 1=沪股 2=深股
//        [request setPostValue:[NSNumber numberWithInt:type] forKey:@"type"]; // 类型
//        [request setPostValue:kId forKey:@"kId"]; // 股票ID
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"]; // 页码
        //NSLog(@"---DFM---请求分析师接口：%@&%@type=%d",kURL(kAnalystList),kId,type);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse analystListBundle:kFenXiShiView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse analystListBundle:kFenXiShiView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 五档明细接口请求
-(void)requestFiveAndDetail:(id)controller Class:(NSString*)class andkId:(NSString*)kId andType:(NSString*)type isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kFiveAndDetail)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:class forKey:@"class"];
        [dic setValue:kId forKey:@"kId"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        // 0=五档 1=明细 2=盘口成交明细 默认为0
//        [request setPostValue:class forKey:@"class"]; // 类型
//        [request setPostValue:kId forKey:@"kId"]; // 股票ID
        //[request setPostValue:type forKey:@"type"]; // 股票Type
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse fiveAndDetailBundle:controller Class:class andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse fiveAndDetailBundle:controller Class:class andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark ------------------------------自选股接口集---------------------------
#pragma mark 请求自选股接口
-(void)requestSelfMarketIndexList:(ziXuanIndexViewController*)zixuanView Element:(NSString*)element OrderBy:(int)orderBy Page:(int)page List:(NSArray*)list isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kSelfMarketIndexList)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        
        if (element) {
            if (element.length>0) {
                [dic setValue:element forKey:@"element"];
               // [request setPostValue:element forKey:@"element"]; // 排序字段
            }
        }
        
        [dic setValue:[NSNumber numberWithInt:orderBy] forKey:@"orderBy"];
        [dic setValue:[NSNumber numberWithInt:page] forKey:@"page"];
        
//        [request setPostValue:[NSNumber numberWithInt:orderBy] forKey:@"orderBy"]; // 排序类型 0=降序 1=升序
//        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"page"]; // 页码
        //[request setPostValue:[list JSONRepresentation] forKey:@"list"]; // 页码
        // 是否传输token 如果传输token则传回来用户远端的列表，否则只传list
        UserModel *user = [UserModel um];
        if (user.userId>0) {
            [dic setValue:[_co getToken] forKey:@"_tk"];
            //[request setPostValue:[_co getToken] forKey:@"_tk"];
        }else{
            [dic setValue:[list JSONRepresentation] forKey:@"list"];
           // [request setPostValue:[list JSONRepresentation] forKey:@"list"]; // 页码
        }
        user = nil;
        //NSLog(@"---DFM---请求自选股接口：%@&%@",kURL(kSelfMarketIndexList),list);
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfMarketListBundle:zixuanView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfMarketListBundle:zixuanView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 请求自选股提醒接口
-(void)requestSelfMarketRemind:(id)zRemind List:(NSArray*)list isAsyn:(BOOL)asyn{
    ASIFormDataRequest *request=[self getRequest:kURL(kSelfStockRemind)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *deviceId = [_co getAppleToken];
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[list JSONRepresentation] forKey:@"list"];
        [dic setValue:[_co getToken] forKey:@"_tk"];
        [dic setValue:deviceId forKey:@"deviceToken"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
//        //设备Token
//        NSString *deviceId = [_co getAppleToken];
//        [request setPostValue:[list JSONRepresentation] forKey:@"list"]; // 页码
//        [request setPostValue:[_co getToken] forKey:@"_tk"];//tokens // 需要登陆
//        [request setPostValue:deviceId forKey:@"deviceToken"]; // 设备token
        //NSLog(@"---DFM---请求自选股提醒接口，设备ID：%@",deviceId);
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfMarketRemindBundle:zRemind andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfMarketRemindBundle:zRemind andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 请求自选股单个管理接口
-(void)requestSelfStockManage:(zRemindViewController*)zRemind Handle:(NSString*)handle MarketId:(NSString*)marketId MarketType:(NSString*)marketType Timestamp:(NSString*)timestamp isAsyn:(BOOL)asyn{
    //    UserModel *user = [UserModel um];
    //    if (user.userId<=0)
    //        return;
    ASIFormDataRequest *request=[self getRequest:kURL(kSelfStockManage)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:handle forKey:@"handle"];
        [dic setValue:marketId forKey:@"marketId"];
        [dic setValue:marketType forKey:@"type"];
        [dic setValue:timestamp forKey:@"timestamp"];
        [dic setValue:[_co getToken] forKey:@"_tk"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        
//        [request setPostValue:handle forKey:@"handle"]; // 操作类型 0：增加，1：删除，2更新修改(更新时间戳)
//        [request setPostValue:marketId forKey:@"marketId"]; // 股票ID
//        [request setPostValue:marketType forKey:@"type"]; // 股票类型 0=大盘  1=个股
//        [request setPostValue:timestamp forKey:@"timestamp"]; // 股票时间戳
//        [request setPostValue:[_co getToken] forKey:@"_tk"];//tokens // 需要登陆
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfStockManageBundle:zRemind andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfStockManageBundle:zRemind andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 请求自选股批量管理接口
-(void)requestSelfStockBatchManage:(ziXuanIndexViewController*)zixuanView List:(NSArray*)list isAsyn:(BOOL)asyn{
//    UserModel *user = [UserModel um];
//    if (user.userId<=0)
//        return;
    ASIFormDataRequest *request=[self getRequest:kURL(kSelfStockBatchManage)];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:[list JSONRepresentation] forKey:@"list"];
        [dic setValue:[_co getToken] forKey:@"_tk"];
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        
//        [request setPostValue:[list JSONRepresentation] forKey:@"list"]; // 页码
//        [request setPostValue:[_co getToken] forKey:@"_tk"];//tokens // 需要登陆
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.hqResponse selfStockBatchManageBundle:zixuanView andRequest:blockRequest isSuccess:YES];
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
               [self.hqResponse selfStockBatchManageBundle:zixuanView andRequest:blockRequest isSuccess:NO];
            });
        }];
        //发送请求
        if (asyn) {
            [request startAsynchronous];
        }else{
            [request startSynchronous];
        }
        
    });
}

#pragma mark 推送消息中心接口
-(ASIHTTPRequest*)requestSelfMarketMessage:(NSString*)pageNum isUp:(BOOL)isUp block:(void (^)(ASIFormDataRequest* request,BOOL isSuccess,BOOL isUp))block
{
    ASIFormDataRequest *request=[self getRequest:kURL(@"selfMarketMessageCenter")];
    if (!request) {//没网络,下面不执行
        NSLog(@"暂无可用网络");
        return nil;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* version=[[CommonOperation getId] getVersion];
        
        
        NSMutableDictionary *dic=[self getDic];
        [dic setValue:pageNum forKey:@"page"];
        
//        [request setPostValue:version forKey:@"version"];//版本号
//        [request setPostValue:[NSString stringWithFormat:@"%d",kClientType] forKey:@"clientType"];//客户端类型
//        [request setPostValue:pageNum forKey:@"page"]; // 页码
        NSString* userId=[UserModel um].userId;
        if (userId>0) {
            [dic setValue:[[CommonOperation getId] getToken] forKey:@"_tk"];
            //[request setPostValue:[[CommonOperation getId] getToken] forKey:@"_tk"];//用户token
        }
        userId=nil;
        
        
        NSString *data=[[CommonOperation getId]encryptHttp:dic];
        [request setPostValue:data forKey:@"data"];
        
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            if(block){
                block(blockRequest,YES,isUp);
            }
        }];
        //请求失败
        [request setFailedBlock:^{
            if(block){
                block(blockRequest,NO,isUp);
            }
        }];
        //发送请求
        [request startAsynchronous];
    });
    return request;
}

@end
