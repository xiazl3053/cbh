//
//  UIImage+Custom.m
//   
//
//  Created by Liccon Chang on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Custom.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

CGFloat TYDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat TYRadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

static void addRoundedRectToPath(CGContextRef context, 
                                 CGRect rect, 
                                 float ovalWidth,                                 
                                 float ovalHeight)
{    
    float fw,fh;    
    if (ovalWidth == 0 || ovalHeight == 0) {        
        CGContextAddRect(context, rect);        
        return;
    }
    CGContextSaveGState(context);    
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));    
    CGContextScaleCTM(context, ovalWidth, ovalHeight);    
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner    
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner    
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner    
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner    
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right    
    CGContextClosePath(context);    
    CGContextRestoreGState(context);
}

@implementation UIImage (scale)  

- (UIImage*)scale:(float)aScale  
{  
	CGSize size=CGSizeMake(self.size.width*aScale, self.size.height*aScale);
	
    return [self scaleToSize:size];
}  

- (UIImage*)scaleToSize:(CGSize)size  
{
    // 创建一个bitmap的context  
    // 并把它设置成为当前正在使用的context  
    //UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片  
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];  
    // 从当前context中创建一个改变大小后的图片  
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
    // 使当前的context出堆栈  
    UIGraphicsEndImageContext();  
    // 返回新的改变大小后的图片  
    return scaledImage;
}  

- (UIImage*)scaleToAspectFitSize:(CGSize)size  
{  
	CGSize imageSize=self.size;
	
    CGFloat imgRatio = imageSize.width / imageSize.height;
	CGFloat btnRatio = size.width / size.height;
	CGFloat scaleFactor = imgRatio > btnRatio ? imageSize.width / size.width : imageSize.height / size.height;
	
	//
	int width=imageSize.width/scaleFactor;
	int height=imageSize.height/scaleFactor;
	
	return [self scaleToSize:CGSizeMake(width, height)];
} 

- (UIImage*)scaleToAspectSizeWithHeight:(int)height
{
	CGSize imageSize=self.size;
	CGFloat scaleFactor = imageSize.height / height;
	int targetWidth=imageSize.width/scaleFactor;
	if (targetWidth>imageSize.width)
    {
        targetWidth=imageSize.width;
    }
	return [self scaleToSize:CGSizeMake(targetWidth, height)];//[self scaleToAspectFitSize:CGSizeMake(targetWidth, height)];
}

- (UIImage*)scaleToAspectSizeWithWidth:(int)width
{
	CGSize imageSize=self.size;
	CGFloat scaleFactor = imageSize.width / width;
	int targetHeight=imageSize.height/scaleFactor;
	return [self scaleToSize:CGSizeMake(width, targetHeight)];
}

- (UIImage*)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:TYRadiansToDegrees(radians)];
}

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(TYDegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    [rotatedViewBox release];
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, TYDegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)scaledToSizeWithSameAspectRatio:(CGSize)targetSize fitType:(enum FitType)fitType
{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        switch (fitType)
        {
            case ENormal:
                if (widthFactor > heightFactor) 
                {
                    scaleFactor = widthFactor; // scale to fit height
                }
                else 
                {
                    scaleFactor = heightFactor; // scale to fit width
                }
                break;
            case EWidth:
                scaleFactor = widthFactor; // scale to fit height
                break;
            case EHeight:
                scaleFactor = heightFactor; // scale to fit width
                break;
        }        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor) 
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) 
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [self CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    if (bitmapInfo == kCGImageAlphaNone)
    {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    CGContextRef bitmap;
    if (self.imageOrientation == UIImageOrientationUp ||self.imageOrientation == UIImageOrientationDown) 
    {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight,CGImageGetBitsPerComponent(imageRef),CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    } else 
    {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth,CGImageGetBitsPerComponent(imageRef),CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    }
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (self.imageOrientation == UIImageOrientationLeft) 
    {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        CGContextRotateCTM (bitmap, TYDegreesToRadians(90.0));
        CGContextTranslateCTM (bitmap, 0, -targetHeight); 
    } 
    else if (self.imageOrientation ==UIImageOrientationRight) 
    {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        CGContextRotateCTM (bitmap, TYDegreesToRadians(-90.0));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
    } 
    else if (self.imageOrientation == UIImageOrientationUp) 
    {
        // NOTHING
    }
    else if (self.imageOrientation == UIImageOrientationDown)
    {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, TYDegreesToRadians(-180.0));
    }
    
    UIImage* newImage = nil;
    if (bitmap)
    {
        CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x,thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
        CGImageRef ref = CGBitmapContextCreateImage(bitmap);
        newImage = [UIImage imageWithCGImage:ref];
        CGContextRelease(bitmap);
        CGImageRelease(ref);
    }
    else
    {
        newImage = [self getSubImage:CGRectMake(thumbnailPoint.x,thumbnailPoint.y, scaledWidth, scaledHeight)];
    }
    return newImage;    
} 

