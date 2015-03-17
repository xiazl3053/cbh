//
//  stocksDetailsListModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "stocksDetailsListModel.h"

@implementation stocksDetailsListModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.marketId = [dic objectForKey:@"marketId"];  // 大盘ID
        if (!self.marketId||![self.marketId isKindOfClass:[NSString class]]) {
            self.marketId=@"";
        }
        self.marketName = [dic objectForKey:@"marketName"];  // 大盘名称
        if (!self.marketName||![self.marketName isKindOfClass:[NSString class]]) {
            self.marketName=@"";
        }
        self.newestValue = [dic objectForKey:@"newestValue"]; // 最新值
        if (!self.newestValue||![self.newestValue isKindOfClass:[NSString class]]) {
            self.newestValue=@"";
        }
        self.changeRate = [dic objectForKey:@"changeRate"]; // 涨跌幅
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
        self.changeValue = [dic objectForKey:@"changeValue"]; // 涨跌额
        if (!self.changeValue||![self.changeValue isKindOfClass:[NSString class]]) {
            self.changeValue=@"";
        }
        self.total = [dic objectForKey:@"total"]; // 总手
        if (!self.total||![self.total isKindOfClass:[NSString class]]) {
            self.total=@"";
        }
        self.amount = [dic objectForKey:@"amount"]; // 金额
        if (!self.amount||![self.amount isKindOfClass:[NSString class]]) {
            self.amount=@"";
        }
        self.highest = [dic objectForKey:@"highest"]; // 最高
        if (!self.highest||![self.highest isKindOfClass:[NSString class]]) {
            self.highest=@"";
        }
        self.lowest = [dic objectForKey:@"lowest"]; // 最低
        if (!self.lowest||![self.lowest isKindOfClass:[NSString class]]) {
            self.lowest=@"";
        }
        self.handoff = [dic objectForKey:@"handoff"]; // 换手
        if (!self.handoff||![self.handoff isKindOfClass:[NSString class]]) {
            self.handoff=@"";
        }
        self.priceEarning = [dic objectForKey:@"priceEarning"]; // 市盈
        if (!self.priceEarning||![self.priceEarning isKindOfClass:[NSString class]]) {
            self.priceEarning=@"";
        }
        self.totalValue = [dic objectForKey:@"totalValue"]; // 总市值
        if (!self.totalValue||![self.totalValue isKindOfClass:[NSString class]]) {
            self.totalValue=@"";
        }
        self.circulatedStockValue = [dic objectForKey:@"circulatedStockValue"]; // 流通市值
        if (!self.circulatedStockValue||![self.circulatedStockValue isKindOfClass:[NSString class]]) {
            self.circulatedStockValue=@"";
        }
        self.dic = dic;
    }
    return self;
}

#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.marketId forKey:@"marketId"];
    [aCoder encodeObject:self.marketName forKey:@"marketName"];
    [aCoder encodeObject:self.newestValue forKey:@"newestValue"];
    [aCoder encodeObject:self.changeRate forKey:@"changeRate"];
    [aCoder encodeObject:self.changeValue forKey:@"changeValue"];
    [aCoder encodeObject:self.total forKey:@"total"];
    [aCoder encodeObject:self.amount forKey:@"amount"];
    [aCoder encodeObject:self.highest forKey:@"highest"];
    [aCoder encodeObject:self.lowest forKey:@"lowest"];
    [aCoder encodeObject:self.handoff forKey:@"handoff"];
    [aCoder encodeObject:self.priceEarning forKey:@"priceEarning"];
    [aCoder encodeObject:self.totalValue forKey:@"totalValue"];
    [aCoder encodeObject:self.circulatedStockValue forKey:@"circulatedStockValue"];

}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.marketId = [[aDecoder decodeObjectForKey:@"marketId"] copy];
    self.marketName = [[aDecoder decodeObjectForKey:@"marketName"] copy];
    self.newestValue = [[aDecoder decodeObjectForKey:@"newestValue"] copy];
    self.changeRate = [[aDecoder decodeObjectForKey:@"changeRate"] copy];
    self.changeValue = [[aDecoder decodeObjectForKey:@"changeValue"] copy];
    self.total = [[aDecoder decodeObjectForKey:@"total"] copy];
    self.amount = [[aDecoder decodeObjectForKey:@"amount"] copy];
    self.highest = [[aDecoder decodeObjectForKey:@"highest"] copy];
    self.lowest = [[aDecoder decodeObjectForKey:@"lowest"] copy];
    self.handoff = [[aDecoder decodeObjectForKey:@"handoff"] copy];
    self.priceEarning = [[aDecoder decodeObjectForKey:@"priceEarning"] copy];
    self.totalValue = [[aDecoder decodeObjectForKey:@"totalValue"] copy];
    self.circulatedStockValue = [[aDecoder decodeObjectForKey:@"circulatedStockValue"] copy];

    return self;
}
@end
