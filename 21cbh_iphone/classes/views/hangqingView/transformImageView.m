//
//  transformImageView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "transformImageView.h"

#define degreesToRadians(x) (M_PI*(x))
#define KRotateSpeed 0.2

enum {
    enSvCropClip,               // the image size will be equal to orignal image, some part of image may be cliped
    enSvCropExpand,             // the image size will expand to contain the whole image, remain area will be transparent
};
typedef NSInteger SvCropMode;


@interface transformImageView(){
    UITapGestureRecognizer *tap;
    int count;
    BOOL isRuning;
}

@end

@implementation transformImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
// 听说要隐藏掉，那就隐藏吧
        
//        angle = 0;
//        isStop = YES;
//        UIImage *image = [UIImage imageNamed:@"D_Refresh.png"];
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, image.size.width, image.size.height);
//        self.image = image;
//        self.userInteractionEnabled = YES;
//        if (!tap) {
//            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction)];
//            [self addGestureRecognizer:tap];
//        }
        
    }
    return self;
}

-(void)dealloc{
    [self removeGestureRecognizer:tap];
}

#pragma mark ---------------------------自定义方法--------------------------
#pragma mark 开始旋转
-(void)start{
    // 旋转停止后才开始
//    if (isStop) {
//        isStop = NO;
//        count = 10; // 防止死循环转个不停
//        
//        [self transformAction];
//    }
}
#pragma mark 图片旋转
-(void)transformAction {
    [self.layer removeAllAnimations];
    //旋转动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform" ];
    animation.delegate = self;
    CATransform3D tans3D = self.layer.transform;
    tans3D = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);//180度
    animation.toValue = [NSValue valueWithCATransform3D:tans3D];
    animation.duration = KRotateSpeed;
    animation.cumulative = YES;
    animation.repeatCount = 4;
    [self.layer addAnimation:animation forKey:@"animation"];
}
#pragma mark 旋转停止
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    count -= 1;
    if (!isStop && count>0) {
        [self transformAction];
    }else{
        [self.layer removeAllAnimations];
    }
}
#pragma mark 停止旋转
-(void)stop{
    isStop = YES;
}
#pragma mark 点击旋转图片
-(void)clickAction{
    if (self.clickActionBlock) {
        [self start];
        self.clickActionBlock(self);
    }
}


@end
