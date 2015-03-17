//
//  UIFont+Custom.h
//   V2
//
//  Created by Rocket on 12-11-7.
//  Copyright (c) 2012年 tianya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Custom)

//设置字体名称
+ (void)setFontName:(NSString*)fontName;
//设置粗体字体名称
+ (void)setBoldFontName:(NSString*)boldFontName;

//使用默认字体
+ (UIFont *)getFontOfSize:(CGFloat)fontSize;
+ (UIFont *)getBoldFontOfSize:(CGFloat)fontSize;

@end