+ (UIImage*)roundedImage:(UIImage*)image size:(CGSize)size
{    
    // the size of CGContextRef    
    int w = size.width;    
    int h = size.height;            
    UIImage *img = image;    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();    
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);    
    CGRect rect = CGRectMake(0, 0, w, h);            
    CGContextBeginPath(context);    
    addRoundedRectToPath(context, rect, w/2, h/2);    
    CGContextClosePath(context);    
    CGContextClip(context);    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);    
    CGContextRelease(context);    
    CGColorSpaceRelease(colorSpace);    
    UIImage* roundedImage= [UIImage imageWithCGImage:imageMasked];   
    CGImageRelease(imageMasked);
    return roundedImage;
}

-(UIImage*)imageWithCornerRadius:(float)cornerRadius
{
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 1.0);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                cornerRadius:10.0] addClip];
    // Draw your image
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    // Get the image, here setting the UIImageView image
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 * 等比例缩放图片，并且返回想要尺寸的图片
 */
- (UIImage*)scaleToSizeAndKeepShape:(CGSize)size
{
    float fScale = 0; //等比例缩放的比例值
    if (size.width/self.size.width > size.height/self.size.height) {
        fScale = size.height/self.size.height;
    } else {
        fScale = size.width/self.size.width;
    }
    UIImage *image = [self scaleToSize:CGSizeMake(self.size.width*fScale, self.size.height*fScale)];
    
    // 将image绘制到新创建的图片缓存中去  
    // 并把它设置成为当前正在使用的context  
    UIGraphicsBeginImageContext(size);  
    // 绘制改变大小的图片  
    [self drawInRect:CGRectMake((size.width-image.size.width)/2, (size.height-image.size.height)/2, image.size.width, image.size.height)];  
    // 从当前context中创建一个改变大小后的图片  
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈  
    UIGraphicsEndImageContext();  
    // 返回新的改变大小后的图片  
    return scaledImage;  
}

/*
 * 先等比例缩放图片,同时保持所需宽度,假如高度超高,就裁剪,不够的话，就空缺
 */
- (UIImage*)scaleToSizeAndKeepWidth:(CGSize)size
{
    CGFloat fScaleHeight = self.size.height*(size.width/self.size.width);
    if (fScaleHeight > size.height) { //缩放后高度超高,就要裁剪
        // 先等比缩放
        UIImage* scaleImage = [self scaleToSize:CGSizeMake(size.width, fScaleHeight)];
        // 再裁剪
        CGImageRef sourceImageRef = [scaleImage CGImage];
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(0, (scaleImage.size.height-size.height)/2, size.width, size.height)); //裁剪区域
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
        CGImageRelease(newImageRef);
        // 返回裁剪图片
        return newImage;
    } else {                          //高度不够,就空缺一部分填充
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size);
        // 绘制改变大小的图片
        [self drawInRect:CGRectMake(0, (size.height-fScaleHeight)/2, size.width, fScaleHeight)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        // 返回新的改变大小后的图片
        return scaledImage;
    }
    return nil;
}

