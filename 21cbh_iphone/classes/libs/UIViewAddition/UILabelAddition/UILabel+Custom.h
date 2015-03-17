//
//  UILabel+Custom.h
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILabel (Custom)

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
		   textAlignment:(UITextAlignment)aTextAlignment;

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
			 shadowColor:(UIColor*)shadowColor
			shadowOffset:(CGSize)shadowOffset
		   textAlignment:(UITextAlignment)aTextAlignment;
-(void)resizeHeightWithAllowReduce:(BOOL)aAllowRecuce;//根据文字，自适应高度。

-(void)setShadowColor:(UIColor*)color shadowOffset:(CGSize)offset;

@end
