//
//  UIImageView+Custom.m
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+Custom.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (Custom)

- (UIImageView*)initWithOriginY:(int)aY parentWidth:(int)aParentWidth image:(UIImage*)aImage 
{
	int x=(aParentWidth-aImage.size.width)/2;
	return [self initWithOrigin:CGPointMake(x,aY) image:aImage];
}

- (UIImageView*)initWithOriginY:(int)y parentWidth:(int)parentWidth width:(int)width image:(UIImage*)image
{
    if(self=[super init])
	{
		self.frame=CGRectMake((parentWidth-width)/2, y, width, image.size.height);
		[self setImage:image];
	}
	
	return self;
}


- (UIImageView*)initWithOrigin:(CGPoint)origin image:(UIImage*)aImage
{
	if(self=[super init])
	{
		UIImage* image=aImage;
		int width=image.size.width;
		int height=image.size.height;
		CGRect frame=CGRectMake(origin.x,origin.y,width,height);
		self.frame=frame;
		[self setImage:image];
    }
    
    return self;
}

- (void)makeCorner:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
//    //给图层添加一个有色边框  
//    self.layer.borderWidth = 5;
//    self.layer.borderColor = [[UIColor colorWithRed:0.52 green:0.09 blue:0.07 alpha:1] CGColor];
}

- (void)addVImage:(UIImage*)aVimg withSize:(CGSize)aSize
{
	UIView* vv=[self viewWithTag:9876];
	if (vv==nil) {
		UIImageView* vImageView=[[UIImageView alloc] initWithImage:aVimg];
		vImageView.tag=9876;
		vImageView.frame=CGRectMake(self.frame.size.width-aSize.width, self.frame.size.height-aSize.height, aSize.width, aSize.height);
		[self addSubview:vImageView];
		[vImageView release];
	}
}

- (void)removeVImage
{
	UIView* vv=[self viewWithTag:9876];
	if (vv)
	{
		[vv removeFromSuperview];
		vv=nil;
	}
}

- (void)addPhotoFrame:(CGFloat)width
{
    CALayer * layer = [self layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = width;
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 0.6;
}

- (void)setRoundHead
{
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
//    
//    // for test
//    CALayer * layer = [self layer];
//    layer.borderColor = [[UIColor redColor] CGColor];
//    layer.borderWidth = 2.0;
//    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0, 0);
//    self.layer.shadowOpacity = 0.5;
//    self.layer.shadowRadius = 0.6;
}
- (void)setCircle
{
    CGFloat width = self.frame.size.width/2;
    
    self.layer.cornerRadius = width;
    self.layer.masksToBounds = YES;
}
@end