
//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//  九宫格滚动视图

#import <UIKit/UIKit.h>
#import "CellViewDelegate.h"

@class CellView;

typedef enum
{
    EScrollDirectionVerticle,
    EScrollDirectionHorizontal,
} TScrollDirection;

@interface ScrollView : UIScrollView <UIScrollViewDelegate>
{
	int iCellWidth;
	int iCellHeight;
	int iIntervalH;//cell间的水平距离的一半,及cell到边上的水平距离
	int iIntervalV;//cell间的垂直距离的一半,及cell到边上的垂直距离
	int iColumns;//在一页中的列数
	int iRows;//在一页中的行数
	int iCurrentIndex;
	BOOL iSingleSelected;//项选择一次后禁用，且此时激活其它禁用的项。为YES时，必须设置每项有不同的id值。
	TScrollDirection iScrollDirection;//0 垂直，1 水平
	int iLayoutDirectionH;//行中水平布局方向 0 left to right, 1 right to left
	
	UIPageControl* iPageControl;
    UIColor* borderColor_;

    NSMutableArray* cellViewArray_;
    BOOL isIndexContinuous_;//索引是否是连续的
    BOOL contentSizeToFit_;//当第2页内容小于一屏时，保持原内容尺寸，而不是认为是两屏。
    
    UIImage* backgroundImage_;
    
    float paddingRight_;
}

@property (nonatomic,assign) int iIntervalH;
@property (nonatomic,assign) int iIntervalV;
@property (nonatomic) BOOL iSingleSelected;
@property (nonatomic) TScrollDirection scrollDirection;
@property (nonatomic) int iLayoutDirectionH;
@property (nonatomic,readonly) int iCurrentIndex;
@property (nonatomic,retain) UIColor* borderColor;
@property (nonatomic) BOOL isIndexContinuous;
@property (nonatomic) BOOL contentSizeToFit;
@property (nonatomic) float paddingRight;

-(void)setBackgroundImage:(UIImage*)aImage;
-(void)setColumns:(int)aColumns
			 rows:(int)aRows;
-(void)setColumns:(int)aColumns
			 rows:(int)aRows
        intervalV:(int)aIntervalV;
-(void)setColumns:(int)aColumns
			 rows:(int)aRows
        intervalH:(int)aIntervalH
		intervalV:(int)aIntervalV;
-(void)setCellArray:(NSArray*)aCellDataArray 
			  delegate:(id<CellViewDelegate>)aDelegate;
-(void)addCell:(CellData*)aCellData 
			  delegate:(id<CellViewDelegate>)aDelegate;
-(void)clear;
-(int)cellCount;
-(void)removeCellViewAtIndex:(int)index animated:(BOOL)animated;
-(void)setSingleSelected:(int)aId;
-(CellView*)cellViewAtIndex:(int)aIndex;
-(void)showPageControl;//只在水平滚动分页时起作用，要在ScrollView被添加到父视图后调用此方法
-(void)showPageControlWithActiveImage:(UIImage*)activeImage inactiveImage:(UIImage*)inactiveImage;
-(void)showPageControlWithFrame:(CGRect)frame superView:(UIView*)superView;
-(void)showPageControlWithFrame:(CGRect)frame
                      superView:(UIView*)superView
                    activeImage:(UIImage*)activeImage
                  inactiveImage:(UIImage*)inactiveImage;
-(void)movePageControlOffset:(CGPoint)offset;//移动page control

-(void)gotoFirstPage;
-(void)addFrameY:(int)aHeight;
-(void)setCurrentPageIndex:(int)currentPageIndex;

//根据CellData，更新显示Cell
-(void)updateCellView;
-(void)updateCellViewTextColor:(UIColor*)textColor;
@end
