//
//  selfMarketModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "selfMarketModel.h"

@implementation selfMarketModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.ids = [dic objectForKey:@"ids"];  // 本地数据库Id
        if (!self.ids||![self.ids isKindOfClass:[NSString class]]) {
            self.ids=@"";
        }
        self.marketId = [dic objectForKey:@"marketId"];  // 大盘或者个股ID
        if (!self.marketId||![self.marketId isKindOfClass:[NSString class]]) {
            self.marketId=@"";
        }
        self.marketName = [dic objectForKey:@"marketName"];  // 名称
        if (!self.marketName||![self.marketName isKindOfClass:[NSString class]]) {
            self.marketName=@"";
        }
        self.marketType = [dic objectForKey:@"marketType"]; // 类型 0=大盘 1=沪股 2=深股
        if (!self.marketType||![self.marketType isKindOfClass:[NSString class]]) {
            self.marketType=@"";
        }
        self.userId = [dic objectForKey:@"userId"]; // 用户Id
        if (!self.userId||![self.userId isKindOfClass:[NSString class]]) {
            self.userId=@"";
        }
        self.timestamp = [dic objectForKey:@"timestamp"]; // 时间戳
        if (!self.timestamp||![self.timestamp isKindOfClass:[NSString class]]) {
            self.timestamp=@"";
        }
        self.isSyn = [dic objectForKey:@"isSyn"]; // 是否同步
        if (!self.isSyn||![self.isSyn isKindOfClass:[NSString class]]) {
            self.isSyn=@"";
        }
        self.heightPrice= [dic objectForKey:@"heightPrice"]; // 股价涨到
        if (!self.heightPrice||![self.heightPrice isKindOfClass:[NSString class]]) {
            self.heightPrice=@"";
        }
        self.lowPrice = [dic objectForKey:@"lowPrice"]; // 股价跌到
        if (!self.lowPrice||![self.lowPrice isKindOfClass:[NSString class]]) {
            self.lowPrice=@"";
        }
        self.todayChangeRate = [dic objectForKey:@"todayChangeRate"]; // 日涨跌幅超
        if (!self.todayChangeRate||![self.todayChangeRate isKindOfClass:[NSString class]]) {
            self.todayChangeRate=@"";
        }
        self.isNotice = [dic objectForKey:@"isNotice"]; // 公告提醒
        if (!self.isNotice||![self.isNotice isKindOfClass:[NSString class]]) {
            self.isNotice=@"";
        }
        self.isNews = [dic objectForKey:@"isNews"]; // 研报提醒
        if (!self.isNews||![self.isNews isKindOfClass:[NSString class]]) {
            self.isNews=@"";
        }
        }
    return self;
}
@end
