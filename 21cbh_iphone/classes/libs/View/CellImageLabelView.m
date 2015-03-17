//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CellImageLabelView.h"
#import "ScrollView.h"
#import <QuartzCore/CALayer.h>

const int KLabelLeftEmbellishImageViewTag=100;
const int KLabelRightEmbellishImageViewTag=101;

@interface CellView(private)
-(void)setBadgeView;
@end

@interface CellImageLabelView(private)
-(void)setUnselected;
@end

@implementation CellImageLabelView

-(void)setContent:(CellData*)aCellData
		 delegate:(id<CellViewDelegate>)aDelegate
{
	[super setContent:aCellData delegate:aDelegate];

	int marginH=iCellData.iPaddingH;
	int boundsWidth=self.bounds.size.width;
	int boundsHeight=self.bounds.size.height;
	
	//button
	CGRect buttonFrame=CGRectMake(marginH, 0, 
								  boundsWidth-marginH*2,
								  boundsHeight);
	iButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
	iButton.frame=buttonFrame;
	[iButton addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventTouchDown];
	[iButton addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[iButton addTarget:self action:@selector(buttonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [iButton addTarget:self action:@selector(buttonTouchCancelled) forControlEvents:UIControlEventTouchCancel];
	
	[self addSubview:iButton];
	
	
	//rect
	int buttonWidth=buttonFrame.size.width;
	int buttonHeight=buttonFrame.size.height;
	CGRect labelFrame=CGRectZero;
	
	if(iCellData.iImage)
	{
		CGRect imageViewRect=CGRectZero;
		
		switch(iCellData.cellLayout)
		{
			case ECellLayout_LabelOnImage:
				{
					imageViewRect=CGRectMake(0, 0,buttonWidth,buttonHeight);
					labelFrame=imageViewRect;
				}
				break;
			case ECellLayout_LabelRightImage:
				{
					int imageWidth=iCellData.iImage.size.width;
					imageViewRect=CGRectMake(0, 0,imageWidth,buttonHeight);
                    
					const int KSpaceImageLabel=0;
					labelFrame=CGRectMake(imageWidth+KSpaceImageLabel,0,
										  buttonWidth-(imageWidth+KSpaceImageLabel),buttonHeight);
				}
				break;
			case ECellLayout_LabelBelowImage:
				{
                    const int KImageMarginTop=5;
                    int imageHeight=iCellData.iImage.size.height;
					imageViewRect=CGRectMake(0,KImageMarginTop,buttonWidth,imageHeight);
                    
                    const int KSpaceImageLabel=0;
					labelFrame=CGRectMake(0,KImageMarginTop+imageHeight+KSpaceImageLabel,
										  buttonWidth,buttonHeight-(KImageMarginTop+imageHeight+KSpaceImageLabel));
				}
				break;
			default:
				{
					imageViewRect=CGRectMake(0, 0,buttonWidth,buttonHeight);
				}
				break;
		}
		
		//imageView
		iImageView=[[UIImageView alloc] initWithImage:iCellData.iImage highlightedImage:iCellData.iImageSelected];
		iImageView.highlighted=iCellData.iSelected;
		iImageView.contentMode=UIViewContentModeCenter;//UIViewContentModeScaleAspectFit
		[iImageView setFrame:imageViewRect];
		[iButton addSubview:iImageView];
        
        if(iCellData.imageUrl)
        {
            [self requestImage];
        }
	}
	else
	{
		labelFrame=CGRectMake(0, 0,buttonWidth,buttonHeight);
	}
	
	//label
	if(!iCellData.iLabelText)
	{
		iCellData.iLabelText=@"";
	}
	
	//位置偏移量
	labelFrame.origin.x+=iCellData.labelOriginOffset.x;
	labelFrame.origin.y+=iCellData.labelOriginOffset.y;
    
	iLabel=[[UILabel alloc] initWithFrame:labelFrame];
    
    if (iCellData.labelFont)
    {
        iLabel.font = iCellData.labelFont;
    }
    else
    {
        iLabel.font = [UIFont systemFontOfSize:13];
    }
    
    if(iCellData.iSelected && iCellData.iLabelTextSelected)
    {
        iLabel.text = iCellData.iLabelTextSelected;
    }
    else
    {
        iLabel.text = iCellData.iLabelText;
    }
	if(iCellData.iLabelTextColor)
	{
		iLabel.textColor=iCellData.iLabelTextColor;
	}
	if(iCellData.iLabelTextColorSelected)
	{
		iLabel.highlightedTextColor=iCellData.iLabelTextColorSelected;
	}
	iLabel.highlighted=iCellData.iSelected;
	iLabel.textAlignment = NSTextAlignmentCenter;
	[iLabel setBackgroundColor:[UIColor clearColor]];
    [iLabel setTextAlignment:iCellData.labelTextAlignment];
	[iButton addSubview:iLabel];
    
    //labelEmbellishImage
    [self setLabelEmbellishImage];
    
    [self setBadgeView];
}

-(void)setLabelEmbellishImage
{
    //labelEmbellishImage
    if(iCellData.labelEmbellishImage || iCellData.labelRightEmbellishImage)
    {
        CGSize stringSize = [iLabel.text sizeWithFont:iLabel.font];
        CGSize imageSize=iCellData.labelEmbellishImage.size;
        CGSize image2Size=iCellData.labelRightEmbellishImage.size;
        const int margin=1;
        CGRect imageRect=CGRectZero;
        
        CGRect labelFrame=iLabel.frame;
        
        if(iCellData.labelEmbellishImage)
        {
            imageRect.origin.x=labelFrame.origin.x+(labelFrame.size.width-stringSize.width)/2-imageSize.width-margin;
            imageRect.origin.y=labelFrame.origin.y+(labelFrame.size.height-imageSize.height)/2;
            imageRect.size=imageSize;
            if(imageRect.origin.x<0)
            {
                labelFrame.origin.x+=imageSize.width+margin;
                labelFrame.size.width-=(imageSize.width);
                iLabel.frame=labelFrame;
                
                imageRect.origin.x=margin*2;
            }
            
            [[iButton viewWithTag:KLabelLeftEmbellishImageViewTag] removeFromSuperview];
            UIImageView* imageView=[[[UIImageView alloc] initWithFrame:imageRect] autorelease];
            imageView.image=iCellData.labelEmbellishImage;
            imageView.tag=KLabelLeftEmbellishImageViewTag;
            [iButton addSubview:imageView];
        }
        
        if(iCellData.labelRightEmbellishImage)
        {
            imageRect.origin.x=labelFrame.origin.x+labelFrame.size.width-(labelFrame.size.width-stringSize.width)/2+margin;
            imageRect.origin.y=labelFrame.origin.y+(labelFrame.size.height-image2Size.height)/2;
            imageRect.size=image2Size;
            if(imageRect.origin.x>labelFrame.origin.x+labelFrame.size.width-image2Size.width)
            {
                imageRect.origin.x=labelFrame.origin.x+labelFrame.size.width-margin-imageRect.size.width;
                
                labelFrame.size.width-=image2Size.width;
                iLabel.frame=labelFrame;
            }
            
            [[iButton viewWithTag:KLabelRightEmbellishImageViewTag] removeFromSuperview];
            UIImageView* imageView=[[[UIImageView alloc] initWithFrame:imageRect] autorelease];
            imageView.image=iCellData.labelRightEmbellishImage;
            imageView.tag=KLabelRightEmbellishImageViewTag;
            [iButton addSubview:imageView];
        }
    }
    else
    {
        [[iButton viewWithTag:KLabelLeftEmbellishImageViewTag] removeFromSuperview];
        [[iButton viewWithTag:KLabelRightEmbellishImageViewTag] removeFromSuperview];
    }
}

-(void)requestImage
{
}

- (void)dealloc {
	[iImageView release];
	[iLabel release];
    [super dealloc];
}

-(void)setTitle:(NSString*)aTitle
{
	iCellData.iLabelText=aTitle;
    iLabel.text=iCellData.iLabelText;
}

-(void)setTitle:(NSString*)aTitle image:(UIImage*)image
{
    [self setTitle:aTitle];
    
    iCellData.iImage=image;
    iImageView.image=iCellData.iImage;
}

-(void)setUserInteractionEnabled:(BOOL)aEnable
{
    [super setUserInteractionEnabled:aEnable];
    
    if(aEnable)
    {
        self.layer.opacity=1.0;
    }
    else
    {
        self.layer.opacity=0.5;
    }
}

-(void)updateView
{
    [super updateView];
    
    if(iCellData.iImage)
	{
        iImageView.image=iCellData.iImage;
        iImageView.highlightedImage=iCellData.iImageSelected;
	}
	
	if(iLabel && iCellData.iLabelTextColor)
	{
		iLabel.textColor=iCellData.iLabelTextColor;
	}
	if(iLabel && iCellData.iLabelTextColorSelected)
	{
		iLabel.highlightedTextColor=iCellData.iLabelTextColorSelected;
	}
    
    iLabel.text=iCellData.iLabelText;
    
    [self setLabelEmbellishImage];
}

#pragma mark -
#pragma mark 状态
-(void)setUnselected
{
	iImageView.highlighted=NO;
	iLabel.highlighted=NO;
    if(iCellData.iLabelText)
    {
        iLabel.text=iCellData.iLabelText;
    }
}

-(void)setSelected:(BOOL)aSelected
{
    self.layer.opacity=1.0;
    
	[super setSelected:aSelected];
	
	if(aSelected)
	{
		iImageView.highlighted=aSelected;
		iLabel.highlighted=aSelected;
        if(iCellData.iLabelTextSelected)
        {
            iLabel.text=iCellData.iLabelTextSelected;
        }
	}
	else 
	{
		//为了在快速单击时突出点击效果
        [self performSelector:@selector(setUnselected) withObject:nil afterDelay:0.05];
	}
}

#pragma mark -
#pragma mark 事件
-(void)buttonTouchDown
{	
	[super buttonTouchDown];
    self.layer.opacity=0.5;
}
-(void)buttonTouchUpOutside
{	
	[super buttonTouchUpOutside];
	[self setSelected:NO];
}
-(void)buttonTouchCancelled
{
	[self buttonTouchUpOutside];
}
@end
