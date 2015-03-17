//
//  ZXTabbarItem.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "ZXTabbarItem.h"
#import "UIImage+ZX.h"
#define Kinterval 3

@implementation ZXTabbarItem

- (id)initWithFrame:(CGRect)frame itemDesc:(ZXTabbarItemDesc *)desc {
    if (self = [super initWithFrame:frame]) {
        // 设置高亮显示的背景
        //[self setHighlightedBg:@"tabbar_slider.png"];
        // 设置selected=YES时的背景
        //[self setSelectedBg:@"tabbar_slider.png"];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        // 设置默认的Image
        [self setImage:[[UIImage imageNamed:desc.normal] scaleToSize:CGSizeMake(28, 28)] forState:UIControlStateNormal];
        // 设置selected=YES时的image
        [self setImage:[[UIImage imageNamed:desc.highlighted] scaleToSize:CGSizeMake(28, 28)] forState:UIControlStateSelected];
        [self setImage:[[UIImage imageNamed:desc.highlighted] scaleToSize:CGSizeMake(28, 28)] forState:UIControlStateHighlighted];
        
        // 不需要在用户长按的时候调整图片为灰色
        self.adjustsImageWhenHighlighted = NO;
        // 设置UIImageView的图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        
        // 设置文字
        [self setTitle:desc.title forState:UIControlStateNormal];
        // 设置文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置字体大小
        self.titleLabel.font=[UIFont fontWithName:kFontName size:13];
        //设置字体颜色
        [self setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
        [self setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
        [self setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateSelected];

    }
    return self;
}

#pragma mark - 覆盖父类的2个方法
#pragma mark 设置按钮标题的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    UIImage *image =  [self imageForState:UIControlStateNormal];
    CGFloat titleY = image.size.height + Kinterval-2;
    CGFloat titleHeight = self.bounds.size.height - titleY;
    return CGRectMake(0, titleY+Kinterval, self.bounds.size.width,  titleHeight-Kinterval);
}
#pragma mark 设置按钮图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    UIImage *image =  [self imageForState:UIControlStateNormal];
    return CGRectMake(0, Kinterval+5, self.bounds.size.width, image.size.height);
}

@end

@implementation ZXTabbarItemDesc
+ (id)itemWithTitle:(NSString *)title normal:(NSString *)normal highlighted:(NSString *)highlighted {
    ZXTabbarItemDesc *desc = [[ZXTabbarItemDesc alloc] init];
    desc.title = title;
    desc.normal = normal;
    desc.highlighted = highlighted;
    return desc;
}

- (void)dealloc {
    _title=nil;
    _normal=nil;
    _highlighted=nil;
}
@end
