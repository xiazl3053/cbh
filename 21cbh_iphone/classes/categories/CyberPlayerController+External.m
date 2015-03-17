//
//  CyberPlayerController+External.m
//  Player
//
//  Created by qinghua on 14-12-24.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "CyberPlayerController+External.h"
#import <objc/runtime.h>

static const void *NowVoice = &NowVoice;

@implementation CyberPlayerController (External)

- (NSString *)nowVoice{
    return objc_getAssociatedObject(self, NowVoice);
}

- (void)setNowVoice:(NSString *)nowVoice{
    objc_setAssociatedObject(self, NowVoice, nowVoice, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