/*
 * 先等比例缩放图片,以最小边缩放,假如高度超高,就裁剪高度,或者宽度过大,就裁剪宽度
 */
- (UIImage*)scaleToSizeAndKeepMinSide:(CGSize)size
{
    if (self.size.width/self.size.height > size.width/size.height) {
        CGFloat fScale = size.height/self.size.height;
        //先不管给定size,等比放大图片
        UIImage* scaleImage = [self scaleToSize:CGSizeMake(self.size.width*fScale, size.height)];
        //再裁剪
        CGImageRef sourceImageRef = [scaleImage CGImage];
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake((scaleImage.size.width-size.width)/2, 0, size.width, size.height)); //裁剪区域
        UIImage* newImage = [UIImage imageWithCGImage:newImageRef];
        CGImageRelease(newImageRef);
        // 返回裁剪图片
        return newImage;
    } else {
        CGFloat fScale = size.width/self.size.width;
        //先不管给定size,等比放大图片
        UIImage* scaleImage = [self scaleToSize:CGSizeMake(size.width, self.size.height*fScale)];
        //再裁剪
        CGImageRef sourceImageRef = [scaleImage CGImage];
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(0, (scaleImage.size.height-size.height)/2, size.width, size.height)); //裁剪区域
        UIImage* newImage = [UIImage imageWithCGImage:newImageRef];
        CGImageRelease(newImageRef);
        // 返回裁剪图片
        return newImage;
    }
    
    return nil;
}

/*
 * 裁减大图,将大图裁减成指定区域内的图片
 */
- (UIImage*)getSubImage:(CGRect)rect 
{ 
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect); 
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size); 
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextDrawImage(context, smallBounds, subImageRef); 
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef]; 
    UIGraphicsEndImageContext(); 
    CGImageRelease(subImageRef);
    //
    return smallImage; 
}  

//没有降低图片质量情况下修改图片大小
-(NSData*)dataOfReducedQualityWithDefaultStandards
{
    UIImage* image=[self imageOfReducedQualityWithDefaultStandards];
    
    NSLog(@"%@",NSStringFromCGSize(image.size));
    NSData* data=UIImageJPEGRepresentation(image,0.65);//0.5
    
    NSLog(@"%d",[data length]/1024);
    
    return data;
}

-(UIImage*)imageOfReducedQualityWithDefaultStandards
{
    UIImage* image=self;
    
    /*
    NSData* data=UIImageJPEGRepresentation(image,0);
    int lengthK=[data length]/1024;
    if(lengthK>50)
    */
    
    CGSize imageSize=image.size;
    if(imageSize.width>imageSize.height)
    {
        if(imageSize.width>960)
        {
            image=[image scaleToAspectFitSize:CGSizeMake(960, 10000)];
        }
    }
    else
    {
        if(imageSize.width>640)
        {
            image=[image scaleToAspectFitSize:CGSizeMake(640, 10000)];
        }
    }
    
    return image;
}

@end 

@implementation UIImage (TextImage)

+ (UIImage*)imageFromText:(NSString*)text font:(UIFont*)font
{
	CGSize size = [text sizeWithFont:font];
	//size.width=22;
	//size.height=22;
    if (UIGraphicsBeginImageContextWithOptions != NULL)
	{
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
	}
    else
	{
        UIGraphicsBeginImageContext(size);
	}
    [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    return image;
}

+ (UIImage*)imageFromText:(NSString *)text font:(UIFont*)font color:(UIColor*)color
{
    // set the font type and size
    CGSize size = [text sizeWithFont:font];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor whiteColor] CGColor]);
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    // draw in context, you can use  drawInRect/drawAtPoint:withFont:
    //[text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();   
    
    return image;
}

