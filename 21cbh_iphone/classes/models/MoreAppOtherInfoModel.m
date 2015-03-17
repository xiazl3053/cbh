//
//  MoreAppAdModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreAppOtherInfoModel.h"

@implementation MoreAppOtherInfoModel

-(id)initWithNSDictonary:(NSDictionary *)dic{
    if (self=[super init]) {
        self.advImageUrl=[dic objectForKey:@"advImgUrl"];
        if (!self.advImageUrl||![self.advImageUrl isKindOfClass:[NSString class]]) {
            self.advImageUrl=@"";
        }
        self.adActionUrl=[dic objectForKey:@"advActionUrl"];
        if (!self.adActionUrl||![self.adActionUrl isKindOfClass:[NSString class]]) {
            self.adActionUrl=@"";
        }
        self.pageCount=[dic objectForKey:@"pageCount"];
        if (!self.pageCount||![self.pageCount isKindOfClass:[NSString class]]) {
            self.pageCount=@"";
        }
    }
    return self;
}


@end
