//
//  TopBar.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopBarDelegate;

@interface TopBar : UIView

@property(assign,nonatomic)id<TopBarDelegate>delegate;
@property(assign,nonatomic)NSInteger currentIndex;
@property(assign,nonatomic)UIView *line;

- (id)initWithFrame:(CGRect)frame array:(NSArray *)array btnTexNormalColor:(UIColor *)btnTexNormalColor btnTextSelectedColor:(UIColor *)btnTextSelectedColor;

@end

@protocol TopBarDelegate <NSObject>
-(void)topBarclickBtn:(UIButton *)btn;

@end