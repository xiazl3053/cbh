//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

//九宫格中的一格

#import <UIKit/UIKit.h>
#import "CellViewDelegate.h"
#import "CellData.h"

@class ScrollView;

@interface CellView : UIView 
{
	CellData* iCellData;
	id<CellViewDelegate> iDelegate;
	ScrollView* iParentView;
	
	UIButton* iButton;
	UIImageView* iBgImageView;
    
    UIButton* badgeButton_;
}

@property (nonatomic,assign) ScrollView* iParentView;
@property (nonatomic,retain) CellData* iCellData;

-(void)setContent:(CellData*)aCellData
		 delegate:(id<CellViewDelegate>)aDelegate;

-(void)setSelected:(BOOL)aSelected;
-(void)setUserInteractionEnabled:(BOOL)aEnable;
-(BOOL)isSelected;
-(void)updateView;
-(int)indexInParentView;

//protected
-(void)buttonTouchUpInside;
-(void)buttonTouchDown;
-(void)buttonTouchUpOutside;

@end
