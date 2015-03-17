//
//  PicsListModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicsListModel.h"

@implementation PicsListModel

- (id)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        
        self.picsId=[dict objectForKey:@"picsId"];
        if (!self.picsId||![self.picsId isKindOfClass:[NSString class]]) {
            self.picsId=@"";
        }
        self.type=[dict objectForKey:@"type"];
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"";
        }
        self.title=[dict objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.followNum=[NSString stringWithFormat:@"%@",[dict objectForKey:@"followNum"]];
        if (!self.followNum||![self.followNum isKindOfClass:[NSString class]]) {
            self.followNum=@"";
        }
        self.picUrls=[dict objectForKey:@"picUrls"];
        if (!self.picUrls||![self.picUrls isKindOfClass:[NSArray class]]) {
            self.picUrls=[NSArray array];
        }
        self.order=[dict objectForKey:@"order"];
        if (!self.order||![self.order isKindOfClass:[NSString class]]) {
            self.order=@"";
        }
        self.addtime=[dict objectForKey:@"addtime"];
        if (!self.addtime||![self.addtime isKindOfClass:[NSString class]]) {
            self.addtime=@"";
        }
    }
    return self;
}


@end
