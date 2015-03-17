//
//  UIImageView+Custom.h
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Custom.h"

@interface UIImageView (Custom)

- (UIImageView*)initWithOriginY:(int)aY
				   parentWidth:(int)aParentWidth 
						 image:(UIImage*)aImage;

//width 图片固定宽度，parentWidth 父容器宽度，y 在父容器中的y值，
- (UIImageView*)initWithOriginY:(int)y parentWidth:(int)parentWidth width:(int)width image:(UIImage*)image;

- (UIImageView*)initWithOrigin:(CGPoint)origin 
						image:(UIImage*)aImage;

- (void)makeCorner:(CGFloat)cornerRadius;

- (void)addVImage:(UIImage*)aVimg withSize:(CGSize)aSize;

- (void)removeVImage;

- (void)addPhotoFrame:(CGFloat)width;

- (void)setRoundHead;//设置为圆角
- (void)setCircle;//设置为圆形

@end


