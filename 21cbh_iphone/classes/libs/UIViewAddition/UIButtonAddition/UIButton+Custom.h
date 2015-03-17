//
//  UIButton+Custom.h
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (Custom)

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage
				asBackground:(BOOL)aAsBackground;

+(UIButton*)buttonWithPosX:(int)posX
			  parentHeight:(int)parentHeight
			   normalImage:(UIImage*)aImage
		 hightlightedImage:(UIImage*)aHightlightedImage
			 selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithPosY:(int)posY
               parentWidth:(int)parentWidth
			   normalImage:(UIImage*)aImage
		 hightlightedImage:(UIImage*)aHightlightedImage
			 selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithFrame:(CGRect)aFrame
				normalImage:(UIImage*)aImage
		  hightlightedImage:(UIImage*)aHightlightedImage
			  selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithFrame:(CGRect)aFrame
				normalImage:(UIImage*)aImage
		  hightlightedImage:(UIImage*)aHightlightedImage
			  selectedImage:(UIImage*)aSelectedImage
			   asBackground:(BOOL)aAsBackground;

//指定宽度aWidth，水平居中+偏移origin
+(UIButton*)buttonWithOrigin:(CGPoint)origin
					   width:(int)aWidth
				 parentWidth:(int)aParentWidth 
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage;

//垂直居中+偏移origin
+(UIButton*)buttonWithOrigin:(CGPoint)origin
				parentHeight:(int)aParentHeight
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage;

//右对齐+RightMargin+偏移originY
+(UIButton*)buttonWithOriginY:(int)originY
                  rightMargin:(int)margin
                  parentWidth:(int)parentWidth
                        title:(NSString*)aTitle
                    titleFont:(UIFont*)aFont
                   titleColor:(UIColor*)aColor
                  normalImage:(UIImage*)aImage
            hightlightedImage:(UIImage*)aHightlightedImage
                selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 parentWidth:(int)aParentWidth 
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithOrigin:(CGPoint)origin
					   width:(int)aWidth
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage;

+(UIButton*)buttonWithOrigin:(CGPoint)origin
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage;

-(void)expandWidthAsTitleWithPaddingH:(int)paddingH;

- (void)centerImageAndTitle:(float)space wihtTopSpace:(float)top;
- (void)centerImageAndTitle:(float)space;  
- (void)centerImageAndTitle;

-(void)setTitleShadowColor:(UIColor*)color shadowOffset:(CGSize)offset;
@end
