//
//  timeShareChartModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "timeShareChartModel.h"

@implementation timeShareChartModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.transationPrice = [dic objectForKey:@"transationPrice"]; // 个股中表示每分钟的最后及时成交价，大盘中表示每分钟的大盘指数
        if (!self.transationPrice||![self.transationPrice isKindOfClass:[NSString class]]) {
            self.transationPrice=@"";
        }
        self.MAn = [dic objectForKey:@"MAn"]; // 个股中表示该种股票即时成交的平均价格，即当天成交总金额除以成交总股数，大盘中表示大盘不含加权的大盘指数
        if (!self.MAn||![self.MAn isKindOfClass:[NSString class]]) {
            self.MAn=@"";
        }
        self.changeValue = [dic objectForKey:@"changeValue"]; // 涨跌额
        if (!self.changeValue||![self.changeValue isKindOfClass:[NSString class]]) {
            self.changeValue=@"";
        }
        self.changeRate = [dic objectForKey:@"changeRate"]; // 涨跌幅
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
        self.volume = [dic objectForKey:@"volume"]; // 成交量
        if (!self.volume||![self.volume isKindOfClass:[NSString class]]) {
            self.volume=@"";
        }
        self.volumePrice = [dic objectForKey:@"volumePrice"]; // 成交额
        if (!self.volumePrice||![self.volumePrice isKindOfClass:[NSString class]]) {
            self.volumePrice=@"";
        }
        self.heightPrice = [dic objectForKey:@"heightPrice"]; // 及时成交价最高值（第一次返回昨天最高价）
        if (!self.heightPrice||![self.heightPrice isKindOfClass:[NSString class]]) {
            self.heightPrice=@"";
        }
        self.closePrice = [dic objectForKey:@"closePrice"]; // 昨日收盘价
        if (!self.closePrice||![self.closePrice isKindOfClass:[NSString class]]) {
            self.closePrice=@"";
        }
        self.time = [dic objectForKey:@"time"]; // 时间
        if (!self.time||![self.time isKindOfClass:[NSString class]]) {
            self.time=@"";
        }
        self.turnoverRate = [dic objectForKey:@"turnoverRate"]; // 换手率
        if (!self.turnoverRate||![self.turnoverRate isKindOfClass:[NSString class]]) {
            self.turnoverRate=@"";
        }
        self.priceType = [dic objectForKey:@"priceType"]; // 涨幅标识（与上一分钟的差决定）
        if (!self.priceType||![self.priceType isKindOfClass:[NSString class]]) {
            self.priceType=@"";
        }
        self.timeFrame = [dic objectForKey:@"timeFrame"]; // 时间段描述
        if (!self.timeFrame||![self.timeFrame isKindOfClass:[NSString class]]) {
            self.timeFrame=@"";
        }
        self.betsType = [dic objectForKey:@"betsType"]; // 盘口类型 0=买盘  1=卖盘
        if (!self.betsType||![self.betsType isKindOfClass:[NSString class]]) {
            self.betsType=@"";
        }
    }
    return self;
}


#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.transationPrice forKey:@"transationPrice"];
    [aCoder encodeObject:self.MAn forKey:@"MAn"];
    [aCoder encodeObject:self.changeValue forKey:@"changeValue"];
    [aCoder encodeObject:self.changeRate forKey:@"changeRate"];
    [aCoder encodeObject:self.volume forKey:@"volume"];
    [aCoder encodeObject:self.volumePrice forKey:@"volumePrice"];
    [aCoder encodeObject:self.heightPrice forKey:@"heightPrice"];
    [aCoder encodeObject:self.closePrice forKey:@"closePrice"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.turnoverRate forKey:@"turnoverRate"];
    [aCoder encodeObject:self.priceType forKey:@"priceType"];
    [aCoder encodeObject:self.timeFrame forKey:@"timeFrame"];
    [aCoder encodeObject:self.betsType forKey:@"betsType"];

}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.transationPrice = [[aDecoder decodeObjectForKey:@"transationPrice"] copy];
    self.MAn = [[aDecoder decodeObjectForKey:@"MAn"] copy];
    self.changeValue = [[aDecoder decodeObjectForKey:@"changeValue"] copy];
    self.changeRate = [[aDecoder decodeObjectForKey:@"changeRate"] copy];
    self.volume = [[aDecoder decodeObjectForKey:@"volume"] copy];
    self.volumePrice = [[aDecoder decodeObjectForKey:@"volumePrice"] copy];
    self.heightPrice = [[aDecoder decodeObjectForKey:@"heightPrice"] copy];
    self.closePrice = [[aDecoder decodeObjectForKey:@"closePrice"] copy];
    self.time = [[aDecoder decodeObjectForKey:@"time"] copy];
    self.turnoverRate = [[aDecoder decodeObjectForKey:@"turnoverRate"] copy];
    self.priceType = [[aDecoder decodeObjectForKey:@"priceType"] copy];
    self.timeFrame = [[aDecoder decodeObjectForKey:@"timeFrame"] copy];
    self.betsType = [[aDecoder decodeObjectForKey:@"betsType"] copy];
    
    return self;
}


@end
