//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

//九宫格中的一格

#import <UIKit/UIKit.h>
#import "CellView.h"

@interface CellImageLabelView : CellView 
{
	UIImageView* iImageView;
	UILabel* iLabel;
}

-(void)setTitle:(NSString*)aTitle;
-(void)setTitle:(NSString*)aTitle image:(UIImage*)image; 

@end
