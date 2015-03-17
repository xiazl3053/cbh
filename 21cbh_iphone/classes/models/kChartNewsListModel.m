//
//  kChartNewsListModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kChartNewsListModel.h"

@implementation kChartNewsListModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.ids = [dic objectForKey:@"id"]; // 资讯id
        if (!self.ids||![self.ids isKindOfClass:[NSString class]]) {
            self.ids=@"";
        }
        self.programId = [dic objectForKey:@"programId"]; // 资讯类型Id
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.title = [dic objectForKey:@"title"]; // 资讯标题
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.time = [dic objectForKey:@"time"]; // 发布时间
        if (!self.time||![self.time isKindOfClass:[NSString class]]) {
            self.time=@"";
        }
    }
    return self;
}

@end
