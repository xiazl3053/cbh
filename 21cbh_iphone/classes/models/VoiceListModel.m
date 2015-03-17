//
//  VoiceListModel.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-5.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "VoiceListModel.h"

@implementation VoiceListModel


- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        self.requestId=[dict objectForKey:@"requestId"];
        if (!self.requestId||![self.requestId isKindOfClass:[NSString class]]) {
            self.requestId=@"";
        }
        self.programId=[dict objectForKey:@"programId"];
        if (!self.programId||![self.programId isKindOfClass:[NSString class]]) {
            self.programId=@"";
        }
        self.articleId=[dict objectForKey:@"articleId"];
        if (!self.articleId||![self.articleId isKindOfClass:[NSString class]]) {
            self.articleId=@"";
        }
        self.duration=[dict objectForKey:@"duration"];
        if (!self.duration||![self.duration isKindOfClass:[NSString class]]) {
            self.duration=@"";
        }
        self.title=[dict objectForKey:@"title"];
        if (!self.title||![self.title isKindOfClass:[NSString class]]) {
            self.title=@"";
        }
        self.voiceUrl=[dict objectForKey:@"voiceUrl"];
        if (!self.voiceUrl||![self.voiceUrl isKindOfClass:[NSString class]]) {
            self.voiceUrl=@"";
        }
        self.size=[dict objectForKey:@"size"];
        if (!self.size||![self.size isKindOfClass:[NSString class]]) {
            self.size=@"";
        }
        self.order=[dict objectForKey:@"order"];
        if (!self.order||![self.order isKindOfClass:[NSString class]]) {
            self.order=@"";
        }
        self.addtime=[dict objectForKey:@"addtime"];
        if (!self.addtime||![self.addtime isKindOfClass:[NSString class]]) {
            self.addtime=@"";
        }
        
        //默认设置为0
        self.isDownLoad=@"0";
        //默认设置为2
        self.downloadstus=2;
    }
    
    return self;
}


@end
