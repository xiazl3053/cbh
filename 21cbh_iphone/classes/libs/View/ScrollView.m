//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ScrollView.h"
#import "CellView.h"
#import "CellImageView.h"
#import "CellImageLabelView.h"
#import "CustomPageControl.h"

@interface ScrollView(private)
-(void)setContentSize;
@end

@implementation ScrollView
@synthesize iIntervalH;
@synthesize iIntervalV;
@synthesize iSingleSelected;
@synthesize scrollDirection=iScrollDirection;
@synthesize iCurrentIndex;
@synthesize iLayoutDirectionH;
@synthesize borderColor=borderColor_;
@synthesize isIndexContinuous=isIndexContinuous_;
@synthesize contentSizeToFit=contentSizeToFit_;
@synthesize paddingRight=paddingRight_;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		iCurrentIndex=0;
		iColumns=1;
		iRows=1;
		self.delegate=self;
        self.scrollsToTop=NO;
        self.backgroundColor=UIColor.clearColor;
    }
    return self;
}

-(void)setBackgroundImage:(UIImage*)aImage
{
    backgroundImage_=[aImage retain];
    [self setNeedsDisplay];
}

-(void)setColumns:(int)aColumns
			 rows:(int)aRows
{
    [self setColumns:aColumns
                       rows:aRows
                  intervalH:0
                  intervalV:0];
}

-(void)setColumns:(int)aColumns
			 rows:(int)aRows
        intervalV:(int)aIntervalV
{
    [self setColumns:aColumns
                rows:aRows
           intervalH:0
           intervalV:aIntervalV];
}

-(void)setColumns:(int)aColumns
			 rows:(int)aRows
        intervalH:(int)aIntervalH
        intervalV:(int)aIntervalV
{
	iRows=aRows;
	iColumns=aColumns;
	
	iIntervalV=aIntervalV;
	iIntervalH=aIntervalH;
	
	iCellWidth=(self.bounds.size.width-paddingRight_)/iColumns-iIntervalH*2;
	iCellHeight=self.bounds.size.height/iRows-iIntervalV*2;
}

-(int)cellCount
{
    return cellViewArray_.count;
}

-(void)clear
{
	NSArray* subViewArray=cellViewArray_;//[super subviews];
	for(UIView* view in subViewArray)
	{
		[view removeFromSuperview];
	}
    [cellViewArray_ removeAllObjects];
	
	self.contentSize=CGSizeMake(0, 0);
}

-(void)setCellArray:(NSArray*)aCellDataArray 
		   delegate:(id<CellViewDelegate>)aDelegate
{	
	[self clear];

	int columns=iColumns;
	int rows=iRows;
	int intervalH=iIntervalH;
	int intervalV=iIntervalV;
	
	int count=[aCellDataArray count];
	int itemCountPerPage=rows*columns;
	
	for(int i=0;i<count;i++)
	{
		CellData* cellData=[aCellDataArray objectAtIndex:i];
		if(cellData.iId<0 || isIndexContinuous_)
		{
			cellData.iId=i;
		}
		
		CGRect rect;
		rect.size.width=iCellWidth;
		rect.size.height=iCellHeight;
		
		if(iScrollDirection==EScrollDirectionVerticle)
		{
			if(iLayoutDirectionH==0)
			{
				rect.origin.x=intervalH+i%columns*(iCellWidth+intervalH*2);
			}
			else 
			{
				rect.origin.x=intervalH+(columns-i%columns-1)*(iCellWidth+intervalH*2);
			}
			rect.origin.y=intervalV+i/columns*(iCellHeight+intervalV*2);
		}
		else 
		{
			/*
			//在一页内先竖排
			rect.origin.x=intervalH+i/rows*(iCellWidth+intervalH*2);
			rect.origin.y=intervalV+i%rows*(iCellHeight+intervalV*2);
			*/
			
			//在一页内先横排
			rect.origin.x=intervalH+i%columns*(iCellWidth+intervalH*2)+(int)i/itemCountPerPage*(self.bounds.size.width-paddingRight_);
			rect.origin.y=intervalV+i%itemCountPerPage/columns*(iCellHeight+intervalV*2);
		}
		
		CellView* cellView=nil;
		if(cellData.iLabelText || cellData.cellLayout>0)
		{
			cellView=[[CellImageLabelView alloc] initWithFrame:rect];
		}
		else 
		{
			cellView=[[CellImageView alloc] initWithFrame:rect];
		}

		cellView.iParentView=self;
		[cellView setContent:cellData delegate:aDelegate];
		
		[self addSubview:cellView];
        if(!cellViewArray_)
        {
            cellViewArray_=[[NSMutableArray alloc] initWithCapacity:count];
        }
        [cellViewArray_ addObject:cellView];
		
		[cellView release];
	}
	
	[self setContentSize];
}

