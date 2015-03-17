//
//  AdBarModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "AdBarModel.h"

@implementation AdBarModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.adId=[dict objectForKey:@"adId"];
        if (!self.adId||![self.adId isKindOfClass:[NSString class]]) {
            self.adId=@"";
        }
        self.picUrl=[dict objectForKey:@"picUrl"];
        if (!self.picUrl||![self.picUrl isKindOfClass:[NSString class]]) {
            self.picUrl=@"";
        }
        self.adUrl=[dict objectForKey:@"adUrl"];
        if (!self.adUrl||![self.adUrl isKindOfClass:[NSString class]]) {
            self.adUrl=@"";
        }
    }
    return self;
}


@end
