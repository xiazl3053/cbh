//
//  kLineModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kLineModel.h"

@implementation kLineModel

-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.openPrice = [dic objectForKey:@"openPrice"]; // 开盘价
        if (!self.openPrice||![self.openPrice isKindOfClass:[NSString class]]) {
            self.openPrice=@"";
        }
        self.closePrice = [dic objectForKey:@"closePrice"]; // 收盘价
        if (!self.closePrice||![self.closePrice isKindOfClass:[NSString class]]) {
            self.closePrice=@"";
        }
        self.heightPrice = [dic objectForKey:@"heightPrice"]; // 最高价
        if (!self.heightPrice||![self.heightPrice isKindOfClass:[NSString class]]) {
            self.heightPrice=@"";
        }
        self.lowPrice = [dic objectForKey:@"lowPrice"]; // 最高价
        if (!self.lowPrice||![self.lowPrice isKindOfClass:[NSString class]]) {
            self.lowPrice=@"";
        }
        self.volume = [dic objectForKey:@"volume"]; // 成交量
        if (!self.volume||![self.volume isKindOfClass:[NSString class]]) {
            self.volume=@"";
        }
        self.volumePrice = [dic objectForKey:@"volumePrice"]; // 成交额
        if (!self.volumePrice||![self.volumePrice isKindOfClass:[NSString class]]) {
            self.volumePrice=@"";
        }
        self.turnoverRate = [dic objectForKey:@"turnoverRate"]; // 换手率
        if (!self.turnoverRate||![self.turnoverRate isKindOfClass:[NSString class]]) {
            self.turnoverRate=@"";
        }
        self.changeValue = [dic objectForKey:@"changeValue"]; // 涨跌额
        if (!self.changeValue||![self.changeValue isKindOfClass:[NSString class]]) {
            self.changeValue=@"";
        }
        self.changeRate = [dic objectForKey:@"changeRate"]; // 涨跌幅
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
        self.MA5 = [dic objectForKey:@"MA5"]; // 5日均线
        if (!self.MA5||![self.MA5 isKindOfClass:[NSString class]]) {
            self.MA5=@"";
        }
        self.MA10 = [dic objectForKey:@"MA10"]; // 10日均线
        if (!self.MA10||![self.MA10 isKindOfClass:[NSString class]]) {
            self.MA10=@"";
        }
        self.MA20 = [dic objectForKey:@"MA20"]; // 20日均线
        if (!self.MA20||![self.MA20 isKindOfClass:[NSString class]]) {
            self.MA20=@"";
        }
        self.volMA5 = [dic objectForKey:@"volMA5"];  // 成交量5日均值
        if (!self.volMA5||![self.volMA5 isKindOfClass:[NSString class]]) {
            self.volMA5=@"";
        }
        self.volMA10 = [dic objectForKey:@"volMA10"];  // 成交量10日均值
        if (!self.volMA10||![self.volMA10 isKindOfClass:[NSString class]]) {
            self.volMA10=@"";
        }
        self.time = [dic objectForKey:@"time"]; // 日期或者时间
        if (!self.time||![self.time isKindOfClass:[NSString class]]) {
            self.time=@"";
        }
        self.MACD_DIF = [dic objectForKey:@"MACD_DIF"]; // MACD DIF值
        if (!self.MACD_DIF||![self.MACD_DIF isKindOfClass:[NSString class]]) {
            self.MACD_DIF=@"";
        }
        self.MACD_DEA = [dic objectForKey:@"MACD_DEA"]; // MACD DEA值
        if (!self.MACD_DEA||![self.MACD_DEA isKindOfClass:[NSString class]]) {
            self.MACD_DEA=@"";
        }
        self.MACD_M = [dic objectForKey:@"MACD_M"]; // MACD M值
        if (!self.MACD_M||![self.MACD_M isKindOfClass:[NSString class]]) {
            self.MACD_M=@"";
        }
        self.MACD_12EMA = [dic objectForKey:@"MACD_12EMA"]; // MACD 12EMA值
        if (!self.MACD_12EMA||![self.MACD_12EMA isKindOfClass:[NSString class]]) {
            self.MACD_12EMA=@"";
        }
        self.MACD_26EMA = [dic objectForKey:@"MACD_26EMA"]; // MACD 26EMA值
        if (!self.MACD_26EMA||![self.MACD_26EMA isKindOfClass:[NSString class]]) {
            self.MACD_26EMA=@"";
        }
        
        self.KDJ_K = [dic objectForKey:@"KDJ_K"]; // KDJ K值
        if (!self.KDJ_K||![self.KDJ_K isKindOfClass:[NSString class]]) {
            self.KDJ_K=@"";
        }
        self.KDJ_D = [dic objectForKey:@"KDJ_D"]; // KDJ D值
        if (!self.KDJ_D||![self.KDJ_D isKindOfClass:[NSString class]]) {
            self.KDJ_D=@"";
        }
        self.KDJ_J = [dic objectForKey:@"KDJ_J"]; // KDJ J值
        if (!self.KDJ_J||![self.KDJ_J isKindOfClass:[NSString class]]) {
            self.KDJ_J=@"";
        }
    }
    return self;
}

