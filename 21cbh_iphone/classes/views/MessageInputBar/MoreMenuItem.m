//
//  MoreMenuItem.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreMenuItem.h"

@implementation MoreMenuItem

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title{
    if (self) {
        self.normalIconImage = normalIconImage;
        self.title = title;
    }
    return self;
}

- (void)dealloc{
    self.normalIconImage = nil;
    self.title = nil;
}

@end
