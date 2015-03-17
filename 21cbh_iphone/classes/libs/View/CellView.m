
//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CellView.h"
#import "ScrollView.h"

const int KBadgeViewTag=2;

@implementation CellView
@synthesize iParentView;
@synthesize iCellData;


-(void)setContent:(CellData*)aCellData
		 delegate:(id<CellViewDelegate>)aDelegate
{
	iDelegate=aDelegate;
	iCellData=[aCellData retain];
	
	if(iCellData.iBgImage)
	{
		iBgImageView=[[UIImageView alloc] initWithFrame:self.bounds];
		iBgImageView.image=iCellData.iBgImage;
		iBgImageView.highlightedImage=iCellData.iBgImageSelected;
		iBgImageView.contentMode=iCellData.iBgImageContentMode;
		iBgImageView.highlighted=iCellData.iSelected;
		[self addSubview:iBgImageView];
	}
	
	if(iCellData.bgColor)
	{
		self.backgroundColor=iCellData.bgColor;
	}
}

- (void)dealloc {
	[iButton release];
	[iCellData release];
	[iBgImageView release];
    [badgeButton_ release];
    [super dealloc];
}

-(void)updateView
{
    if(iBgImageView && iCellData.iBgImage)
	{
		iBgImageView.image=iCellData.iBgImage;
		iBgImageView.highlightedImage=iCellData.iBgImageSelected;
	}
	
	if(iCellData.bgColor)
	{
		self.backgroundColor=iCellData.bgColor;
	}
    
    [self setBadgeView];
}

-(void)setBadgeView
{
    //badge
	if(iCellData.badgeView && !iCellData.badgeView.superview)
	{
		CGRect badgeButtonFrame=CGRectZero;
		
		badgeButtonFrame.origin.x+=iCellData.badgeOriginOffset.x;
		badgeButtonFrame.origin.y+=iCellData.badgeOriginOffset.y;
		badgeButtonFrame.size=iCellData.badgeView.bounds.size;
		[self addSubview:iCellData.badgeView];
        iCellData.badgeView.tag=KBadgeViewTag;
	}
    else
    {
        [[self viewWithTag:KBadgeViewTag] removeFromSuperview];
    }
}

-(int)indexInParentView
{
    int index=-1;
    
    int count=iParentView.cellCount;
    for (int i=0;i<count;i++)
    {
        CellView* cellView=[iParentView cellViewAtIndex:i];
        if(cellView==self)
        {
            index=i;
            break;
        }
    }
    
    return index;
}

#pragma mark -
#pragma mark 状态
-(void)setSelected:(BOOL)aSelected
{
	iButton.selected=aSelected;
	iBgImageView.highlighted=aSelected;
}

-(BOOL)isSelected
{
	return iButton.selected;
}

-(void)setUnselected
{
	iBgImageView.highlighted=NO;
}

-(void)setUserInteractionEnabled:(BOOL)aEnable
{
	[iButton setUserInteractionEnabled:aEnable];
	iButton.enabled=aEnable;
}

#pragma mark -
#pragma mark 事件
-(void)buttonTouchDown
{	
	iBgImageView.highlighted=YES;
    
    if ([iDelegate respondsToSelector:@selector(handleCellTouchDownEvent:cellData:)])
    {
        [iDelegate handleCellTouchDownEvent:self cellData:iCellData];
    }
}
-(void)buttonTouchUpOutside
{	
	iBgImageView.highlighted=NO;
}
-(void)buttonTouchUpInside
{	
	if(iParentView.iSingleSelected)
	{
		[iParentView setSingleSelected:iCellData.iId];
	}
	else if(iCellData.iKeepSelectedState)
	{
		BOOL selected=[self isSelected];
		[self setSelected:!selected];
	}
	else 
	{
		[self setSelected:NO];
	}
    
    if (iDelegate && [iDelegate respondsToSelector:@selector(handleCellEvent:cellData:)])
    {
        [iDelegate handleCellEvent:self cellData:iCellData];
    }
}

@end
