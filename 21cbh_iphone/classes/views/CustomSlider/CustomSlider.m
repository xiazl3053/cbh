//
//  CustomSlider.m
//  21cbh_iphone
//
//  Created by qinghua on 15-1-29.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

#pragma mark -去除左右空隙
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.x = rect.origin.x - 5 ;
    rect.size.width = rect.size.width +10;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds{
    return CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

-(CGRect)maximumValueImageRectForBounds:(CGRect)bounds{
    return CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

#pragma mark -定义slider.track.rect
-(CGRect)trackRectForBounds:(CGRect)bounds
{
    bounds.origin.x=15;
    bounds.origin.y=(bounds.size.height-3.5)*.5;
    //bounds.size.height=bounds.size.height/5;
    bounds.size.height=3.5;
    bounds.size.width=bounds.size.width-30;
    return bounds;
}

@end