-(void)addCell:(CellData*)aCellData 
	  delegate:(id<CellViewDelegate>)aDelegate
{	
	int columns=iColumns;
	int intervalH=iIntervalH;
	int intervalV=iIntervalV;
	int itemCountPerPage=iRows*iColumns;
	int subViewCount=[cellViewArray_ count];

	CGRect rect;
	if(iLayoutDirectionH==0)
	{
		//rect.origin.x=intervalH+subViewCount%columns*(iCellWidth+intervalH*2);
        rect.origin.x=intervalH+subViewCount%columns*(iCellWidth+intervalH*2)+(int)subViewCount/itemCountPerPage*(self.bounds.size.width-paddingRight_);
        rect.origin.y=intervalV+subViewCount%itemCountPerPage/columns*(iCellHeight+intervalV*2);
	}
	else 
	{
		rect.origin.x=intervalH+(columns-subViewCount%columns-1)*(iCellWidth+intervalH*2);
        rect.origin.y=intervalV+subViewCount/columns*(iCellHeight+intervalV*2);
	}
	
	rect.size.width=iCellWidth;
	rect.size.height=iCellHeight;

	CellView* cellView=nil;
	if(aCellData.iLabelText)
	{
		cellView=[[CellImageLabelView alloc]initWithFrame:rect];
	}
	else 
	{
		cellView=[[CellImageView alloc]initWithFrame:rect];
	}
	
	cellView.iParentView=self;
	[cellView setContent:aCellData delegate:aDelegate];
	if(aCellData.iId<0 || isIndexContinuous_)
	{
		aCellData.iId=subViewCount;
	}

	[self addSubview:cellView];
    if(!cellViewArray_)
    {
        cellViewArray_=[[NSMutableArray alloc] initWithCapacity:1];
    }
    [cellViewArray_ addObject:cellView];
    
	[cellView release];
	
	if(subViewCount==0)
	{	
		//scroll grid view
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
	}
	
	[self setContentSize];
}

- (void)dealloc 
{
    [backgroundImage_ release];
    [cellViewArray_ release];
    [borderColor_ release];
	[iPageControl release];
	[super dealloc];
}

-(void)setSingleSelected:(int)aId
{
	NSArray* subViewArray=cellViewArray_;//[self subviews];
	int count=[subViewArray count];
	for(int i=0;i<count;i++)
	{
		CellView* cellView=[subViewArray objectAtIndex:i];
		if([cellView isKindOfClass:[CellView class]])
		{
			if(cellView.iCellData.iId==aId)
			{
				iCurrentIndex=i;
				[cellView setSelected:YES];
				[cellView setUserInteractionEnabled:NO];
			}
			else 
			{
				[cellView setSelected:NO];
				[cellView setUserInteractionEnabled:YES];
			}
		}
	}
}

-(void)removeCellViewAtIndex:(int)index animated:(BOOL)animated
{
    __block CellView* cellView=[cellViewArray_ objectAtIndex:index];
    __block CGRect frontRect=cellView.frame;
    [cellView removeFromSuperview];
    [cellViewArray_ removeObjectAtIndex:index];
    
    void (^animations)()=^
    {
        for (int i=index;i<cellViewArray_.count;i++)
        {
            cellView=[cellViewArray_ objectAtIndex:i];
            CGRect tempRect=cellView.frame;
            cellView.frame=frontRect;
            frontRect=tempRect;
        }
    };
    
    if(animated)
    {
        [UIView animateWithDuration:0.5 animations:animations completion:^(BOOL finished) {
            [self setContentSize];
        }];
    }
    else
    {
        animations();
        [self setContentSize];
    }
}

-(CellView*)cellViewAtIndex:(int)aIndex
{
	NSArray* subViewArray=cellViewArray_;//[self subviews];
	return [subViewArray objectAtIndex:aIndex];
}

-(void)gotoFirstPage
{
	iCurrentIndex=0;
	self.contentOffset=CGPointMake(0, 0);
    iPageControl.currentPage=0;
}

