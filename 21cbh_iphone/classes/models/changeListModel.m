//
//  changeListModel.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "changeListModel.h"

@implementation changeListModel
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
        self.newestValue = [dic objectForKey:@"newestValue"];
        if (!self.newestValue||![self.newestValue isKindOfClass:[NSString class]]) {
            self.newestValue=@"";
        }
        self.changeRate = [dic objectForKey:@"changeRate"];
        if (!self.changeRate||![self.changeRate isKindOfClass:[NSString class]]) {
            self.changeRate=@"";
        }
        self.changeValue = [dic objectForKey:@"changeValue"];
        if (!self.changeValue||![self.changeValue isKindOfClass:[NSString class]]) {
            self.changeValue=@"";
        }
    }
    return self;
}

#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.marketId forKey:@"marketId"];
    [aCoder encodeObject:self.marketName forKey:@"marketName"];
    [aCoder encodeObject:self.newestValue forKey:@"newestValue"];
    [aCoder encodeObject:self.changeValue forKey:@"changeValue"];
    [aCoder encodeObject:self.changeRate forKey:@"changeRate"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.marketId = [[aDecoder decodeObjectForKey:@"marketId"] copy];
    self.marketName = [[aDecoder decodeObjectForKey:@"marketName"] copy];
    self.newestValue = [[aDecoder decodeObjectForKey:@"newestValue"] copy];
    self.changeValue = [[aDecoder decodeObjectForKey:@"changeValue"] copy];
    self.changeRate = [[aDecoder decodeObjectForKey:@"changeRate"] copy];
    return self;
}

@end
