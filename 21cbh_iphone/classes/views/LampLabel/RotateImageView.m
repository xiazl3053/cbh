//
//  RotateImageView.m
//  21cbh_iphone
//
//  Created by qinghua on 15-1-8.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "RotateImageView.h"

@implementation RotateImageView


-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        //[self addAnimation];
    }
    
    return self;
}

-(void)addAnimation{

    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 2.0f;
    fullRotation.repeatCount = MAXFLOAT;
    
    [self.layer addAnimation:fullRotation forKey:@"360"];
}

-(void)stopAnimating{
    [super stopAnimating];
    [self.layer removeAllAnimations];
    self.hidden=YES;
}
-(void)startAnimating{
    [self.layer removeAllAnimations];
    [super startAnimating];
    [self addAnimation];
    self.hidden=NO;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //动画的参数设定
//    [UIView beginAnimations:@"animation" context:nil];
//    [UIView setAnimationDuration:2];
//    //设定动画开始时的图片状态（当前状态）
//    //[UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationRepeatAutoreverses:NO];
//    [UIView setAnimationRepeatCount: LONG_MAX];
//    
//    //设定动画结束时的图片状态（透明度与缩放比例）
//    self.transform = CGAffineTransformScale(self.transform , -1.0, -1.0);
//    
//    //产生动画
//    [UIView commitAnimations];
    
}


@end
