//
//  DLabel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLabel : UIView
{
    NSMutableAttributedString* _string;
    UIFont* _font;
    UIColor* _textColor;
}

@property (nonatomic, retain) NSMutableAttributedString* string;
@property (nonatomic, retain) UIFont* font;
@property (nonatomic, retain) UIColor* textColor;

- (void)setText:(NSString*)text;

@end
