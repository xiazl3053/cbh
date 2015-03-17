//
//  globalMarketList.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "globalMarketList.h"

@implementation globalMarketList

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
        self.state = [dic objectForKey:@"state"]; // 国家编码
        if (!self.state||![self.state isKindOfClass:[NSString class]]) {
            self.state=@"";
        }
        self.isChangeColor = [dic objectForKey:@"isChangeColor"]; // 是否改变背景颜色
        if (!self.isChangeColor||![self.isChangeColor isKindOfClass:[NSString class]]) {
            self.isChangeColor=@"";
        }
    }
    return self;
}



@end
