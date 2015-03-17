//
//  professionMarketListModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "professionMarketListModel.h"

@implementation professionMarketListModel

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
        self.changeRate = [dic objectForKey:@"changeRate"]; // 涨跌幅
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
        self.threeChangeRate = [dic objectForKey:@"threeChangeRate"]; // 三日涨跌幅
        if (!self.threeChangeRate||![self.threeChangeRate isKindOfClass:[NSString class]]) {
            self.threeChangeRate=@"";
        }
        self.topStockName = [dic objectForKey:@"topStockName"]; // 领涨股
        if (!self.topStockName||![self.topStockName isKindOfClass:[NSString class]]) {
            self.topStockName=@"";
        }
        self.volume = [dic objectForKey:@"volume"]; // 总额
        if (!self.volume||![self.volume isKindOfClass:[NSString class]]) {
            self.volume=@"";
        }
        self.totalTurnover = [dic objectForKey:@"totalTurnover"]; // 总手
        if (!self.totalTurnover||![self.totalTurnover isKindOfClass:[NSString class]]) {
            self.totalTurnover=@"";
        }
        self.newestValue = [dic objectForKey:@"newestValue"]; // 最新值
        if (!self.newestValue||![self.newestValue isKindOfClass:[NSString class]]) {
            self.newestValue=@"";
        }
        self.turnoverRate = [dic objectForKey:@"turnoverRate"]; // 换手率
        if (!self.turnoverRate||![self.turnoverRate isKindOfClass:[NSString class]]) {
            self.turnoverRate=@"";
        }
        self.threeTurnoverRate = [dic objectForKey:@"threeTurnoverRate"]; // 三日换手率
        if (!self.threeTurnoverRate||![self.threeTurnoverRate isKindOfClass:[NSString class]]) {
            self.threeTurnoverRate=@"";
        }
        self.totalValue = [dic objectForKey:@"totalValue"]; // 总市值
        if (!self.totalValue||![self.totalValue isKindOfClass:[NSString class]]) {
            self.totalValue=@"";
        }
        self.circulatedStockValue = [dic objectForKey:@"circulatedStockValue"]; // 流通市值
        if (!self.circulatedStockValue||![self.circulatedStockValue isKindOfClass:[NSString class]]) {
            self.circulatedStockValue=@"";
        }
        self.isChangeColor = [dic objectForKey:@"isChangeColor"]; // 是否改变背景颜色
        if (!self.isChangeColor||![self.isChangeColor isKindOfClass:[NSString class]]) {
            self.isChangeColor=@"";
        }
    }
    return self;
}


@end
