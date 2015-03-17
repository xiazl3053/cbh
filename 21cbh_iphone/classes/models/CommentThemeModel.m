//
//  CommentThemeModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentThemeModel.h"

@implementation CommentThemeModel

-(id)initWithNSDictionary:(NSDictionary *)dic{
    if (self=[super init]) {
        
        self.programID=[dic objectForKey:@"programId"];
        if (!self.programID||![self.programID isKindOfClass:[NSString class]]) {
            self.programID=@"";
        }
        self.shareUrl=[dic objectForKey:@"url"];
        if (!self.shareUrl||![self.shareUrl isKindOfClass:[NSString class]]) {
            self.shareUrl=@"";
        }
        self.articleId=[dic objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.picsId=[dic objectForKey:@"picsId"];
        if (!self.picsId||![self.picsId isKindOfClass:[NSString class]]) {
            self.picsId=@"";
        }
        self.title=[dic objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.sharePic=[dic objectForKey:@"sharePic"];
        if (!self.sharePic||![self.sharePic isKindOfClass:[NSString class]]) {
            self.sharePic=@"";
        }
    }

    return self;
}


@end
