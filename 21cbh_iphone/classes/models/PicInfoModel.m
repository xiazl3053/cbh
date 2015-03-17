//
//  PicInfoModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicInfoModel.h"

@implementation PicInfoModel

- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.picsId=[dict objectForKey:@"picsId"];
        if (!self.picsId||![self.picsId isKindOfClass:[NSString class]]) {
            self.picsId=@"";
        }
        self.title=[dict objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.sharePic=[dict objectForKey:@"sharePic"];
        if (!self.sharePic||![self.sharePic isKindOfClass:[NSString class]]) {
            self.sharePic=@"";
        }
        self.shareUrl=[dict objectForKey:@"shareUrl"];
        if (!self.shareUrl||![self.shareUrl isKindOfClass:[NSString class]]) {
            self.shareUrl=@"";
        }

    }
    
    return self;
}

@end
