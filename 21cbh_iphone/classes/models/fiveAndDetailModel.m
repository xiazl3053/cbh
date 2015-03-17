//
//  fiveAndDetailModel.m
//  21cbh_iphone

//  五档明细接口模型

//  Created by 21tech on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "fiveAndDetailModel.h"

@implementation fiveAndDetailModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.one = [dic objectForKey:@"one"];  // 第一列 五档代表排序号，明细代表成交时间
        if (!self.one||![self.one isKindOfClass:[NSString class]]) {
            self.one=@"";
        }
        self.two = [dic objectForKey:@"two"];  // 第二列 五档表示买卖盘价，明细表示及时成交价
        if (!self.two||![self.two isKindOfClass:[NSString class]]) {
            self.two=@"";
        }
        self.three = [dic objectForKey:@"three"];  // 第三列 五档中表示买卖盘挂单手数，明细中表示及时成交手数
        if (!self.three||![self.three isKindOfClass:[NSString class]]) {
            self.three=@"";
        }
        self.priceType = [dic objectForKey:@"priceType"];  // 取值-1,0,1  跌=-1 涨=1 其他=0
        if (!self.priceType||![self.priceType isKindOfClass:[NSString class]]) {
            self.priceType=@"";
        }
    }
    return self;
}
@end
