//
//  ROllLabel.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//


#import "ROllLabel.h"

@implementation ROllLabel

- (id)initWithFrame:(CGRect)frame Withsize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator   = NO;
        self.showsHorizontalScrollIndicator = NO;//水平滚动条
//        self.bounces = NO;
        self.contentSize = size;//滚动大小
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
+ (ROllLabel *)rollLabelTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font superView:(UIView *)superView fram:(CGRect)rect
{
    //文字大小，设置label的大小和uiscroll的大小
    CGSize size = [title  sizeWithFont:font constrainedToSize:kConstrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = CGRectMake(0, 0, size.width, rect.size.height);
    ROllLabel *roll = [[ROllLabel alloc]initWithFrame:rect Withsize:size];
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = title;
    label.font = font;
    label.textColor = color;
    [roll addSubview:label];
    [superView addSubview:roll];
    return roll;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
