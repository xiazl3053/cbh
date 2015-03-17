//
//  UIView+Custom.h
//   
//
//  Created by gzty1 on 12-3-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+Custom.h"
#import <QuartzCore/QuartzCore.h>
#import "UIResponder+Custom.h"

@implementation UIView (Custom)

-(CGRect)setFrameOffsetX:(CGFloat)dx y:(CGFloat)dy
{
    CGRect rect=self.frame;
    rect=CGRectOffset(rect, dx, dy);
    self.frame=rect;
    return rect;
}

-(CGRect)setFrameSizeInsetWidth:(CGFloat)dx height:(CGFloat)dy
{
    CGRect rect=self.frame;
    rect.size.width+=dx;
    rect.size.height+=dy;
    self.frame=rect;
    return rect;
}

-(BOOL)getOriginInSuperView:(UIView*)theSuperView resultOrigin:(CGPoint*)resultOrigin
{
    BOOL found=NO;
    if(!theSuperView)
    {
        found=YES;
    }
    
    UIView* superView=[self superview];
    (*resultOrigin)=self.frame.origin;
	
	while (superView) 
	{
		CGPoint point=CGPointZero;
		if([superView isKindOfClass:[UIScrollView class]])
		{
			UIScrollView* scrollView=(UIScrollView*)superView;
			point=scrollView.contentOffset;
		}
		
		CGRect superFrame=superView.frame;
        (*resultOrigin).x+=superFrame.origin.x-point.x;
		(*resultOrigin).y+=superFrame.origin.y-point.y;
		
		if(superView==theSuperView)
		{
            found=YES;
			break;
		}
		else
		{
			superView=[superView superview];
		}
	}
    
    return found;
}

-(void)clearBoundsPathShadow
{
     [self setBoundsPathShadowColor:nil radius:0.0];
}

-(void)setBoundsPathShadow
{
    [self setBoundsPathShadowColor:[UIColor blackColor] radius:10.0];
}

-(void)setBoundsPathShadowColor:(UIColor*)color radius:(float)radius
{
    if(color)
    {
        self.layer.shadowColor = [color CGColor];
    }
    else 
    {
        self.layer.shadowColor = [[UIColor clearColor] CGColor];
    }
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    if([[self firstViewController] isKindOfClass:[UINavigationController class]])
    {
        if(color)
        {
            self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        }
        else 
        {
            self.layer.shadowPath = nil;
        }
        //self.layer.shouldRasterize = NO;
        //self.layer.cornerRadius = radius;
    }
}

-(UIImage*)imageInRect:(CGRect)rect
{
    CGPoint pt = rect.origin;
    UIImage *screenImage;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context,  CGAffineTransformMakeTranslation(-(int)pt.x, -(int)pt.y));
    [self.layer renderInContext:context];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

- (NSMutableArray*)allSubViews
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    [arr addObject:self];
    for (UIView *subview in self.subviews)
    {
        [arr addObjectsFromArray:(NSArray*)[subview allSubViews]];
    }
    return [arr autorelease];
}

@end