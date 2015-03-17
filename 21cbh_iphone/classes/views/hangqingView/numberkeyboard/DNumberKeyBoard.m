//
//  DNumberKeyBoard.m
//  21cbh_iphone
//
//  Created by 21tech on 14-4-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "DNumberKeyBoard.h"

@interface DNumberKeyBoard ()

@end


@implementation DNumberKeyBoard

@synthesize delegate = _delegate;

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
