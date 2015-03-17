//
//  selfMarketMessageModel.m
//  21cbh_iphone
//
//  Created by Franky on 14-4-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "selfMarketMessageModel.h"

@implementation selfMarketMessageModel

-(id)initWithNSDictonary:(NSDictionary *)dic
{
    if(self=[super init])
    {
        self.msgId=[dic objectForKey:@"id"];
        if (!self.msgId||![self.msgId isKindOfClass:[NSString class]]) {
            self.msgId=@"";
        }
        self.type=[dic objectForKey:@"type"];
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"";
        }
        self.title=[dic objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.date=[dic objectForKey:@"date"];
        if (!self.date||![self.date isKindOfClass:[NSString class]]) {
            self.date=@"";
        }
        self.time=[dic objectForKey:@"time"];
        if (!self.time||![self.time isKindOfClass:[NSString class]]) {
            self.time=@"";
        }
        self.marketId=[dic objectForKey:@"marketId"];
        if (!self.marketId||![self.marketId isKindOfClass:[NSString class]]) {
            self.marketId=@"";
        }
        self.marketName=[dic objectForKey:@"marketName"];
        if (!self.marketName||![self.marketName isKindOfClass:[NSString class]]) {
            self.marketName=@"";
        }
        self.marketType=[dic objectForKey:@"marketType"];
        if (!self.marketType||![self.marketType isKindOfClass:[NSString class]]) {
            self.marketType=@"";
        }
        self.isRead=[dic objectForKey:@"isRead"];
        if (!self.isRead||![self.isRead isKindOfClass:[NSString class]]) {
            self.isRead=@"";
        }
        self.newsId=[dic objectForKey:@"newsId"];
        if (!self.newsId||![self.newsId isKindOfClass:[NSString class]]) {
            self.newsId=@"";
        }
        self.programId=[dic objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
    }
    return self;
}

@end
