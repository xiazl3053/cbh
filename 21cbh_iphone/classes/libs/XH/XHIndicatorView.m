//
//  XHIndicatorView.m
//  XHScrollMenu
//
//  Created by 周晓 on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XHIndicatorView.h"

@implementation XHIndicatorView

- (void)setIndicatorWidth:(CGFloat)indicatorWidth {
    _indicatorWidth = indicatorWidth;
    CGRect indicatorRect = self.frame;
    indicatorRect.size.width = _indicatorWidth;
    self.frame = indicatorRect;
}

+ (instancetype)initIndicatorView {
    XHIndicatorView *indicatorView = [[XHIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 70, kXHIndicatorViewHeight)];
    return indicatorView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor =UIColorFromRGB(0xe86e25);
    }
    return self;
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