+(UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width,size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end


@implementation UIImage (ImageEffect)

CGContextRef CreateRGBABitmapContext (CGImageRef inImage);

// Return a bitmap context using alpha/red/green/blue byte values
CGContextRef CreateRGBABitmapContext (CGImageRef inImage) 
{
	CGContextRef context = NULL; 
	CGColorSpaceRef colorSpace; 
	void *bitmapData; 
	int bitmapByteCount; 
	int bitmapBytesPerRow;
	size_t pixelsWide = CGImageGetWidth(inImage); 
	size_t pixelsHigh = CGImageGetHeight(inImage); 
	bitmapBytesPerRow	= (pixelsWide * 4); 
	bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); 
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL) 
	{
		fprintf(stderr, "Error allocating color space\n"); return NULL;
	}
	// allocate the bitmap & create context 
	bitmapData = malloc( bitmapByteCount ); 
	if (bitmapData == NULL) 
	{
		fprintf (stderr, "Memory not allocated!"); 
		CGColorSpaceRelease( colorSpace ); 
		return NULL;
	}
	context = CGBitmapContextCreate (bitmapData, 
									 pixelsWide, 
									 pixelsHigh, 
									 8, 
									 bitmapBytesPerRow, 
									 colorSpace, 
									 kCGImageAlphaPremultipliedLast);
	if (context == NULL) 
	{
		free (bitmapData); 
		fprintf (stderr, "Context not created!");
	} 
	CGColorSpaceRelease( colorSpace );
    
	return context;
}
// Return Image Pixel data as an RGBA bitmap 
unsigned char *RequestImagePixelData(UIImage *inImage);
unsigned char *RequestImagePixelData(UIImage *inImage) 
{
	CGImageRef img = [inImage CGImage]; 
	CGSize size = [inImage size];
	CGContextRef cgctx = CreateRGBABitmapContext(img); 
	
	if (cgctx == NULL) 
		return NULL;
	
	CGRect rect = {{0, 0}, {size.width, size.height}}; 
	CGContextDrawImage(cgctx, rect, img); 
	unsigned char *data = CGBitmapContextGetData (cgctx); 
	CGContextRelease(cgctx);
	return data;
}

+ (UIImage*)blackWhite:(UIImage*)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y=0; y< h; y++)
	{
		pixOff = wOff;
		
		for (GLuint x=0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			int bw = (int)((red+green+blue)/3.0);
			
			imgPixel[pixOff] = bw;
			imgPixel[pixOff+1] = bw;
			imgPixel[pixOff+2] = bw;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, 
										NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return my_Image;
}

+ (UIImage*)cartoon:(UIImage *)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			int ava = (int)((red+green+blue)/3.0);
			
			int newAva = ava>128 ? 255 : 0;
			
			imgPixel[pixOff] = newAva;
			imgPixel[pixOff+1] = newAva;
			imgPixel[pixOff+2] = newAva;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return my_Image;
}

+ (UIImage *)memory:(UIImage *)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			red = green = blue = ( red + green + blue ) /3;
			
			red += red*2;
			green = green*2;
			
			if(red > 255)
				red = 255;
			if(green > 255)
				green = 255;
			
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return my_Image;
}

