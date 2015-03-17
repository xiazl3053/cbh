//
//  UIButton+ZX.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "UIButton+ZX.h"

@implementation UIButton (ZX)
- (void)setNormalBg:(NSString *)normalName {
    UIImage *normal = [UIImage resizeImage:normalName];
    [self setBackgroundImage:normal forState:UIControlStateNormal];
}

- (void)setHighlightedBg:(NSString *)HighlightedName {
    UIImage *highlighted = [UIImage resizeImage:HighlightedName];
    [self setBackgroundImage:highlighted forState:UIControlStateHighlighted];
}

- (void)setSelectedBg:(NSString *)selectedName {
    UIImage *highlighted = [UIImage resizeImage:selectedName];
    [self setBackgroundImage:highlighted forState:UIControlStateSelected];
}

- (void)setNormalBg:(NSString *)normalName andHighlighted:(NSString *)HighlightedName {
    [self setNormalBg:normalName];
    [self setHighlightedBg:HighlightedName];
}
@end
