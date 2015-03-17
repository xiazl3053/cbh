//
//  stockBetsModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "stockBetsModel.h"

@implementation stockBetsModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.newsValue = [dic objectForKey:@"newsValue"]; // 最新值
        if (!self.newsValue||![self.newsValue isKindOfClass:[NSString class]]) {
            self.newsValue=@"";
        }
        self.openPrice = [dic objectForKey:@"openPrice"]; // 开盘价
        if (!self.openPrice||![self.openPrice isKindOfClass:[NSString class]]) {
            self.openPrice=@"";
        }
        self.changeValue = [dic objectForKey:@"changeValue"]; // 涨跌额
        if (!self.changeValue||![self.changeValue isKindOfClass:[NSString class]]) {
            self.changeValue=@"";
        }
        self.heightPrice = [dic objectForKey:@"heightPrice"]; // 最高价
        if (!self.heightPrice||![self.heightPrice isKindOfClass:[NSString class]]) {
            self.heightPrice=@"";
        }
        self.volume = [dic objectForKey:@"volume"]; // 成交量
        if (!self.volume||![self.volume isKindOfClass:[NSString class]]) {
            self.volume=@"";
        }
        self.upStop = [dic objectForKey:@"upStop"]; // 涨停
        if (!self.upStop||![self.upStop isKindOfClass:[NSString class]]) {
            self.upStop=@"";
        }
        self.outerDish = [dic objectForKey:@"outerDish"]; // 外盘
        if (!self.outerDish||![self.outerDish isKindOfClass:[NSString class]]) {
            self.outerDish=@"";
        }
        self.quantityRatio = [dic objectForKey:@"quantityRatio"]; // 量比
        if (!self.quantityRatio||![self.quantityRatio isKindOfClass:[NSString class]]) {
            self.quantityRatio=@"";
        }
        self.peRatioA = [dic objectForKey:@"peRatioA"]; // 市盈（动）
        if (!self.peRatioA||![self.peRatioA isKindOfClass:[NSString class]]) {
            self.peRatioA=@"";
        }
        self.netAsset = [dic objectForKey:@"netAsset"]; // 净资产
        if (!self.netAsset||![self.netAsset isKindOfClass:[NSString class]]) {
            self.netAsset=@"";
        }
        self.totalStock = [dic objectForKey:@"totalStock"]; // 总股本
        if (!self.totalStock||![self.totalStock isKindOfClass:[NSString class]]) {
            self.totalStock=@"";
        }
        self.flowOfEquity = [dic objectForKey:@"flowOfEquity"]; // 流通股本
        if (!self.flowOfEquity||![self.flowOfEquity isKindOfClass:[NSString class]]) {
            self.flowOfEquity=@"";
        }
        self.changeRate = [dic objectForKey:@"changeRate"]; // 涨跌幅
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
        self.turnoverRate = [dic objectForKey:@"turnoverRate"]; // 换手率
        if (!self.turnoverRate||![self.turnoverRate isKindOfClass:[NSString class]]) {
            self.turnoverRate=@"";
        }
        self.lowPrice = [dic objectForKey:@"lowPrice"]; // 最低价
        if (!self.lowPrice||![self.lowPrice isKindOfClass:[NSString class]]) {
            self.lowPrice=@"";
        }
        self.volumePrice = [dic objectForKey:@"volumePrice"]; // 成交额
        if (!self.volumePrice||![self.volumePrice isKindOfClass:[NSString class]]) {
            self.volumePrice=@"";
        }
        self.downStop = [dic objectForKey:@"downStop"]; // 跌停
        if (!self.downStop||![self.downStop isKindOfClass:[NSString class]]) {
            self.downStop=@"";
        }
        self.innerDish = [dic objectForKey:@"innerDish"]; // 内盘
        if (!self.innerDish||![self.innerDish isKindOfClass:[NSString class]]) {
            self.innerDish=@"";
        }
        self.earningsThree = [dic objectForKey:@"earningsThree"]; // 收益（三）
        if (!self.earningsThree||![self.earningsThree isKindOfClass:[NSString class]]) {
            self.earningsThree=@"";
        }
        self.peRatioB = [dic objectForKey:@"peRatioB"]; // 市盈（静）
        if (!self.peRatioB||![self.peRatioB isKindOfClass:[NSString class]]) {
            self.peRatioB=@"";
        }
        self.pbRatio = [dic objectForKey:@"pbRatio"]; // 市净率
        if (!self.pbRatio||![self.pbRatio isKindOfClass:[NSString class]]) {
            self.pbRatio=@"";
        }
        self.totalPrice = [dic objectForKey:@"totalPrice"]; // 总市值
        if (!self.totalPrice||![self.totalPrice isKindOfClass:[NSString class]]) {
            self.totalPrice=@"";
        }
        self.flowPrice = [dic objectForKey:@"flowPrice"]; // 流通市值
        if (!self.flowPrice||![self.flowPrice isKindOfClass:[NSString class]]) {
            self.flowPrice=@"";
        }
        self.mainIn = [dic objectForKey:@"mainIn"]; // 主力流入
        if (!self.mainIn||![self.mainIn isKindOfClass:[NSString class]]) {
            self.mainIn=@"";
        }
        self.mainOut = [dic objectForKey:@"mainOut"]; // 主力流出
        if (!self.mainOut||![self.mainOut isKindOfClass:[NSString class]]) {
            self.mainOut=@"";
        }
        self.mainNetIn = [dic objectForKey:@"mainNetIn"]; // 主力净流入
        if (!self.mainNetIn||![self.mainNetIn isKindOfClass:[NSString class]]) {
            self.mainNetIn=@"";
        }
        self.hugeOrder = [dic objectForKey:@"hugeOrder"]; // 超大单
        if (!self.hugeOrder||![self.hugeOrder isKindOfClass:[NSString class]]) {
            self.hugeOrder=@"";
        }
        self.bigOrder = [dic objectForKey:@"bigOrder"]; // 大单
        if (!self.bigOrder||![self.bigOrder isKindOfClass:[NSString class]]) {
            self.bigOrder=@"";
        }
        self.middleOrder = [dic objectForKey:@"middleOrder"]; // 中单
        if (!self.middleOrder|![self.middleOrder isKindOfClass:[NSString class]]) {
            self.middleOrder=@"";
        }
        self.smallOrder = [dic objectForKey:@"smallOrder"]; // 小单
        if (!self.smallOrder||![self.smallOrder isKindOfClass:[NSString class]]) {
            self.smallOrder=@"";
        }
        self.todayPrice = [dic objectForKey:@"todayPrice"]; // 今天开盘指数，用于大盘或者行业指数
        if (!self.todayPrice||![self.todayPrice isKindOfClass:[NSString class]]) {
            self.todayPrice=@"";
        }
        self.yesterdayPrice = [dic objectForKey:@"yesterdayPrice"]; // 昨天收盘指数，用于大盘或者行业指数
        if (!self.yesterdayPrice||![self.yesterdayPrice isKindOfClass:[NSString class]]) {
            self.yesterdayPrice=@"";
        }
        self.changeUpValue = [dic objectForKey:@"changeUpValue"]; // 上涨，用于大盘或者行业指数
        if (!self.changeUpValue||![self.changeUpValue isKindOfClass:[NSString class]]) {
            self.changeUpValue=@"";
        }
        self.changeDownValue = [dic objectForKey:@"changeDownValue"]; // 下跌，用于大盘或者行业指数
        if (!self.changeDownValue||![self.changeDownValue isKindOfClass:[NSString class]]) {
            self.changeDownValue=@"";
        }
        self.sameDish = [dic objectForKey:@"newsValue"]; // 平盘，用于大盘或者行业指数
        if (!self.sameDish||![self.sameDish isKindOfClass:[NSString class]]) {
            self.sameDish=@"";
        }
        self.stockName = [dic objectForKey:@"stockName"]; // 股票名称
        if (!self.stockName||![self.stockName isKindOfClass:[NSString class]]) {
            self.stockName=@"";
        }
        self.dic = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    return self;
}

@end
