//
//  searchStocksModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "searchStocksModel.h"

@implementation searchStocksModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.rowid = [dic objectForKey:@"rowid"];  // id
        if (!self.rowid||![self.rowid isKindOfClass:[NSString class]]) {
            self.rowid=@"";
        }
        self.code = [dic objectForKey:@"code"];  // 股票代码
        if (!self.code||![self.code isKindOfClass:[NSString class]]) {
            self.code=@"";
        }
        self.market = [dic objectForKey:@"market"];  // 股票市场
        if (!self.market||![self.market isKindOfClass:[NSString class]]) {
            self.market=@"";
        }
        self.type = [dic objectForKey:@"type"];  // 类型 0=大盘 1=沪股 2=深股
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"";
        }
        self.pinyin = [dic objectForKey:@"pinyin"]; // 拼音
        if (!self.pinyin||![self.pinyin isKindOfClass:[NSString class]]) {
            self.pinyin=@"";
        }
        self.name = [dic objectForKey:@"name"]; // 名称
        if (!self.name||![self.name isKindOfClass:[NSString class]]) {
            self.name=@"";
        }
    }
    return self;
}
@end
