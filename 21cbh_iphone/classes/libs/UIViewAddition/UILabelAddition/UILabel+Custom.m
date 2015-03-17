//
//  UILabel+Custom.m
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UILabel+Custom.h"


@implementation UILabel (Custom)

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
		   textAlignment:(UITextAlignment)aTextAlignment
{
	return [self initWithFrame:aFrame
						  text:aText
						  font:aFont
					 textColor:aTextColor
				   shadowColor:nil
				  shadowOffset:CGSizeMake(0, 0)
				 textAlignment:aTextAlignment];
}

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
			 shadowColor:(UIColor*)shadowColor
			shadowOffset:(CGSize)shadowOffset
		   textAlignment:(UITextAlignment)aTextAlignment
{
	if(self=[self initWithFrame:aFrame])//不能用 [super initWithFrame:aFrame]，会导致颜色失效。
	{
		if(aTextColor)
		{
			self.textColor=aTextColor;
		}
		if(aFont)
		{
			self.font=aFont; 
		}
		self.textAlignment=aTextAlignment;//UITextAlignmentCenter;
		self.backgroundColor=[UIColor clearColor];
		self.text=aText;
		self.numberOfLines=0;
		if(shadowColor)
		{
			self.shadowColor = shadowColor;
			self.shadowOffset = shadowOffset;
		}
	}
	return self;
}

-(void)resizeHeightWithAllowReduce:(BOOL)aAllowRecuce
{
	[self setNumberOfLines:0];//设置行0

    CGSize autoResize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 1000) lineBreakMode: UILineBreakModeWordWrap];
    
    CGRect rect=self.frame;
    if(autoResize.height>rect.size.height || aAllowRecuce)
    {
        rect.size.height=autoResize.height;
        [self setFrame:rect];
    }
}


-(void)setShadowColor:(UIColor*)color shadowOffset:(CGSize)offset
{
    self.shadowColor = color;
    self.shadowOffset = offset;
}

@end
