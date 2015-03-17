//
//  analystListModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "analystListModel.h"

@implementation analystListModel
-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.ids = [dic objectForKey:@"id"]; // 资讯id
        if (!self.ids||![self.ids isKindOfClass:[NSString class]]) {
            self.ids=@"";
        }
        self.title = [dic objectForKey:@"title"]; // 分析师标题
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.pdf = [dic objectForKey:@"pdf"]; // Pdf文件地址
        if (!self.pdf||![self.pdf isKindOfClass:[NSString class]]) {
            self.pdf=@"";
        }
        self.comeFrom = [dic objectForKey:@"comefrom"];// 报告来源
        if (!self.comeFrom||![self.comeFrom isKindOfClass:[NSString class]]) {
            self.comeFrom=@"";
        }
        self.date = [dic objectForKey:@"date"]; // 撰写日期
        if (!self.date||![self.date isKindOfClass:[NSString class]]) {
            self.date=@"";
        }
        self.author = [dic objectForKey:@"author"]; // 报告作者
        if (!self.author||![self.author isKindOfClass:[NSString class]]) {
            self.author=@"";
        }
        self.area = [dic objectForKey:@"area"]; // 所属领域
        if (!self.area||![self.area isKindOfClass:[NSString class]]) {
            self.area=@"";
        }
        self.level = [dic objectForKey:@"level"]; // 评级
        if (!self.level||![self.level isKindOfClass:[NSString class]]) {
            self.level=@"";
        }
        self.levelChange = [dic objectForKey:@"levelChange"]; // 评级调整
        if (!self.levelChange||![self.levelChange isKindOfClass:[NSString class]]) {
            self.levelChange=@"";
        }
        self.targetPrice = [dic objectForKey:@"targetPrice"]; // 目标价
        if (!self.targetPrice||![self.targetPrice isKindOfClass:[NSString class]]) {
            self.targetPrice=@"";
        }
        self.content = [dic objectForKey:@"content"]; // 核心观点简介
        if (!self.content||![self.content isKindOfClass:[NSString class]]) {
            self.content=@"";
        }
        self.hits = [dic objectForKey:@"hits"]; // 阅读量
        if (!self.hits||![self.hits isKindOfClass:[NSString class]]) {
            self.hits=@"";
        }
    }
    return self;
}
@end
