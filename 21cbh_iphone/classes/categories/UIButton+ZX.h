//
//  UIButton+ZX.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ZX.h"

@interface UIButton (ZX)
#pragma mark 设置背景
- (void)setNormalBg:(NSString *)normalName;
- (void)setHighlightedBg:(NSString *)HighlightedName;
- (void)setSelectedBg:(NSString *)selectedName;
- (void)setNormalBg:(NSString *)normalName andHighlighted:(NSString *)HighlightedName;
@end
