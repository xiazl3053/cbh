//
//  ROllLabel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//


#import <UIKit/UIKit.h>
#define kConstrainedSize CGSizeMake(10000,40)//字体最大
@interface ROllLabel : UIScrollView
/*title,要显示的文字
 *color,文字颜色
 *font , 字体大小
 *superView,要加载标签的视图
 *rect ,标签的frame
 */
+ (ROllLabel *)rollLabelTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font superView:(UIView *)superView fram:(CGRect)rect;
@end