#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.openPrice forKey:@"openPrice"];
    [aCoder encodeObject:self.closePrice forKey:@"closePrice"];
    [aCoder encodeObject:self.heightPrice forKey:@"heightPrice"];
    [aCoder encodeObject:self.lowPrice forKey:@"lowPrice"];
    [aCoder encodeObject:self.volume forKey:@"volume"];
    [aCoder encodeObject:self.volumePrice forKey:@"volumePrice"];
    [aCoder encodeObject:self.turnoverRate forKey:@"turnoverRate"];
    [aCoder encodeObject:self.changeValue forKey:@"changeValue"];
    [aCoder encodeObject:self.changeRate forKey:@"changeRate"];
    [aCoder encodeObject:self.MA5 forKey:@"MA5"];
    [aCoder encodeObject:self.MA10 forKey:@"MA10"];
    [aCoder encodeObject:self.MA20 forKey:@"MA20"];
    [aCoder encodeObject:self.volMA5 forKey:@"volMA5"];
    [aCoder encodeObject:self.volMA10 forKey:@"volMA10"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.MACD_DIF forKey:@"MACD_DIF"];
    [aCoder encodeObject:self.MACD_DEA forKey:@"MACD_DEA"];
    [aCoder encodeObject:self.MACD_M forKey:@"MACD_M"];
    [aCoder encodeObject:self.MACD_12EMA forKey:@"MACD_12EMA"];
    [aCoder encodeObject:self.MACD_26EMA forKey:@"MACD_26EMA"];
    [aCoder encodeObject:self.KDJ_K forKey:@"KDJ_K"];
    [aCoder encodeObject:self.KDJ_D forKey:@"KDJ_D"];
    [aCoder encodeObject:self.KDJ_J forKey:@"KDJ_J"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.openPrice = [[aDecoder decodeObjectForKey:@"openPrice"] copy];
    self.closePrice = [[aDecoder decodeObjectForKey:@"closePrice"] copy];
    self.heightPrice = [[aDecoder decodeObjectForKey:@"heightPrice"] copy];
    self.lowPrice = [[aDecoder decodeObjectForKey:@"lowPrice"] copy];
    self.volume = [[aDecoder decodeObjectForKey:@"volume"] copy];
    self.volumePrice = [[aDecoder decodeObjectForKey:@"volumePrice"] copy];
    self.turnoverRate = [[aDecoder decodeObjectForKey:@"turnoverRate"] copy];
    self.changeValue = [[aDecoder decodeObjectForKey:@"changeValue"] copy];
    self.changeRate = [[aDecoder decodeObjectForKey:@"changeRate"] copy];
    self.MA5 = [[aDecoder decodeObjectForKey:@"MA5"] copy];
    self.MA10 = [[aDecoder decodeObjectForKey:@"MA10"] copy];
    self.MA20 = [[aDecoder decodeObjectForKey:@"MA20"] copy];
    self.volMA5 = [[aDecoder decodeObjectForKey:@"volMA5"] copy];
    self.volMA10 = [[aDecoder decodeObjectForKey:@"volMA10"] copy];
    self.time = [[aDecoder decodeObjectForKey:@"time"] copy];
    self.MACD_DIF = [[aDecoder decodeObjectForKey:@"MACD_DIF"] copy];
    self.MACD_DEA = [[aDecoder decodeObjectForKey:@"MACD_DEA"] copy];
    self.MACD_M = [[aDecoder decodeObjectForKey:@"MACD_M"] copy];
    self.MACD_12EMA = [[aDecoder decodeObjectForKey:@"MACD_12EMA"] copy];
    self.MACD_26EMA = [[aDecoder decodeObjectForKey:@"MACD_26EMA"] copy];
    self.KDJ_K = [[aDecoder decodeObjectForKey:@"KDJ_K"] copy];
    self.KDJ_D = [[aDecoder decodeObjectForKey:@"KDJ_D"] copy];
    self.KDJ_J = [[aDecoder decodeObjectForKey:@"KDJ_J"] copy];
    return self;
}
@end
