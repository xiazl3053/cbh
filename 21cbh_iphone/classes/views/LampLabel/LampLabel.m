//
//  Lamp.m
//  Player
//
//  Created by qinghua on 14-12-18.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "LampLabel.h"

@implementation LampLabel

@synthesize motionWidth;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        motionWidth = 120;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.layer removeAllAnimations];
}

-(void)addAnimation{
    float w  = self.frame.size.width;
    
    //    if (w<=motionWidth) {
    //        return;
    //    }
    
    CGRect frame = self.frame;
    frame.origin.x = 137;
    self.frame = frame;
    
    [UIView beginAnimations:@"testAnimation" context:NULL];
    [UIView setAnimationDuration:8.0f * (w<160?160:w) / 160.0 ];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationRepeatCount: LONG_MAX];
    
    frame = self.frame;
    frame.origin.x = -w ;
    self.frame = frame;
    [UIView commitAnimations];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"%s",__FUNCTION__);
}

-(void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"%s",__FUNCTION__);
}

-(void)stopAnimation{
    [self.layer removeAllAnimations];
    CGRect rect=self.frame;
    rect.origin.x=0;
    self.frame=rect;
    NSLog(@"%@",NSStringFromCGRect(self.frame));
}

-(void)startAnimation{
   // [self drawRect:self.frame];
    [self.layer removeAllAnimations];
    [self addAnimation];
}

@end
