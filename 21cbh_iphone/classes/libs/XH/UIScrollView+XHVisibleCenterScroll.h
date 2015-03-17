//
//  UIScrollView+XHVisibleCenterScroll.h
//  XHScrollMenu
//
//  Created by 周晓 on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (XHVisibleCenterScroll)

- (void)scrollRectToVisibleCenteredOn:(CGRect)visibleRect
                             animated:(BOOL)animated;

@end
