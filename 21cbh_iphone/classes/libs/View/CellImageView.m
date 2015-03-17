//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CellImageView.h"
#import "ScrollView.h"
#import "UIButton+Custom.h"
#import "UIImage+Custom.h"

@implementation CellImageView


-(void)setContent:(CellData*)aCellData
		 delegate:(id<CellViewDelegate>)aDelegate
{
	[super setContent:aCellData delegate:aDelegate];
	
	int marginH=iCellData.iPaddingH;
    int marginV=iCellData.iPaddingV;
	int boundsWidth=self.bounds.size.width;
	int boundsHeight=self.bounds.size.height;
	
	CGRect buttonFrame=CGRectMake(marginH, marginV, boundsWidth-marginH*2,boundsHeight-marginV*2);
	
	if (iCellData.iScaleAspectFit) 
	{
		iCellData.iImage=[iCellData.iImage scaleToAspectFitSize:buttonFrame.size];
		iCellData.iImageSelected=[iCellData.iImageSelected scaleToAspectFitSize:buttonFrame.size];
	}
    
    iButton=[[UIButton buttonWithFrame:buttonFrame 
                           normalImage:iCellData.iImage
                     hightlightedImage:iCellData.iImageHighlighted
                         selectedImage:iCellData.iImageSelected] retain];
	[iButton setImage:iCellData.iImageDisabled forState:UIControlStateDisabled];
	
	[iButton addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventAllEvents];
	[iButton addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventTouchDown];
	[iButton addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	[iButton addTarget:self action:@selector(buttonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
	
	[self addSubview:iButton];
    
    [iButton setSelected:iCellData.iSelected];
    [iButton setEnabled:iCellData.enabled];
    [iButton setUserInteractionEnabled:iCellData.enabled];
    iButton.hidden=!iCellData.enabled;
    
    //badge
	if(iCellData.badgeBgImage)
	{
		CGRect badgeButtonFrame=CGRectZero;
		
		badgeButtonFrame.origin.x+=iCellData.badgeOriginOffset.x;
		badgeButtonFrame.origin.y+=iCellData.badgeOriginOffset.y;
		badgeButtonFrame.size.width=iCellData.badgeBgImage.size.width;
		badgeButtonFrame.size.height=iCellData.badgeBgImage.size.height;
		badgeButton_=[[UIButton buttonWithFrame:badgeButtonFrame
									normalImage:iCellData.badgeBgImage
							  hightlightedImage:nil
								  selectedImage:nil] retain];
        [badgeButton_ addTarget:self
                         action:@selector(onBadgeButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:badgeButton_];
	}
}

-(void)onBadgeButtonTouchUpInside
{
    if (iDelegate && [iDelegate respondsToSelector:@selector(handleCellBadgeEvent:cellData:)])
    {
        [iDelegate handleCellBadgeEvent:self cellData:iCellData];
    }
}

-(void)updateBadgeButton
{
    //badge
	if(iCellData.badgeBgImage)
	{
        if(!badgeButton_)
        {
            CGRect badgeButtonFrame=CGRectZero;
            
            badgeButtonFrame.origin.x+=iCellData.badgeOriginOffset.x;
            badgeButtonFrame.origin.y+=iCellData.badgeOriginOffset.y;
            badgeButtonFrame.size.width=iCellData.badgeBgImage.size.width;
            badgeButtonFrame.size.height=iCellData.badgeBgImage.size.height;
            badgeButton_=[[UIButton buttonWithFrame:badgeButtonFrame
                                        normalImage:iCellData.badgeBgImage
                                  hightlightedImage:nil
                                      selectedImage:nil] retain];
            [badgeButton_ addTarget:self
                             action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:badgeButton_];
        }
        else
        {
            [badgeButton_ setImage:iCellData.badgeBgImage forState:UIControlStateNormal];
        }
	}
    else
    {
        [badgeButton_ removeFromSuperview];
        [badgeButton_ release];
        badgeButton_=nil;
    }
}

-(void)setSelected:(BOOL)aSelected
{
	BOOL selected=[super isSelected];
	
	[super setSelected:aSelected];
	
	if(aSelected!=selected)
	{
		if(aSelected)
		{
			[iButton setImage:iCellData.iImageSelected forState:UIControlStateNormal];
			[iButton setImage:iCellData.iImageHighlighted forState:UIControlStateHighlighted];
			[iButton setImage:iCellData.iImageSelected forState:UIControlStateSelected];
		}
		else 
		{
			[iButton setImage:iCellData.iImage forState:UIControlStateNormal];
			[iButton setImage:iCellData.iImageHighlighted forState:UIControlStateHighlighted];
			[iButton setImage:iCellData.iImage forState:UIControlStateSelected];
			
			//为了在快速单击时突出点击效果
            [self performSelector:@selector(setUnselected) withObject:nil afterDelay:0.05];
		}
	}
}

-(void)setImage:(UIImage*)aImage highlightedImage:(UIImage*)aHighlightedImage
{
	iCellData.iImage=aImage;
	iCellData.iImageSelected=aHighlightedImage;
	[iButton setImage:aImage forState:UIControlStateNormal];
	[iButton setImage:aHighlightedImage forState:UIControlStateHighlighted];
}

-(void)updateView
{
    [super updateView];
    
	[iButton setImage:iCellData.iImage forState:UIControlStateNormal];
    [iButton setImage:iCellData.iImageHighlighted forState:UIControlStateHighlighted];
    [iButton setImage:iCellData.iImageSelected forState:UIControlStateSelected];
    [iButton setImage:iCellData.iImageDisabled forState:UIControlStateDisabled];
    
    //badge
	[self updateBadgeButton];
}

@end
