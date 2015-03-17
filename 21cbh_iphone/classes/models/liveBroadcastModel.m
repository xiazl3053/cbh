//
//  liveBroadcastModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-5-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "liveBroadcastModel.h"

@implementation liveBroadcastModel

- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        self.liveType=[dict objectForKey:@"liveType"];
        if (!self.liveType||![self.liveType isKindOfClass:[NSString class]]) {
            self.liveType=@"";
        }
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.articleId=[dict objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.addtime=[dict objectForKey:@"addtime"];
        if (!self.addtime||![self.addtime isKindOfClass:[NSString class]]) {
            self.addtime=@"";
        }
        self.desc=[dict objectForKey:@"desc"];
        if (!self.desc||![self.desc isKindOfClass:[NSString class]]) {
            self.desc=@"";
        }
        
    }
    
    return self;
}

@end
