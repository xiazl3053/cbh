//
//  NewsDetailModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsDetailModel.h"

@implementation NewsDetailModel

- (id)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.type=[dict objectForKey:@"type"];
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"0";
        }
        self.articleId=[dict objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.followNum=[dict objectForKey:@"followNum"];
        if (!self.followNum||![self.followNum isKindOfClass:[NSString class]]) {
            self.followNum=@"";
        }
        self.title=[dict objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.articUrl=[dict objectForKey:@"articUrl"];
        if (!self.articUrl||![self.articUrl isKindOfClass:[NSString class]]) {
            self.articUrl=@"";
        }
        self.sharePic=[dict objectForKey:@"sharePic"];
        if (!self.sharePic||![self.sharePic isKindOfClass:[NSString class]]) {
            self.sharePic=@"";
        }
        self.picUrls=[dict objectForKey:@"picUrls"];
        if (!self.picUrls||![self.picUrls isKindOfClass:[NSArray class]]) {
            self.picUrls=[NSArray array];
        }
        self.descs=[dict objectForKey:@"descs"];
        if (!self.descs||![self.descs isKindOfClass:[NSArray class]]) {
            self.descs=[NSArray array];
        }
        self.template=[dict objectForKey:@"template"];
        if (!self.template||![self.template isKindOfClass:[NSString class]]) {
            self.template=@"";
        }
        self.body=[dict objectForKey:@"body"];
        if (!self.body||![self.body isKindOfClass:[NSString class]]) {
            self.body=@"";
        }
        self.addtime=[dict objectForKey:@"addtime"];
        if (!self.addtime||![self.addtime isKindOfClass:[NSString class]]) {
            self.addtime=@"";
        }
        self.breif=[dict objectForKey:@"breif"];
        if (!self.breif||![self.breif isKindOfClass:[NSString class]]) {
            self.breif=@"";
        }
        
    }
    return self;
}


@end
