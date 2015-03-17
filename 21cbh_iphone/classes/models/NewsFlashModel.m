//
//  NewsFlashModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsFlashModel.h"

@implementation NewsFlashModel

- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.articleId=[dict objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.title=[dict objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
    }
    return self;
}

@end
