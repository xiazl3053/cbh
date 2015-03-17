//
//  ZXTabbarItem.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+ZX.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@class ZXTabbarItemDesc;

@interface ZXTabbarItem : UIButton
- (id)initWithFrame:(CGRect)frame itemDesc:(ZXTabbarItemDesc *)desc;
@end

@interface ZXTabbarItemDesc : NSObject
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, copy) NSString *normal; //默认图标
@property (nonatomic, copy) NSString *highlighted; // 高亮图标

+ (id)itemWithTitle:(NSString *)title normal:(NSString *)normal highlighted:(NSString *)highlighted;
@end