//待检验
-(void)relayout
{
	int columns=iColumns;
	int rows=iRows;
	int intervalH=iIntervalH;
	int intervalV=iIntervalV;
	
	NSArray* viewArray=[self subviews];
	int count=[viewArray count];
	int itemCountPerPage=rows*columns;
	
	for(int i=0;i<count;i++)
	{
		CellView* cellView=[viewArray objectAtIndex:i];
		
		CellData* cellData=cellView.iCellData;
		if(cellData.iId<0 || isIndexContinuous_)
		{
			cellData.iId=i;
		}
		
		CGRect rect=CGRectZero;
		rect.size.width=iCellWidth;
		rect.size.height=iCellHeight;
		
		if(iScrollDirection==EScrollDirectionVerticle)
		{
			if(iLayoutDirectionH==0)
			{
				rect.origin.x=intervalH+i%columns*(iCellWidth+intervalH*2);
			}
			else 
			{
				rect.origin.x=intervalH+(columns-i%columns-1)*(iCellWidth+intervalH*2);
			}
			rect.origin.y=intervalV+i/columns*(iCellHeight+intervalV*2);
		}
		else 
		{
			/*
			 //在一页内先竖排
			 rect.origin.x=intervalH+i/rows*(iCellWidth+intervalH*2);
			 rect.origin.y=intervalV+i%rows*(iCellHeight+intervalV*2);
			 */
			
			//在一页内先横排
			rect.origin.x=intervalH+i%columns*(iCellWidth+intervalH*2)+i/itemCountPerPage*self.bounds.size.width;
			rect.origin.y=intervalV+i%itemCountPerPage/columns*(iCellHeight+intervalV*2);
		}
		
		cellView.frame=rect;
	}
	
	[self setContentSize];
}

-(void)setContentSize
{
	int count=[cellViewArray_ count];//[[super subviews] count];
	
	//scroll grid view
	CGSize newContentSize=CGSizeZero;
	int pageNumber=count / (iRows*iColumns);
	int modeCount=count % (iRows*iColumns);//余数
	if(modeCount>0)
	{
		pageNumber++;
	}
	
    if(iScrollDirection==EScrollDirectionVerticle)
	{
		//垂直滚动
		if(self.pagingEnabled)
		{
			newContentSize=CGSizeMake(self.bounds.size.width,pageNumber*self.bounds.size.height);
		}
		else
		{
			if(modeCount==0)
			{
				newContentSize=CGSizeMake(self.bounds.size.width,pageNumber*self.bounds.size.height);
			}
			else
			{
				int lastPageRows=modeCount/iColumns+ (modeCount%iColumns>0?1:0);
				int lastPageHeight=lastPageRows*(iCellHeight+iIntervalV*2);
				newContentSize=CGSizeMake(self.bounds.size.width,(pageNumber-1)*self.bounds.size.height+lastPageHeight);
			}
		}
	}
	else 
	{
		//水平滚动
        if(contentSizeToFit_ && modeCount>0)
		{
            int lastPageColumns=modeCount/iRows+ (modeCount%iRows>0?1:0);
            int lastPageWidth=lastPageColumns*(iCellWidth+iIntervalH*2);
            newContentSize=CGSizeMake((pageNumber-1)*self.bounds.size.width+lastPageWidth,
                                      self.bounds.size.height);
        }
        else
        {
            newContentSize=CGSizeMake(pageNumber*self.bounds.size.width,self.bounds.size.height);
        }
	}
    
    newContentSize.width-=paddingRight_*(modeCount>0?pageNumber-1:pageNumber);
	
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.contentSize =newContentSize;
}

-(void)showPageControl
{
    CGRect rect=self.frame;
    rect.size.height=10;
    rect.origin.y=self.frame.origin.y+self.frame.size.height-rect.size.height;
    
    [self showPageControlWithFrame:rect superView:[self superview]];
}

-(void)showPageControlWithFrame:(CGRect)frame superView:(UIView*)superView
{
    [self showPageControlWithFrame:frame superView:superView activeImage:nil inactiveImage:nil];
}

-(void)showPageControlWithActiveImage:(UIImage*)activeImage inactiveImage:(UIImage*)inactiveImage
{
    CGRect rect=self.frame;
    rect.size.height=10;
    rect.origin.y=self.frame.origin.y+self.frame.size.height-rect.size.height;
    
    [self showPageControlWithFrame:rect superView:[self superview] activeImage:activeImage inactiveImage:inactiveImage];
}

