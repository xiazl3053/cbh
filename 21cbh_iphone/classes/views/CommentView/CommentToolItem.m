//
//  CommentToolViewItem.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentToolItem.h"
#import "ZXTabbarItem.h"
#import "NCMConstant.h"


#define Kinterval 3

@implementation CommentToolItem

- (id)initWithFrame:(CGRect)frame itemDesc:(ZXTabbarItemDesc *)desc {
    if (self = [super initWithFrame:frame]) {
        // 设置高亮显示的背景
        //[self setHighlightedBg:@"tabbar_slider.png"];
        // 设置selected=YES时的背景
        //[self setSelectedBg:@"tabbar_slider.png"];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        // 设置默认的Image
        [self setImage:[UIImage imageNamed:desc.normal] forState:UIControlStateNormal];
        // 设置selected=YES时的image
        [self setImage:[UIImage imageNamed:desc.highlighted] forState:UIControlStateSelected];
        
        [self setBackgroundImage:[UIImage imageNamed:@"NewsComment_Toolitem_Highlight.png"] forState:UIControlStateHighlighted];
        
        // 不需要在用户长按的时候调整图片为灰色
        self.adjustsImageWhenHighlighted = NO;
        
        // 设置UIImageView的图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        
        // 设置文字
        [self setTitle:desc.title forState:UIControlStateNormal];
        // 设置文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置字体大小
        self.titleLabel.font=[UIFont systemFontOfSize:10];;
        //设置字体颜色
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       // [self setTitleColor:UIColorFromRGB(0xee5909) forState:UIControlStateHighlighted];
       // [self setTitleColor:UIColorFromRGB(0xee5909) forState:UIControlStateSelected];
        
    }
    return self;
}

#pragma mark - 覆盖父类的2个方法
#pragma mark 设置按钮标题的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    UIImage *image =  [self imageForState:UIControlStateNormal];
    CGFloat titleY = image.size.height + Kinterval;
    CGFloat titleHeight = self.bounds.size.height - titleY;
    return CGRectMake(0, titleY+Kinterval, self.bounds.size.width,  titleHeight-Kinterval);
}
#pragma mark 设置按钮图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    UIImage *image =  [self imageForState:UIControlStateNormal];
    return CGRectMake(0, Kinterval+1, self.bounds.size.width, image.size.height);
}

@end
