//
//  UIImage+ZX.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZX)
#pragma mark 返回拉伸好的图片
+ (UIImage *)resizeImage:(NSString *)imgName;
-(UIImage*)scaleToSize:(CGSize)size;
@end
