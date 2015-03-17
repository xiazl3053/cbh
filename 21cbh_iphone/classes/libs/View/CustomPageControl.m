//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

-(id) initWithFrame:(CGRect)frame activeImage:(UIImage*)activeImage inactiveImage:(UIImage*)inactiveImage
{
    self = [super initWithFrame:frame];
    if(self)
    {
        activeImage_ = [activeImage retain];
        inactiveImage_ = [inactiveImage retain];
        [self setCurrentPage:1];
    }
    return self;
}

-(void) updateDots
{
    int count=[self.subviews count];
    for (int i = 0; i < count; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if([dot isKindOfClass:[UIImageView class]])
        {
            if (i == self.currentPage)
                dot.image = activeImage_;
            else 
                dot.image = inactiveImage_;
        }
    }
}

-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self updateDots];
}

-(void)dealloc
{
    [activeImage_ release];
    [inactiveImage_ release];
    [super dealloc];
}

@end