+ (UIImage *)bopo:(UIImage *)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	//printf("w:%d,h:%d",w,h);
	
	int i, j, m, n;
	int bRowOff;
	int width = 8; //对于某些图片可能处理会画屏，可能需要更改特效点的宽度(目前是8,用5,10会好些)
    if (w%width != 0) {
        bool bFind = NO;
        for (int n=4; n<=16; n++) {
            if (w%n == 0) {
                width = n;
                bFind = YES;
                break;
            }
        }
        if (!bFind) {
            return nil;
        }
    }
    //printf("width:%d",width);
	int height = 8;
	int centerW = width /2;
	int centerH = height /2;
	
	//fix the image to right size
	int modw = w%width;
	int modh = h%height;
	if(modw) w = w - modw;
	if(modh) h = h - modh;
	
	int br, bg, bb;
	int tr, tg, tb;
	
	double offset;
	//double **weight= malloc(height*width*sizeof(double));
	NSMutableArray *wei = [[NSMutableArray alloc] init];
	for(m = 0; m < height; m++)
	{
		NSMutableArray *t1 = [[NSMutableArray alloc] init];
		for(n = 0; n < width; n++)
		{
			[t1 addObject:[NSNull null]];
		}
		[wei addObject:t1];
		[t1 release];
	}
	
	int total = 0;
	int max = (int)(pow(centerH, 2) + pow(centerW, 2));
	
	for(m = 0; m < height; m++)
	{
		for(n = 0; n < width; n++)
		{
			offset = max - (int)(pow((m - centerH), 2) + pow((n - centerW), 2));
			total += offset;
			//weight[m][n] = offset;
			[[wei objectAtIndex:m] insertObject:[NSNumber numberWithDouble:offset] atIndex:n];
		}
	}
	for(m = 0; m < height; m++)
	{
		for(n = 0; n < width; n++)
		{
			//weight[m][n] = weight[m][n] / total;
			double newVal = [[[wei objectAtIndex:m] objectAtIndex:n] doubleValue]/total;
			[[wei objectAtIndex:m] replaceObjectAtIndex:n 
                                             withObject:[NSNumber numberWithDouble:newVal]];
		}
	}
	bRowOff = 0;
	for(j = 0; j < h; j+=height) 
	{
		int bPixOff = bRowOff;
		
		for(i = 0; i < w; i+=width) 
		{
			int bRowOff2 = bPixOff;
			
			tr = tg = tb = 0;
			
			for(m = 0; m < height; m++)
			{
				int bPixOff2 = bRowOff2;
				
				for(n = 0; n < width; n++)
				{
					tr += 255 - imgPixel[bPixOff2];
					tg += 255 - imgPixel[bPixOff2+1];
					tb += 255 - imgPixel[bPixOff2+2];
					
					bPixOff2 += 4;
				}
				
				bRowOff2 += w*4;
			}
			bRowOff2 = bPixOff;
			
			for(m = 0; m < height; m++)
			{
				int bPixOff2 = bRowOff2;
				for(n = 0; n < width; n++)
				{
					
					//offset = weight[m][n];
					offset =  [[[wei objectAtIndex:m] objectAtIndex:n] doubleValue];
					br = 255 - (int)(tr * offset);
					bg = 255 - (int)(tg * offset);
					bb = 255 - (int)(tb * offset);
					
					if(br < 0)
						br = 0;
					if(bg < 0)
						bg = 0;
					if(bb < 0)
						bb = 0;
					imgPixel[bPixOff2] = br;
					imgPixel[bPixOff2 +1] = bg;
					imgPixel[bPixOff2 +2] = bb;
					
					bPixOff2 += 4; // advance background to next pixel
				}
				bRowOff2 += w*4;
			}
			bPixOff += width*4; // advance background to next pixel
		}
		bRowOff += w * height*4;
	}
	[wei release];
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
                                        bitsPerComponent, 
                                        bitsPerPixel, 
                                        bytesPerRow, 
                                        colorSpaceRef, 
                                        bitmapInfo, 
                                        provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return my_Image;
}

+ (UIImage *)scanLine:(UIImage *)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y+=2)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			int newR,newG,newB;
			int rr = red *2;
			newR = rr > 255 ? 255 : rr;
			int gg = green *2;
			newG = gg > 255 ? 255 : gg;
			int bb = blue *2;
			newB = bb > 255 ? 255 : bb;
			
			imgPixel[pixOff] = newR;
			imgPixel[pixOff+1] = newG;
			imgPixel[pixOff+2] = newB;
			
			pixOff += 4;
		}
		wOff += w * 4 *2;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return my_Image;
}

@end

@implementation UIImage (FitInSize)