-(void)showPageControlWithFrame:(CGRect)frame superView:(UIView*)superView activeImage:(UIImage*)activeImage inactiveImage:(UIImage*)inactiveImage
{
    [iPageControl removeFromSuperview];
    [iPageControl release];
    iPageControl=nil;
    
    if(iScrollDirection==EScrollDirectionHorizontal)
	{
		self.pagingEnabled=YES;
		
        if(activeImage && activeImage)
        {
            iPageControl=[[CustomPageControl alloc] initWithFrame:frame activeImage:activeImage inactiveImage:inactiveImage];
        }
        else 
        {
            iPageControl=[[UIPageControl alloc] initWithFrame:frame];
        }
        [superView addSubview:iPageControl];
        iPageControl.hidesForSinglePage=YES;
        [iPageControl addTarget:self action:@selector(onPageControlValueChanged) forControlEvents:UIControlEventValueChanged];
        
		int count=[cellViewArray_ count];//[[super subviews] count];
		int pageNumber=count / (iRows*iColumns);
		if(count % (iRows*iColumns) >0)
		{
			pageNumber++;
		}
		iPageControl.numberOfPages=pageNumber;
        iPageControl.currentPage=0;
	}
}

-(void)movePageControlOffset:(CGPoint)offset
{
    CGRect frame=iPageControl.frame;
	frame.origin.x+=offset.x;
    frame.origin.y+=offset.y;
	iPageControl.frame=frame;
}

-(void)addFrameY:(int)aHeight
{
	CGRect frame=self.frame;
	frame.origin.y+=aHeight;
	self.frame=frame;
	
	frame=iPageControl.frame;
	frame.origin.y+=aHeight;
	iPageControl.frame=frame;
}

-(void)onPageControlValueChanged
{
	[self setContentOffset:CGPointMake(self.bounds.size.width*iPageControl.currentPage,self.contentOffset.y) animated:YES];
}

- (void)drawRect:(CGRect)rect
{
    if(iPageControl && !iPageControl.superview)
    {
        [self.superview addSubview:iPageControl];
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, NO);
    CGContextSetStrokeColorWithColor(context, [borderColor_ CGColor]);
    CGContextSetLineWidth(context, 1);
    CGContextBeginPath(context);

    if(borderColor_)
    {
        //水平绘制borderColor
        int y=1;
        while (y<=self.bounds.size.height) 
        {        
            CGContextMoveToPoint(context, 0, y);
            CGContextAddLineToPoint(context, self.bounds.size.width,y);
            
            y=y==1?0:y;
            
            y+=iCellHeight+iIntervalV+iIntervalV;
        }
        
        //垂直平绘制borderColor
        int x=0;
        while (x<=self.bounds.size.width) 
        {        
            CGContextMoveToPoint(context, x,0);
            CGContextAddLineToPoint(context, x, self.bounds.size.height);
            
            x+=iCellWidth+iIntervalH+iIntervalH;
        }
    }
    
    //backgroundImage
    if(backgroundImage_)
	{
		CGRect r = CGRectZero;
        if(EScrollDirectionHorizontal==iScrollDirection)
        {
            r.origin.y = 0;
            r.origin.x = self.contentOffset.x;
        }
        else
        {
            r.origin.y = self.contentOffset.y;
            r.origin.x = 0;
        }
        r.size = backgroundImage_.size;

		[backgroundImage_ drawInRect:r];
	}
    
    CGContextDrawPath(context, kCGPathStroke);
}

-(void)setCurrentPageIndex:(int)currentPageIndex
{
    [self showPageControl];
    iCurrentIndex=currentPageIndex;
    iPageControl.currentPage=currentPageIndex;
    [self setContentOffset: CGPointMake(self.bounds.size.width*currentPageIndex, 0) animated:NO];
}

-(void)updateCellView
{
    for(CellView* cellView in cellViewArray_)
    {
        [cellView updateView];
    }
}

-(void)updateCellViewTextColor:(UIColor*)textColor
{
    for(CellView* cellView in cellViewArray_)
    {
        cellView.iCellData.iLabelTextColor=textColor;
        [cellView updateView];
    }
}
    
#pragma mark - fromParent
-(void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    iPageControl.alpha=alpha;
}
    
-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    iPageControl.hidden=hidden;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if(iPageControl)
	{
		CGPoint offset = scrollView.contentOffset;
		int page=offset.x/self.bounds.size.width;
        int mode=[[NSNumber numberWithFloat:offset.x] intValue]%[[NSNumber numberWithFloat:self.bounds.size.width] intValue];
		if(iPageControl.currentPage!=page && mode==0)
		{
			iPageControl.currentPage=page;
            iCurrentIndex=page;
		}
	}
}
@end