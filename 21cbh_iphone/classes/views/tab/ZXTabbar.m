//
//  ZXTabbar.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "ZXTabbar.h"
#import "ZXTabbarItem.h"

@interface ZXTabbar() {
    // 当前被选中的tabbaritem
    ZXTabbarItem *_current;
}
@end

@implementation ZXTabbar

#pragma mark item点击
- (void)itemClick:(ZXTabbarItem *)new {
    // 设置selected为YES，就能达到UIControlStateSelected状态
    if (_current != new) {
        if ([self.delegate respondsToSelector:@selector(tabbarItemChangeFrom:to:)]) {
            [self.delegate tabbarItemChangeFrom:_current.tag to:new.tag];
        }
        
        _current.userInteractionEnabled = YES;
        new.userInteractionEnabled = NO;
        
        new.selected = YES;
        _current.selected = NO;
        
        _current = new;
    }
}

#pragma mark 构造方法
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items {
    if (self = [super initWithFrame:frame]) {
        // colorWithPatternImage ： 平铺一张图片来生成背景颜色
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]];
        
        int count = items.count;
        CGFloat itemHeight = self.bounds.size.height;
        CGFloat itemWidth = self.bounds.size.width / count;
        
        for (int index = 0; index < count; index++) {
            ZXTabbarItemDesc *desc = [items objectAtIndex:index];
            CGFloat itemX = index * itemWidth;
            CGRect itemFrame = CGRectMake(itemX, (self.frame.size.height-itemHeight)*0.5, itemWidth, itemHeight);
            ZXTabbarItem *item = [[ZXTabbarItem alloc] initWithFrame:itemFrame itemDesc:desc];
            
            // 设置一个标记
            item.tag = index;
            
            [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:item];
            
            if (index == 0) {
                // 让第0个item选中
                [self itemClick:item];
            }
        }
        
    }
    return self;
}

@end
