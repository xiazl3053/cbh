//
//  ZXTabbar.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZXTabbarDelegate <NSObject>
- (void)tabbarItemChangeFrom:(int)from to:(int)to;
@end

@interface ZXTabbar : UIView
// items ： 有多少个标签
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@property (nonatomic, assign) id<ZXTabbarDelegate> delegate;

@end
