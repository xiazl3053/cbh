//
//  NumberKeyBoard.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//


#import "NumberKeyBoard.h"

@implementation NumberKeyBoard

@synthesize delegate = _delegate;

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

- (IBAction) keyClick:(id) sender {
    
    UIButton* btn = (UIButton*)sender;
    
    NSString *buttonVlaue = btn.titleLabel.text;
    
    // no delegate, print log info
    if (nil == _delegate) {
        NSLog(@"button tag [%@]",buttonVlaue);
        return;
    }
    
    [_delegate numberKeyBoardInput:buttonVlaue];
}

@end
