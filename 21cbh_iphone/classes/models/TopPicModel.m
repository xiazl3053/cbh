//
//  TopPicModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "TopPicModel.h"

@implementation TopPicModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.picUrl=[dict objectForKey:@"picUrl"];
        if (!self.picUrl||![self.picUrl isKindOfClass:[NSString class]]) {
            self.picUrl=@"";
        }
        self.desc=[dict objectForKey:@"desc"];
        if (!self.desc||![self.desc isKindOfClass:[NSString class]]) {
            self.desc=@"";
        }
        self.type=[dict objectForKey:@"type"];
        if (!self.type||![self.type isKindOfClass:[NSString class]]) {
            self.type=@"";
        }
        self.articleId=[dict objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.specialId=[dict objectForKey:@"specialId"];
        if (!self.specialId||![self.specialId isKindOfClass:[NSString class]]) {
            self.specialId=@"";
        }
        self.picsId=[dict objectForKey:@"picsId"];
        if (!self.picsId||![self.picsId isKindOfClass:[NSString class]]) {
            self.picsId=@"";
        }
        self.videoId=[dict objectForKey:@"videoId"];
        if (!self.videoId||![self.videoId isKindOfClass:[NSString class]]) {
            self.videoId=@"";
        }
        self.adId=[dict objectForKey:@"adId"];
        if (!self.adId||![self.adId isKindOfClass:[NSString class]]) {
            self.adId=@"";
        }
        self.adUrl=[dict objectForKey:@"adUrl"];
        if (!self.adUrl||![self.adUrl isKindOfClass:[NSString class]]) {
            self.adUrl=@"";
        }
        self.videoUrl=[dict objectForKey:@"videoUrl"];
        if (!self.videoUrl||![self.videoUrl isKindOfClass:[NSString class]]) {
            self.videoUrl=@"";
        }
        self.addtime=[dict objectForKey:@"addtime"];
        if (!self.addtime||![self.addtime isKindOfClass:[NSString class]]) {
            self.addtime=@"";
        }
    }
    return self;
}


@end
