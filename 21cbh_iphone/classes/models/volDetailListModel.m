//
//  volDetailListModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "volDetailListModel.h"

@implementation volDetailListModel

-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.time = [dic objectForKey:@"time"];  // 时间
        if (!self.time||![self.time isKindOfClass:[NSString class]]) {
            self.time=@"";
        }
        self.price = [dic objectForKey:@"price"];  // 成交价
        if (!self.price||![self.price isKindOfClass:[NSString class]]) {
            self.price=@"";
        }
        self.vol = [dic objectForKey:@"vol"]; // 成交量
        if (!self.vol||![self.vol isKindOfClass:[NSString class]]) {
            self.vol=@"";
        }
    }
    return self;
}

@end
