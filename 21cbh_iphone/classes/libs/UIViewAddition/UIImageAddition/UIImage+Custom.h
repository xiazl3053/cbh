//
//  UIImage+Custom.h
//   
//
//  Created by Liccon Chang on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ALAssetsLibraryAssetForURLImageResultBlock)(UIImage* image);

enum FitType 
{
    ENormal = 0,//自计算
    EWidth = 1,//以宽为准
    EHeight = 2//以高为准
};

@interface UIImage (scale)  
- (UIImage*)scale:(float)aScale;
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage*)scaleToAspectFitSize:(CGSize)size;
- (UIImage*)scaleToAspectSizeWithHeight:(int)height;
- (UIImage*)scaleToAspectSizeWithWidth:(int)width;
- (UIImage*)getSubImage:(CGRect)rect;
- (UIImage*)imageRotatedByRadians:(CGFloat)radians;
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage*)scaledToSizeWithSameAspectRatio:(CGSize)targetSize fitType:(enum FitType)fitType;
+ (UIImage*)roundedImage:(UIImage*)image size:(CGSize)size;
-(UIImage*)imageWithCornerRadius:(float)cornerRadius;
- (UIImage*)scaleToSizeAndKeepShape:(CGSize)size;
- (UIImage*)scaleToSizeAndKeepWidth:(CGSize)size;
- (UIImage*)scaleToSizeAndKeepMinSide:(CGSize)size;
- (NSData*)dataOfReducedQualityWithDefaultStandards;//按默认标准降低了质量的图片的数据
@end 

@interface UIImage (TextImage)
+ (UIImage*)imageFromText:(NSString*)text font:(UIFont*)font;
+ (UIImage*)imageFromText:(NSString *)text font:(UIFont*)font color:(UIColor*)color;
+ (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size;
@end 

/*图片特效处理*/
@interface UIImage (ImageEffect)
+ (UIImage *)blackWhite:(UIImage *)inImage; //黑白
+ (UIImage *)cartoon:(UIImage *)inImage;    //漫画卡通
+ (UIImage *)memory:(UIImage *)inImage;     //复古
+ (UIImage *)bopo:(UIImage *)inImage;       //波普
+ (UIImage *)scanLine:(UIImage *)inImage;   //扫描线

@end

@interface UIImage (FitInSize)
+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize) aSize;
+ (UIImage *)image:(UIImage *)image fitInSize: (CGSize)viewsize;
@end

@interface UIImage(ImagePath)
+(UIImage*)imageInDirectoryWithName:(NSString*)name path:(NSString*)path;//寻找资源中文件夹下的图片
@end

@interface UIImage (UIImagePickerControllerDidFinishPickingMedia)
+ (UIImage*)originalImageFromImagePickerMediaInfo:(NSDictionary*)info;
+ (UIImage*)originalImageFromImagePickerMediaInfo:(NSDictionary*)info resultBlock:(ALAssetsLibraryAssetForURLImageResultBlock)resultBlock;
+ (UIImage*)editedImageFromImagePickerMediaInfo:(NSDictionary*)info;
+ (UIImage*)editedImageFromImagePickerMediaInfo:(NSDictionary*)info resultBlock:(ALAssetsLibraryAssetForURLImageResultBlock)resultBlock;
@end 