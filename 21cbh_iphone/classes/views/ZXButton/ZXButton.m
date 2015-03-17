//
//  ZXButton.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ZXButton.h"

#define Kinterval 3
@implementation ZXButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - 覆盖父类的2个方法
#pragma mark 设置按钮标题的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    UIImage *image =  [self imageForState:UIControlStateNormal];
    CGFloat titleY = image.size.height;
    CGFloat titleHeight = self.bounds.size.height - titleY-5;
    return CGRectMake(0, titleY+5, self.bounds.size.width,  titleHeight);
}
#pragma mark 设置按钮图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    UIImage *image =  [self imageForState:UIControlStateNormal];
    return CGRectMake(0, Kinterval+2, self.bounds.size.width, image.size.height);
}


@end
