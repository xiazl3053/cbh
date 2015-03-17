//
//  UIFont+Custom.m
//   V2
//
//  Created by Rocket on 12-11-7.
//  Copyright (c) 2012年 tianya. All rights reserved.
//

#import "UIFont+Custom.h"

@implementation UIFont (Custom)

static NSString* customFontName=@"HelveticaNeue";
static NSString* customBoldFontName=@"HelveticaNeue-Bold";

//设置字体名称
+ (void)setFontName:(NSString*)fontName
{
    [customFontName autorelease];
    customFontName=[fontName copy];
}

//设置粗体字体名称
+ (void)setBoldFontName:(NSString*)boldFontName
{
    [customBoldFontName autorelease];
    customBoldFontName=[boldFontName copy];
}

//使用默认字体
+ (UIFont *)getFontOfSize:(CGFloat)fontSize
{
    if ([customFontName length]>0)
    {
        return [UIFont fontWithName:customFontName size:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)getBoldFontOfSize:(CGFloat)fontSize
{
    if ([customBoldFontName length]>0)
    {
        return [UIFont fontWithName:customBoldFontName size:fontSize];
    }
    return [UIFont boldSystemFontOfSize:fontSize];
}

//直接替代系统的
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize
{
    return [UIFont getFontOfSize:fontSize];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize
{
    return [UIFont getBoldFontOfSize:fontSize];
}

@end
