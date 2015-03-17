//
//  WebModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "AdDetaiModel.h"

@implementation AdDetaiModel

- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        self.adId=[dict objectForKey:@"adId"];
        if (!self.adId||![self.adId isKindOfClass:[NSString class]]) {
            self.adId=@"";
        }
        self.sharePic=[dict objectForKey:@"sharePic"];
        if (!self.sharePic||![self.sharePic isKindOfClass:[NSString class]]) {
            self.sharePic=@"";
        }
        self.adTitle=[dict objectForKey:@"adTitle"];
        if (!self.adTitle||![self.adTitle isKindOfClass:[NSString class]]) {
            self.adTitle=@"";
        }
        self.adUrl=[dict objectForKey:@"adUrl"];
        if (!self.adUrl||![self.adUrl isKindOfClass:[NSString class]]) {
            self.adUrl=@"";
        }
        self.type=[dict objectForKey:@"type"];
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"";
        }
    }
    
    return self;
}


@end