+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGFloat scale;
	CGSize newsize;
	
	if(thisSize.width<aSize.width && thisSize.height < aSize.height)
	{
		newsize = thisSize;
	}
	else 
	{
		if(thisSize.width >= thisSize.height)
		{
			scale = aSize.width/thisSize.width;
			newsize.width = aSize.width;
			newsize.height = thisSize.height*scale;
		}
		else 
		{
			scale = aSize.height/thisSize.height;
			newsize.height = aSize.height;
			newsize.width = thisSize.width*scale;
		}
	}
	return newsize;
}

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize
{
    // calculate the fitted size
	CGSize size = [UIImage fitSize:image.size inSize:viewsize];
	
	UIGraphicsBeginImageContext(size);
    
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[image drawInRect:rect];
	
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();  
	
	return newimg;  
}

@end

@implementation UIImage (ImagePath)

+(UIImage *)imageInDirectoryWithName:(NSString *)name path:(NSString *)path
{
    NSString* bundlePath=[[[NSBundle mainBundle] pathForResource:path ofType:nil] stringByAppendingPathComponent:name];
    UIImage* image=[UIImage imageWithContentsOfFile:bundlePath];
    if(!image)
    {
        image=[UIImage imageNamed:name];
        if (image == nil)
        {
            NSString* fileName = [name lastPathComponent];
            NSString* exestr = [name pathExtension];
            if ([fileName length] > 0 && ([[exestr lowercaseString] isEqualToString:@"png"] || [[exestr lowercaseString] isEqualToString:@"jpg"]))
            {
                image=[UIImage imageNamed:fileName];
            }
        }
    }
    return image;
}

@end

@implementation UIImage (UIImagePickerControllerDidFinishPickingMedia)
+ (UIImage*)originalImageFromImagePickerMediaInfo:(NSDictionary*)info  
{
    return [UIImage imageFromImagePickerMediaInfo:info imageType:UIImagePickerControllerOriginalImage resultBlock:nil];
}
+ (UIImage*)originalImageFromImagePickerMediaInfo:(NSDictionary*)info resultBlock:(ALAssetsLibraryAssetForURLImageResultBlock)resultBlock
{
    return [UIImage imageFromImagePickerMediaInfo:info imageType:UIImagePickerControllerOriginalImage resultBlock:resultBlock];
}
+ (UIImage*)editedImageFromImagePickerMediaInfo:(NSDictionary*)info
{
    return [UIImage imageFromImagePickerMediaInfo:info imageType:UIImagePickerControllerEditedImage resultBlock:nil];
}
+ (UIImage*)editedImageFromImagePickerMediaInfo:(NSDictionary*)info resultBlock:(ALAssetsLibraryAssetForURLImageResultBlock)resultBlock
{
    return [UIImage imageFromImagePickerMediaInfo:info imageType:UIImagePickerControllerEditedImage resultBlock:resultBlock];
}
+ (UIImage*)imageFromImagePickerMediaInfo:(NSDictionary*)info imageType:(NSString*)imageType resultBlock:(ALAssetsLibraryAssetForURLImageResultBlock)resultBlock
{
    UIImage* image=nil;
    
    NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
	if([mediaType isEqualToString:(NSString*)kUTTypeImage])//(NSString*)kUTTypeImage,public.image
	{
		image=[info objectForKey:imageType];
        
        if(image)
        {
            image=[UIImage adjustImageOrientation:image];
        }
        else
        {        
            //ALAssetsLibrary
            NSURL *imageFileURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            __block UIImage* thumbnail = nil;
            [library assetForURL:imageFileURL resultBlock:^(ALAsset *asset)
             {
                 thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
                 thumbnail=[UIImage adjustImageOrientation:thumbnail];
                 resultBlock(thumbnail);
                 [library autorelease];
             }
             failureBlock:^(NSError *error)
             {
                 NSLog(@"error : %@", error);
                 resultBlock(nil);
                 [library autorelease];
                 
             }];
        }
	}
    
    return image;
}

+(UIImage*)adjustImageOrientation:(UIImage*)image
{
    UIImageOrientation imageOrientation=image.imageOrientation;
    if(imageOrientation!=UIImageOrientationUp)
    {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会逆时针旋转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    
    return image;
}
@end