//
//  NewListModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewListModel.h"

@implementation NewListModel//新闻列表实体类


- (id)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        self.type=[dict objectForKey:@"type"];
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"";
        }
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.articleId=[dict objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.picsId=[dict objectForKey:@"picsId"];
        if (!self.picsId||![self.picsId isKindOfClass:[NSString class]]) {
            self.picsId=@"";
        }
        self.specialId=[dict objectForKey:@"specialId"];
        if (!self.specialId||![self.specialId isKindOfClass:[NSString class]]) {
            self.specialId=@"";
        }
        self.videoId=[dict objectForKey:@"videoId"];
        if (!self.videoId||![self.videoId isKindOfClass:[NSString class]]) {
            self.videoId=@"";
        }
        self.adId=[dict objectForKey:@"adId"];
        if (!self.adId||![self.adId isKindOfClass:[NSString class]]) {
            self.adId=@"";
        }
        self.title=[dict objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.desc=[dict objectForKey:@"desc"];
        if (!self.desc||![self.desc isKindOfClass:[NSString class]]) {
            self.desc=@"";
        }
        self.followNum=[dict objectForKey:@"followNum"];
        if (!self.followNum||![self.followNum isKindOfClass:[NSString class]]) {
            self.followNum=@"";
        }
        self.adUrl=[dict objectForKey:@"adUrl"];
        if (!self.adUrl||![self.adUrl isKindOfClass:[NSString class]]) {
            self.adUrl=@"";
        }
        self.videoUrl=[dict objectForKey:@"videoUrl"];
        if (!self.videoUrl||![self.videoUrl isKindOfClass:[NSString class]]) {
            self.videoUrl=@"";
        }
        self.order=[dict objectForKey:@"order"];
        if (!self.order||![self.order isKindOfClass:[NSString class]]) {
            self.order=@"";
        }
        self.addtime=[dict objectForKey:@"addtime"];
        if (!self.addtime||![self.addtime isKindOfClass:[NSString class]]) {
            self.addtime=@"";
        }
        self.picUrls=[dict objectForKey:@"picUrls"];
        if (!self.picUrls||![self.picUrls isKindOfClass:[NSArray class]]) {
            self.picUrls=[NSArray array];
        }

    }
    return self;
}


@end
