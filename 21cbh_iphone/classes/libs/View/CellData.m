//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CellData.h"


@implementation CellData
@synthesize iId;
@synthesize iLabelText;
@synthesize iLabelTextSelected;
@synthesize iLabelTextColor;
@synthesize cellLayout;//标签是否浮于图片上
@synthesize iPaddingH;//cell内控件与边缘的距离
@synthesize iPaddingV;
@synthesize iImage;//在button上的图像
@synthesize imageUrl=imageUrl_;
@synthesize iImageSelected;
@synthesize iImageHighlighted;
@synthesize iImageDisabled;
@synthesize iLabelTextColorSelected;
@synthesize iSelected;
@synthesize iKeepSelectedState;
@synthesize iScaleAspectFit;
@synthesize iBgImage;
@synthesize iBgImageSelected;
@synthesize iBgImageContentMode;
@synthesize bgColor=bgColor_;
@synthesize userInfo=userInfo_;
@synthesize labelOriginOffset=labelOriginOffset_;
@synthesize enabled=enabled_;
@synthesize labelTextAlignment=labelTextAlignment_;
@synthesize badgeView=badgeView_;
@synthesize badgeBgImage=badgeBgImage_;
@synthesize labelFont=labelFont_;
@synthesize labelEmbellishImage=labelEmbellishImage_;
@synthesize labelRightEmbellishImage=labelRightEmbellishImage_;
@synthesize badgeOriginOffset=badgeOriginOffset_;
@synthesize imageCornerRadius=imageCornerRadius_;

-(id)init
{
	if(self=[super init])
	{
		self.iLabelTextColor=[UIColor whiteColor];
		self.iLabelTextColorSelected=iLabelTextColor;
		iCellLayout=ECellLayout_Default;
		iBgImageContentMode=UIViewContentModeCenter;
		iId=-1;
		labelOriginOffset_=CGPointMake(0, 0);
        labelTextAlignment_=NSTextAlignmentCenter;
        enabled_=YES;
	}
	return self;
}

- (void)setUserInfoObject:(id)anObject forKey:(id)aKey
{
	if(!userInfo_)
	{
		userInfo_=[[NSMutableDictionary alloc] initWithCapacity:1];
	}
	[userInfo_ setObject:anObject forKey:aKey];
}

-(void)dealloc
{
    [iLabelTextSelected release];
	[iLabelText release];
	[iLabelTextColor release];
	[iLabelTextColorSelected release];
	[iImage release];
    [imageUrl_ release];
	[iImageSelected release];
	[iBgImage release];
	[iBgImageSelected release];
	[userInfo_ release];
	[iImageHighlighted release];
	[iImageDisabled release];
	[bgColor_ release];
    [badgeBgImage_ release];
    [labelEmbellishImage_ release];
    [labelRightEmbellishImage_ release];
    [badgeView_ release];
    
	[super dealloc];
}

@end
