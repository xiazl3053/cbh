//
//  UIColor+helper.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class colorModel;
@interface UIColor (helper)

+ (UIColor *) colorWithHexString: (NSString *)color withAlpha:(CGFloat)alpha;
+ (colorModel *) RGBWithHexString: (NSString *)color withAlpha:(CGFloat)alpha;

@end
