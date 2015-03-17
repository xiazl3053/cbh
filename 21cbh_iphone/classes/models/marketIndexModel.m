//
//  marketIndexModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "marketIndexModel.h"

@implementation marketIndexModel


-(id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.marketId = [dic objectForKey:@"marketId"];
        if (!self.marketId||![self.marketId isKindOfClass:[NSString class]]) {
            self.marketId=@"";
        }
        self.marketName = [dic objectForKey:@"marketName"];
        if (!self.marketName||![self.marketName isKindOfClass:[NSString class]]) {
            self.marketName=@"";
        }
        self.totalValue = [dic objectForKey:@"totalValue"];
        if (!self.totalValue||![self.totalValue isKindOfClass:[NSString class]]) {
            self.totalValue=@"";
        }
        self.changeValue = [dic objectForKey:@"changeValue"];
        if (!self.changeValue||![self.changeValue isKindOfClass:[NSString class]]) {
            self.changeValue=@"";
        }
        self.changeRate = [dic objectForKey:@"changeRate"];
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
    }
    return self;
}

#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.marketId forKey:@"marketId"];
    [aCoder encodeObject:self.marketName forKey:@"marketName"];
    [aCoder encodeObject:self.totalValue forKey:@"totalValue"];
    [aCoder encodeObject:self.changeValue forKey:@"changeValue"];
    [aCoder encodeObject:self.changeRate forKey:@"changeRate"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.marketId = [[aDecoder decodeObjectForKey:@"marketId"] copy];
    self.marketName = [[aDecoder decodeObjectForKey:@"marketName"] copy];
    self.totalValue = [[aDecoder decodeObjectForKey:@"totalValue"] copy];
    self.changeValue = [[aDecoder decodeObjectForKey:@"changeValue"] copy];
    self.changeRate = [[aDecoder decodeObjectForKey:@"changeRate"] copy];
    return self;
}

@end
