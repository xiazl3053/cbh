//
//  ZXTextFiled.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ZXTextFiled.h"


@implementation ZXTextFiled

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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


-(void) drawPlaceholderInRect:(CGRect)rect {
    [_placeholderColor setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}


@end
