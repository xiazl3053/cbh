//
//  MaskView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MaskView.h"

@implementation MaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _alpha = 0.5;
        [self initViews];
    }
    return self;
}


- (id)initWithAlpha:(CGFloat)alpha
{
    self = [super init];
    if (self) {
        _alpha = alpha;
        [self initViews];
    }
    return self;
}

-(void)dealloc{
    self.sportView = nil;
    self.mainBody = nil;
    self.hideFinishBlock = nil;
}

-(void)initViews{
    self.frame = CGRectMake(0, 0, KScreenSize.width, KScreenSize.height);
    self.backgroundColor = ClearColor;
    if (!self.sportView) {
        CGFloat h = 150;
        CGFloat w = self.frame.size.width;
        CGFloat y = self.frame.size.height + h;
        CGFloat x = 0;
    
        self.mainBody = [[UIView alloc] initWithFrame:self.frame];
        self.mainBody.alpha = _alpha;
        self.mainBody.backgroundColor = UIColorFromRGB(0x000000);
        [self addSubview:self.mainBody];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self.mainBody addGestureRecognizer:tap];
        tap = nil;
        
        self.sportView = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
        self.sportView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [self addSubview:self.sportView];
        
    }
   
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)show:(void (^)(void))animations{
    CGRect frame = self.sportView.frame;
    frame.origin.y = KScreenSize.height - frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.sportView.frame = frame;
        self.mainBody.alpha = _alpha;
    } completion:^(BOOL finish){
        if (animations) {
            animations();
        }
    }];
}

-(void)hide{
    CGRect frame = self.sportView.frame;
    frame.origin.y = KScreenSize.height + frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.sportView.frame = frame;
        self.mainBody.alpha = 0;
    } completion:^(BOOL finish){
        [self removeFromSuperview];
        if (self.hideFinishBlock) {
            self.hideFinishBlock();
        }
        
    }];
}

@end
