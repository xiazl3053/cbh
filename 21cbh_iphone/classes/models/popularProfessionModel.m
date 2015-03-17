//
//  popularProfessionModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "popularProfessionModel.h"

@implementation popularProfessionModel

-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.professionId = [dic objectForKey:@"professionId"];
        if (!self.professionId||![self.professionId isKindOfClass:[NSString class]]) {
            self.professionId=@"";
        }
        self.professionName = [dic objectForKey:@"professionName"];
        if (!self.professionName||![self.professionName isKindOfClass:[NSString class]]) {
            self.professionName=@"";
        }
        self.professionChangeRate = [dic objectForKey:@"professionChangeRate"];
        if (!self.professionChangeRate||![self.professionChangeRate isKindOfClass:[NSString class]]) {
            self.professionChangeRate=@"";
        }
        self.stockName = [dic objectForKey:@"stockName"];
        if (!self.stockName||![self.stockName isKindOfClass:[NSString class]]) {
            self.stockName=@"";
        }
        self.stockChangeRate = [dic objectForKey:@"stockChangeRate"];
        if (!self.stockChangeRate||![self.stockChangeRate isKindOfClass:[NSString class]]) {
            self.stockChangeRate=@"";
        }
    }
    return self;
}

@end
