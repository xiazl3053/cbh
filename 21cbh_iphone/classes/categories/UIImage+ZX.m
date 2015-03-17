//
//  UIImage+ZX.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "UIImage+ZX.h"
#import "SDiPhoneVersion.h"

@implementation UIImage (ZX)
#pragma mark 返回拉伸好的图片
+ (UIImage *)resizeImage:(NSString *)imgName {
    UIImage *image = [UIImage imageNamed:imgName];
    CGFloat leftCap = image.size.width * 0.5f;
    CGFloat topCap = image.size.height * 0.5f;
    return [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}



-(UIImage*)scaleToSize:(CGSize)size
{
    
     NSInteger iphoneType=[SDiPhoneVersion deviceVersion];
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    //Determine whether the screen is retina
    if(iphoneType ==iPhone6Plus){
        UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    }else{
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    }
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end
