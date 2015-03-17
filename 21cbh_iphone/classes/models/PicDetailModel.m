//
//  PicDetailModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicDetailModel.h"

@implementation PicDetailModel

- (id)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        self.desc=[dict objectForKey:@"desc"];
        if (!self.desc||![self.desc isKindOfClass:[NSString class]]) {
            self.desc=@"";
        }
        self.picUrls=[dict objectForKey:@"picUrls"];
        if (!self.picUrls||![self.picUrls isKindOfClass:[NSArray class]]) {
            self.picUrls=[NSArray array];
        }
    }
    return self;
}

@end
